# OOO Summary

A Power Automate flow that emails a team a weekly summary of upcoming out-of-office (OOO) time, pulled from a shared SharePoint calendar list and addressed to the members of an Office 365 group.

## What it does

Every Friday morning the flow:

1. Queries a SharePoint "OOO Calendar" list for entries that overlap the next 30 days.
2. Enumerates members of an Office 365 group (the team's mailing-list group).
3. Builds an HTML table of those entries: Name, Start Date, End Date.
4. Emails the table to every group member with a link back to the calendar list so people can add missing entries.

Useful for teams where everyone has visibility into one another's planned time off without anyone having to check the calendar by hand.

## Data model

One SharePoint list — `OOO Calendar`. Recommended columns:

| Column | Type | Notes |
|---|---|---|
| `Title` | Single line of text | Person's name (the calendar entry's "subject"). |
| `Start Date` | Date | First day off. |
| `End Date` | Date | Last day off. |

Plus one Office 365 group — the team distribution list. Find its `groupId` in the Microsoft Entra admin centre or via Graph: `GET https://graph.microsoft.com/v1.0/groups`.

## Recipe

**Trigger:** Recurrence — frequency `Week`, interval `1`, weekday `Friday`, start time `<your preferred Friday morning UTC time>`.

**Actions, in order:**

1. **Get items** — SharePoint, site `{{SHAREPOINT_SITE_URL}}`, list `OOO Calendar` (or list GUID `{{LIST_GUID}}`).
   - Filter Query: `Start_x0020_Date le '@{addDays(utcNow(), 30, 'yyyy-MM-dd')}' and End_x0020_Date ge '@{formatDateTime(utcNow(), 'yyyy-MM-dd')}'`
   - Order By: `Start_x0020_Date`

   Internal field names use `_x0020_` for spaces (SharePoint encoding for "Start Date" → `Start_x0020_Date`).

2. **List group members** — Office 365 Groups, group ID `{{GROUP_ID}}`.

3. **Initialize variable** `Email List` (string).

4. **Apply to each** group member from `outputs('List_group_members')?['body/value']`:
   - **Append to string variable** `Email List` ← `@{items('Apply_to_each')?['userPrincipalName']}; ` (note trailing semicolon and space — Outlook accepts a `;`-delimited list).

5. **Create HTML table** from `outputs('Get_items')?['body/value']` with explicit columns:

   | Header | Value |
   |---|---|
   | `Name` | `@item()?['Title']` |
   | `Start Date` | `@item()?['Start_x0020_Date']` |
   | `End Date` | `@item()?['End_x0020_Date']` |

6. **Compose** — wrap the HTML table in a `<style>` block so it renders with borders and a header gradient instead of the unstyled default. Use `replace(...)` to inject a CSS class onto the `<table>` element:

   ```text
   <style>
   table.minimalistBlack {
     border: 3px solid #000000;
     width: 100%;
     text-align: left;
     border-collapse: collapse;
   }
   table.minimalistBlack td, table.minimalistBlack th {
     border: 1px solid #000000;
     padding: 5px 4px;
   }
   table.minimalistBlack tbody td { font-size: 15px; }
   table.minimalistBlack thead {
     background: #CFCFCF;
     background: linear-gradient(to bottom, #dbdbdb 0%, #d3d3d3 66%, #CFCFCF 100%);
     border-bottom: 3px solid #000000;
   }
   table.minimalistBlack thead th {
     font-size: 15px; font-weight: bold; color: #000000; text-align: left;
   }
   </style>

   @{replace(body('Create_HTML_table'), '<table>', '<table class="minimalistBlack">')}
   ```

7. **Send an email (V2)** — Office 365 Outlook.
   - To: `@variables('Email List')`
   - Subject: `Team Upcoming OOO`
   - Body:
     ```html
     <p>Hello,</p>
     <p>Please see the following summary of planned OOO dates for the team.</p>
     <p>@{outputs('Compose')}</p>
     <p>If any OOO time you have planned is missing, please visit the
       <a href="{{SHAREPOINT_SITE_URL}}/Lists/OOO%20Calendar/OOO%20Calendar.aspx">OOO Calendar</a>
       to make any additional entries.</p>
     <p>Thanks,<br>{{YOUR_NAME}}</p>
     ```

## Notes

- The `replace('<table>', '<table class="...">')` trick is the simplest way to style a table built by `Create HTML table` — Power Automate doesn't expose a class attribute on the action.
- A semicolon-delimited string in the `To` field works because Outlook splits on `;`. If you'd rather pass a JSON array, change the variable type to `array` and append objects, then pass `@variables('Email List')` directly.
- Filter dates as strings (`yyyy-MM-dd`) — SharePoint's OData filter expects ISO-8601 date literals in single quotes.
- This is a **read-only** flow as far as the SharePoint list is concerned; safe to run on a real calendar without write-permission worries.

## What you swap for your org

- The SharePoint site URL and list GUID
- The Office 365 group ID
- The recurrence schedule (day, time, frequency) to match when your team wants the digest
- Your name in the signature line
- Optional: column display names if your calendar uses different field names
