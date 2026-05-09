# Incident Tracker

A canvas Power App for logging close-process (or any other) incidents into a SharePoint list, paired with a Power Automate flow that emails the right people based on which segments and functions the incident touches.

## What it does

- **Canvas app** ("Close Incident Report"): a form that captures the incident title, description, submitter, the impacted segments, and the impacted functions. Writes to a SharePoint list on submit.
- **Notification flow**: triggers when a new incident is created in that list. For each impacted segment/function tag, looks up matching key-contact records in a separate "Contacts" list, deduplicates the resulting email list, and sends each contact a personalised HTML email with a deep-link back to the canvas app.

## Data model

Two SharePoint lists.

### `Incidents` list

| Column | Type | Notes |
|---|---|---|
| `Title` | Single line of text | Short incident title. |
| `Issue Description` | Multiple lines | Free text. |
| `Issue Submitter` | Person or Group | Auto-populated from the canvas app. |
| `Segment(s) Impacted` | Choice (multi) | Maps to the `Title` column on the Contacts list. |
| `Function(s) Impacted` | Choice (multi) | Same lookup mechanism as Segments. |

### `Contacts` list

| Column | Type | Notes |
|---|---|---|
| `Title` | Single line of text | Name of the segment or function — must exactly match the choice values used on the Incidents list. |
| `Contacts` | (multi-row child) | One row per contact; needs `DisplayName` and `Email`. |

In practice the `Contacts` column is often modelled as a related list or a JSON column; the flow expects items to have `?['Contacts']` as an enumerable of `{ DisplayName, Email }` records.

## Canvas app — key formulas

```text
// Submit-button OnSelect
OnSelect = Patch(
    '{{LIST_NAME_INCIDENTS}}',
    Defaults('{{LIST_NAME_INCIDENTS}}'),
    {
        Title: txtTitle.Text,
        'Issue Description': txtDescription.Text,
        'Issue Submitter': { Claims: "i:0#.f|membership|" & Lower(User().Email) },
        'Segment(s) Impacted': cmbSegments.SelectedItems,
        'Function(s) Impacted': cmbFunctions.SelectedItems
    }
);
Notify("Incident submitted", NotificationType.Success);
Navigate(scrConfirmation)
```

## Notification flow — recipe

**Trigger:** SharePoint → *When an item is created* on the `Incidents` list. Recurrence `5 minutes`.

**Actions, in order:**

1. **Get items** — pull all rows from the `Contacts` list. (We resolve email addresses entirely in-memory afterwards.)
2. **Initialize variable** `DistinctEmails` (array).
3. **Initialize variable** `DistinctDomains` (array).
4. **Apply to each** over `triggerOutputs()?['body/Segment_x0028_s_x0029__x0020_Imp']`:
   - **Append to array variable** `DistinctDomains` ← `{ "Domains": @{items()?['Value']}, "Type": "Segment" }`
5. **Apply to each** over `triggerOutputs()?['body/Function_x0028_s_x0029__x0020_Im']`:
   - **Append to array variable** `DistinctDomains` ← `{ "Domains": @{items()?['Value']}, "Type": "Segment" }` (the original used `Type: Segment` for both — change to `"Function"` if you care about the distinction in downstream logic)
6. **Apply to each** in `DistinctDomains`:
   - **Filter array** the `Contacts` items where `Title == current Domains value`.
   - **Apply to each** filtered record → **Apply to each** in `?['Contacts']` → append `{ Email, Name }` to `DistinctEmails`.
7. **Compose — Remove Duplicates** from DistinctEmails: `union(variables('DistinctEmails'), variables('DistinctEmails'))`.
8. **Apply to each** in the deduplicated output:
   - **Send an email (V2)** to `?['Email']` with a subject like `New Close Incident Logged` and an HTML body that includes:
     - `Hello @{items()?['Name']}`
     - Incident title from `triggerOutputs()?['body/Title']`
     - Submitter from `triggerOutputs()?['body/Issue_x0020_Submitter/DisplayName']`
     - Description from `triggerOutputs()?['body/Issue_x0020_Description']`
     - A deep-link to the canvas app: `https://apps.powerapps.com/play/{{APP_ID}}?tenantId={{TENANT_ID}}`
     - A deep-link to the contacts list so recipients can self-service updates: `{{SHAREPOINT_SITE_URL}}/Lists/Contacts/AllItems.aspx`

## Notes

- The pattern of "tag the record with one or more taxonomy values, then look up routing contacts in a separate list keyed by `Title`" is more flexible than putting recipients directly on the form — it lets ops update the routing list without touching the canvas app or the flow.
- The `union(x, x)` idiom is the standard Power Automate trick for deduplicating an array.
- The original encoded segment and function items both as `Type: "Segment"`. Keep them distinct if your downstream logic ever needs to behave differently (e.g. priority-route by function only).

## What you swap for your org

- Both SharePoint list names / GUIDs and the parent site URL
- Tenant ID and canvas-app ID for the deep-link
- Choice values for `Segment(s) Impacted` and `Function(s) Impacted`
- Email subject / body / branding
