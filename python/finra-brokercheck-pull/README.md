# FINRA BrokerCheck Pull

Bulk-download FINRA BrokerCheck reports for a list of broker CRDs and extract a basic summary — name, current registration status, and prior-firm registration history — into a CSV.

Useful for compliance / due-diligence workflows where you need to spot-check the registration status of many reps at once.

## Install

```bash
python3 -m venv .venv && . .venv/bin/activate
pip install -r requirements.txt
```

## Usage

```bash
# From a CSV of CRDs (first column; header optional)
python brokercheck_pull.py --in crds.example.csv --out report.csv

# Or pass CRDs directly
python brokercheck_pull.py --crd 215549 --crd 837692 --out report.csv

# Mix both
python brokercheck_pull.py --in crds.example.csv --crd 1234567 --out report.csv

# Dump raw extracted text to stderr for diagnosing parse failures
python brokercheck_pull.py --crd 215549 --out report.csv --debug
```

Output columns:

| Column | Notes |
|---|---|
| `crd` | The input CRD. |
| `name` | Best-effort extracted rep name. Empty if the layout markers couldn't be found. |
| `currently_registered` | `True` / `False` based on the "This broker is not currently registered." marker. |
| `registration_history` | Free-text block listing prior firms and date ranges. |
| `error` | Set if download/parse failed for this CRD. |

## How the parsing works

The script downloads the public PDF at `https://files.brokercheck.finra.org/individual/individual_<CRD>.pdf` and extracts text with `pypdf`. It then slices three sections out by string-matching anchor phrases:

- Name: between `BrokerCheck Report` and `Section Title`.
- Registration status: presence/absence of `This broker is not currently registered.`.
- History: between `The broker previously was registered with` and `This section provides up to 10 years`.

This is layout-fragile by design — FINRA periodically changes the BrokerCheck PDF format. If outputs come back blank, run with `--debug` and inspect the raw text. The anchor strings are constants at the top of `brokercheck_pull.py`; adjust them to match the current format.

## Caveats

- Only public BrokerCheck reports are supported. Reps without published reports return a 404 and are recorded with an `error`.
- Network-bound and serial. For large batches, add a `--workers` option (or run a few processes in parallel against disjoint CSV slices).
- Ethics / TOS: BrokerCheck data is public, but FINRA's [terms of use](https://brokercheck.finra.org/terms-of-use) prohibit using BrokerCheck for commercial purposes other than to inform investment decisions. Don't redistribute the raw PDFs.
