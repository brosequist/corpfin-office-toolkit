# corpfin-office-toolkit

Small, focused utilities for Corporate Finance professionals — the kind of glue code that would otherwise live as untracked snippets pasted into a teammate's email.

## Scope

This is a personal collection. It favors:

- **Excel** as the primary surface, since that's where most finance work lands.
- **VBA** for in-workbook automation that needs to ship as a single file.
- **Power Platform** (Power Apps + Power Automate) for SharePoint- and SQL-backed apps. Captured here as recipes you re-implement in your own tenant, not as importable binaries.
- **Python** for one-off batch jobs against public APIs.

Each utility lives in its own directory with its own README explaining what it does, how to install it, and any caveats.

## Contents

| Path | Description |
|---|---|
| [`excel/distro-mailer/`](excel/distro-mailer/) | Send the active Excel workbook to a list of email addresses read from a column on the active sheet. |
| [`power-platform/`](power-platform/) | Recipes for canvas Power Apps and Power Automate flows: PMO task tracker, incident tracker, initiative tracker, intake form, OOO summary digest, and a SQL-stored-proc flow template. |
| [`python/finra-brokercheck-pull/`](python/finra-brokercheck-pull/) | Bulk-download FINRA BrokerCheck reports for a list of broker CRDs and extract name / registration status / history into a CSV. |

## Conventions

- VBA modules are checked in as exported `.bas` files. Workbook copies (`.xlsm`) are included for convenience but the `.bas` exports are the canonical source.
- Every module starts with `Option Explicit`.
- Public entry points are documented at the top of each module.

## License

Provided as-is for personal and professional reuse. No warranty.
