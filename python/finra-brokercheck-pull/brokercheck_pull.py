"""Pull FINRA BrokerCheck reports for a list of CRDs and emit a CSV summary.

Reads CRDs from a CSV (one CRD per row, first column) or from --crd
arguments. For each CRD, downloads the public BrokerCheck PDF, extracts
the rep's name, current registration status, and prior-firm registration
history, and writes a row to the output CSV.

Example:

    python brokercheck_pull.py --in crds.csv --out report.csv
    python brokercheck_pull.py --crd 215549 --crd 837692 --out report.csv

The PDF parsing is layout-based and fragile; FINRA changes the
BrokerCheck PDF format from time to time. If a field comes back blank
or wrong, run with --debug to see the raw section text the script is
slicing from.
"""

from __future__ import annotations

import argparse
import csv
import io
import sys
import urllib.request
from dataclasses import dataclass
from pathlib import Path

from pypdf import PdfReader


BROKERCHECK_URL = "https://files.brokercheck.finra.org/individual/individual_{crd}.pdf"

NAME_BLOCK_START = "BrokerCheck Report"
NAME_BLOCK_END = "Section Title"
NOT_REGISTERED_MARKER = "This broker is not currently registered."
HISTORY_BLOCK_START = "The broker previously was registered with"
HISTORY_BLOCK_END = "This section provides up to 10 years"


@dataclass
class BrokerSummary:
    crd: str
    name: str = ""
    currently_registered: bool | None = None
    registration_history: str = ""
    error: str = ""


def fetch_pdf_text(crd: str, timeout: int = 30) -> str:
    url = BROKERCHECK_URL.format(crd=crd)
    with urllib.request.urlopen(url, timeout=timeout) as resp:  # noqa: S310 (public FINRA URL)
        data = resp.read()
    reader = PdfReader(io.BytesIO(data))
    return "\n".join(page.extract_text() or "" for page in reader.pages)


def parse_summary(crd: str, text: str) -> BrokerSummary:
    summary = BrokerSummary(crd=crd)

    name_start = text.find(NAME_BLOCK_START)
    name_end = text.find(NAME_BLOCK_END)
    if name_start != -1 and name_end != -1 and name_end > name_start:
        summary.name = text[name_start + len(NAME_BLOCK_START) : name_end].strip().strip("\n")

    summary.currently_registered = NOT_REGISTERED_MARKER not in text

    history_start = text.find(HISTORY_BLOCK_START)
    history_end = text.find(HISTORY_BLOCK_END)
    if history_start != -1 and history_end != -1 and history_end > history_start:
        summary.registration_history = (
            text[history_start:history_end].strip().replace("\r\n", "\n")
        )

    return summary


def load_crds(crds_arg: list[str], in_path: Path | None) -> list[str]:
    crds: list[str] = list(crds_arg)
    if in_path is not None:
        with in_path.open(newline="") as f:
            reader = csv.reader(f)
            for row in reader:
                if not row:
                    continue
                cell = row[0].strip()
                if not cell or cell.lower() == "crd":
                    continue
                crds.append(cell)
    return crds


def write_csv(out_path: Path, rows: list[BrokerSummary]) -> None:
    with out_path.open("w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["crd", "name", "currently_registered", "registration_history", "error"])
        for row in rows:
            writer.writerow(
                [
                    row.crd,
                    row.name,
                    "" if row.currently_registered is None else str(row.currently_registered),
                    row.registration_history,
                    row.error,
                ]
            )


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--in", dest="in_path", type=Path, help="CSV of CRDs (first column).")
    parser.add_argument("--crd", action="append", default=[], help="Single CRD; repeatable.")
    parser.add_argument("--out", dest="out_path", type=Path, required=True, help="Output CSV path.")
    parser.add_argument("--debug", action="store_true", help="Print raw extracted text for each CRD.")
    args = parser.parse_args(argv)

    crds = load_crds(args.crd, args.in_path)
    if not crds:
        parser.error("Provide CRDs via --in <csv> and/or --crd <id>.")

    rows: list[BrokerSummary] = []
    for crd in crds:
        try:
            text = fetch_pdf_text(crd)
        except Exception as e:  # noqa: BLE001
            print(f"[{crd}] fetch/parse failed: {e}", file=sys.stderr)
            rows.append(BrokerSummary(crd=crd, error=str(e)))
            continue

        if args.debug:
            print(f"---------- {crd} raw text ----------", file=sys.stderr)
            print(text, file=sys.stderr)

        summary = parse_summary(crd, text)
        rows.append(summary)
        print(
            f"[{crd}] {summary.name or '<name not parsed>'} — "
            f"{'registered' if summary.currently_registered else 'not registered'}",
            file=sys.stderr,
        )

    write_csv(args.out_path, rows)
    print(f"Wrote {len(rows)} rows to {args.out_path}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
