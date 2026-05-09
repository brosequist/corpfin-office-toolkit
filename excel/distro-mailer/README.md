# Excel Distro Mailer

Send the active Excel workbook as an attachment to a list of email addresses listed vertically on a worksheet.

Typical use: a finance template that gets distributed to the same standing list every period. Drop the addresses into a column, click into the top one, run the macro.

## Files

| File | Role |
|---|---|
| `VerticalListToArray.bas` | `StoreVerticalListToArray(StartCell)` — reads a contiguous column of strings into a `String()` array. |
| `ArrayToDistributionList.bas` | `SendToDistributionList(EmailList, Subject)` — sends `ActiveWorkbook` to each address. |
| `DistroListExampleMain.bas` | `DistroListExampleMain` — demo entry point; reads from the active cell, sends with a default subject. |
| `DistroListExample.xlsm` | Pre-wired demo workbook. |

The `.bas` files are the canonical source. The `.xlsm` is a convenience copy and may drift; if you need to refresh it, re-import the `.bas` modules.

## Installation

Either:

1. Open `DistroListExample.xlsm` and use it directly, **or**
2. Import the three `.bas` files into your own workbook:
   - Open the workbook, press `Alt+F11` to launch the VBA editor.
   - `File → Import File…` and pick each `.bas`.
   - Save the host workbook as `.xlsm` (macro-enabled).

## Usage

1. Put the recipient email addresses in a single column on any sheet, one per row, no blank rows in the middle.
2. Click the cell containing the **first** address.
3. `Alt+F8 → DistroListExampleMain → Run`.

The active workbook is sent to every address in the column with the subject "Please see the attached workbook".

## Caveats

- **`ActiveWorkbook.SendMail` uses the legacy MAPI client.** On modern M365/Outlook installs it commonly:
  - Surfaces a security prompt the user must click through.
  - Fails silently if no MAPI provider is registered.
  - Doesn't let you set CC/BCC, body, or attachments other than the workbook itself.

  For production use, replace `SendToDistributionList` with Outlook automation (`CreateObject("Outlook.Application")`) or an SMTP library. The current implementation is intentionally minimal.
- The reader stops at the **first empty cell**. Blank rows split the list.
- The workbook must be saved on disk (not a brand-new untitled file) for `SendMail` to attach anything useful.
