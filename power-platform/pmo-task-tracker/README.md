# PMO Task Tracker

A canvas Power App for finance PMO members to enter and update their open tasks each month, paired with two Power Automate flows that handle the recurring admin work.

## What it does

- **Canvas app** ("Rapid Report"): a one-screen UI to view and update tasks owned by the signed-in user for the current reporting period. Filters by `Task Owner = Office365Users.MyProfile().Mail` and shows status, deadline, and a free-text update field.
- **Rollover flow** (monthly recurrence): on the first of each month, copies every task with status ≠ `Cancelled`/`Complete` from the previous period to the current period, preserving owner, domain, deadline, and comments. Posts a Teams notification when complete.
- **Reminder flow** (calendar-driven): triggered by a recurring Outlook event titled `Status Updates Due`, the flow groups open tasks by owner and emails each owner a personalised HTML table of just their tasks with a deep-link back to the canvas app.

The whole pattern is built around **one SharePoint list** that all three components share.

## Data model

One SharePoint list — call it `Finance PMO Tasks`. Recommended columns:

| Column | Type | Notes |
|---|---|---|
| `Title` | Single line of text | The task description. |
| `Reporting Date` | Date | One value per period; rollover sets this to "last day of prior month". |
| `Task Owner` | Person or Group | Single user. The reminder flow groups by `Email`. |
| `Task Status` | Choice | e.g. `Not Started`, `In Progress`, `Complete`, `Cancelled`, `Blocked`. |
| `Task Domain` | Choice | Optional — for grouping in the canvas app. |
| `Task Sponsor(s)` | Person or Group (multi) | Optional. |
| `Task Deadline` | Date | Optional. |
| `Comments` | Multiple lines of text | Optional. |
| `Link to Additional Detail` | Hyperlink | Optional. |
| `Locked` | Yes/No | Optional — the canvas app can hide locked rows. |

When SharePoint stores spaces in column internal names it replaces them with `_x0020_`, so flow expressions reference fields like `Task_x0020_Owner` and `Task_x0020_Status/Value`.

## Canvas app (Rapid Report) — key formulas

```text
// On a Gallery showing the current user's tasks
Items =
    Filter(
        '{{LIST_NAME}}',
        'Task Owner'.Email = Office365Users.MyProfile().Mail,
        'Reporting Date' >= DateAdd(StartOfMonth(Today()), -1, Months)
    )

// Submit-button OnSelect — patch the selected gallery row
OnSelect = Patch(
    '{{LIST_NAME}}',
    galTasks.Selected,
    {
        'Task Status': { Value: drpStatus.Selected.Value },
        Comments: txtComment.Text
    }
)

// New-task button OnSelect — create a row for the current period
OnSelect = Patch(
    '{{LIST_NAME}}',
    Defaults('{{LIST_NAME}}'),
    {
        Title: txtNewTitle.Text,
        'Task Owner': { Claims: "i:0#.f|membership|" & Lower(User().Email) },
        'Reporting Date': EOMonth(Today(), -1) + 1,
        'Task Status': { Value: "Not Started" }
    }
)
```

## Rollover flow — recipe

**Trigger:** Recurrence — frequency `Month`, interval `1`, time-zone `Eastern Standard Time`, start `2020-05-01T00:00:00`.

**Actions, in order:**

1. **Get items** — SharePoint, site `{{SHAREPOINT_SITE_URL}}`, list `{{LIST_NAME}}` (or list GUID `{{LIST_GUID}}`).
   - Filter Query: `Reporting_x0020_Date ge '@{subtractFromTime(startOfMonth(utcNow()), 2, 'Month')}' and Task_x0020_Status ne 'Cancelled' and Task_x0020_Status ne 'Complete'`
   - Order By: `Title asc`
2. **Apply to each** over `body('Get items')?['value']`:
   - **Create item** — same site/list. Body:
     ```json
     {
       "Title": "@{items('Apply_to_each')?['Title']}",
       "Reporting_x0020_Date": "@{addDays(startOfMonth(utcNow()), -1)}",
       "Task_x0020_Owner": {
         "Claims": "@{items('Apply_to_each')?['Task_x0020_Owner']?['Claims']}"
       },
       "Task_x0020_Status": {
         "Value": "@{items('Apply_to_each')?['Task_x0020_Status']?['Value']}"
       },
       "Task_x0020_Domain": {
         "Value": "@{items('Apply_to_each')?['Task_x0020_Domain']?['Value']}"
       },
       "Task_x0020_Sponsor_x0028_s_x0029": "@{items('Apply_to_each')?['Task_x0020_Sponsor_x0028_s_x0029']}",
       "Comments": "@{items('Apply_to_each')?['Comments']}",
       "Task_x0020_Deadline": "@{items('Apply_to_each')?['Task_x0020_Deadline']}",
       "Locked": false
     }
     ```
3. **Post a message in a chat or channel** — Teams. Group `{{TEAMS_GROUP_ID}}`, channel `{{TEAMS_CHANNEL_ID}}`, message:
   `Finance PMO Rapid Reports task data was successfully rolled forward from @{getPastTime(2, 'Month', 'MMMM')} to @{getPastTime(1, 'Month', 'MMMM')}.`

## Reminder flow — recipe

**Trigger:** Outlook 365 → *When an upcoming event is starting soon (V3)*. Pick the calendar that holds your recurring `Status Updates Due` event. `lookAheadTimeInMinutes` ≈ a few days so it fires once per occurrence.

**Top-level Condition:** only fire when the calendar event subject is `Status Updates Due`:
- `equals(triggerBody()?['subject'], 'Status Updates Due')`

**Actions inside the condition (in order):**

1. **Initialize variable** `TaskTable` (array).
2. **Initialize variable** `DistinctEmails` (array).
3. **Get items** — SharePoint, list `{{LIST_NAME}}`, filter `Reporting_x0020_Date ge '@{subtractFromTime(startOfMonth(utcNow()), 1, 'Month')}'`, order by `Title asc`.
4. **Apply to each** task → append `Task Owner email` to `DistinctEmails` and append a struct `{ Owner Name, Owner Email, Task Description, Task Status }` to `TaskTable`.
5. **Compose** — deduplicate `DistinctEmails`: `union(variables('DistinctEmails'), variables('DistinctEmails'))`. Save back into `DistinctEmails` with **Set variable**.
6. **Apply to each** unique email:
   - **Filter array** `TaskTable` where `Owner Email == current email`.
   - **Select** to keep only `Task Description` and `Task Status` columns.
   - **Create HTML table** from the selected rows.
   - **Compose** — wrap the HTML table in a `<style>` block with table borders and a header gradient (any styling you like).
   - **Send an email (V2)** — to `current email`, subject `Finance PMO Task Updates Due by @{formatDateTime(triggerBody()?['end'], 'ddddd, MMMM d')}`, body includes the styled table plus a deep-link back to the canvas app: `https://apps.powerapps.com/play/{{APP_ID}}?tenantId={{TENANT_ID}}`.

## What you swap for your org

- The SharePoint site URL and list GUID
- Your Azure AD tenant ID in the deep-link URL
- The Teams channel ID + group ID for the rollover notification
- The Outlook calendar that hosts the recurring "Status Updates Due" event
- Email signature / branding in the reminder email body
- Status / Domain choice values to match your team's vocabulary
