# Excel Macro Recipes

Small, reusable VBA building blocks. Each module is self-contained and operates on a passed `Range` or `Worksheet` rather than `ActiveCell` / `Selection`, so they compose cleanly into your own macros.

## Modules

| File | Purpose |
|---|---|
| [`CellLoopPatterns.bas`](CellLoopPatterns.bas) | Walk a column from a starting cell — find first non-empty, find last non-empty, run an action per row until empty. |
| [`MonthColumns.bas`](MonthColumns.bas) | Write `Jan`–`<cutoff>` month abbreviations across columns; YTD variant adds a prior-/current-year header row. |
| [`FormattingPatterns.bas`](FormattingPatterns.bas) | Apply Currency / Percent / Comma styles to a column; highlight a row in yellow with red bold-italic font. |
| [`R1C1Formulas.bas`](R1C1Formulas.bas) | Three flavours of `FormulaR1C1`: absolute, relative, mixed (e.g. "% of column B"). |
| [`ResetWorksheet.bas`](ResetWorksheet.bas) | Three reset patterns: hardcoded headers, headers from a string array, contiguous-block clear via `CurrentRegion`. |
| [`WorksheetLoop.bas`](WorksheetLoop.bas) | Index-based iteration from a starting worksheet, plus an unconditional "loop every sheet" variant. |

## Conventions

- Every module starts with `Option Explicit` and declares all variables.
- Public entry points take their context as an argument (`Range`, `Worksheet`, `Workbook`) instead of relying on the selection or active sheet. This is what lets them compose.
- Where the original SkillScale examples used `ActiveCell.Offset(...).Activate` to walk cells, these recipes use `Cursor.Offset(...)` against a `Range` variable. Avoiding `.Select` / `.Activate` is faster, cleaner, and doesn't disturb the user's actual selection.

## Installing

In any workbook, press `Alt+F11` to open the VBA editor, then `File → Import File…` and pick the `.bas` files you want. They land as standard modules — call them from your own subs.
