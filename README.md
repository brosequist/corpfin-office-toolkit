# corpfin-office-toolkit

Small, focused MS Office utilities for Corporate Finance professionals — the kind of glue code that would otherwise live as untracked snippets pasted into a teammate's email.

## Scope

This is a personal collection. It favours:

- **Excel** as the primary surface, since that's where most finance work lands.
- **VBA** for in-workbook automation that needs to ship as a single file.
- **Power Query (M)** and **DAX** for repeatable, model-driven transformations (none yet — placeholder for additions).
- **Access** for lightweight desktop databases when a workbook isn't enough (none yet — placeholder for additions).

Each utility lives in its own directory with its own README explaining what it does, how to install it, and any caveats.

## Contents

| Path | Description |
|---|---|
| [`excel/distro-mailer/`](excel/distro-mailer/) | Send the active Excel workbook to a list of email addresses read from a column on the active sheet. |

## Conventions

- VBA modules are checked in as exported `.bas` files. Workbook copies (`.xlsm`) are included for convenience but the `.bas` exports are the canonical source.
- Every module starts with `Option Explicit`.
- Public entry points are documented at the top of each module.

## License

Provided as-is for personal and professional reuse. No warranty.
