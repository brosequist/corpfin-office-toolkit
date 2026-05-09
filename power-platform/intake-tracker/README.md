# Intake Tracker

A canvas Power App that captures intake / new-request submissions and writes them to a SharePoint list. The simplest of the recipes — a good starting point if you're building your first canvas app.

## What it does

- One screen with a form: requester, request type, summary, free-text detail, optional attachments.
- A submit button that creates a row in the `Intake Requests` SharePoint list and sends the user back to a confirmation screen.
- A multi-select control for tagging the request with one or more "segments" — the original used a `colSegmentsSelected` in-memory collection to drive a chips-style UI.

## Data model

One SharePoint list — `Intake Requests`. Recommended columns:

| Column | Type | Notes |
|---|---|---|
| `Title` | Single line of text | Short summary. |
| `Requester` | Person or Group | Auto-populated from the signed-in user. |
| `Request Type` | Choice | e.g. New Report, Process Change, Tooling Request. |
| `Detail` | Multiple lines | Free text. |
| `Segment(s)` | Choice (multi) | Optional. |
| `Status` | Choice | Default `New`. Set later by triage. |

## Canvas app — key formulas

```text
// Multi-select chips backed by a collection
// (gallery shows colSegmentsSelected; clicking a chip removes it)
OnSelect on each segment chip = Remove(colSegmentsSelected, ThisItem)
OnSelect on the "add" combo box = Collect(colSegmentsSelected, cmbSegmentToAdd.Selected)

// Submit button
OnSelect =
    Patch(
        '{{LIST_NAME_INTAKE}}',
        Defaults('{{LIST_NAME_INTAKE}}'),
        {
            Title: txtSummary.Text,
            Requester: { Claims: "i:0#.f|membership|" & Lower(User().Email) },
            'Request Type': { Value: drpType.Selected.Value },
            Detail: txtDetail.Text,
            'Segment(s)': colSegmentsSelected,
            Status: { Value: "New" }
        }
    );
    Clear(colSegmentsSelected);
    Reset(txtSummary); Reset(txtDetail); Reset(drpType);
    Notify("Request submitted", NotificationType.Success);
    Navigate(scrConfirmation)
```

## Notes

- The `Clear` + `Reset` combo on submit prevents stale state if the user comes back to the form to submit another request.
- Multi-select choice columns expect a *collection* of `{ Value: "..." }` records — exactly what `colSegmentsSelected` is.
- For attachments, add an Attachment control bound to the form's `DataCard` (Power Apps wires it to SharePoint automatically).

## What you swap for your org

- The SharePoint list name / GUID and site URL
- Choice values for `Request Type`, `Segment(s)`, `Status`
- Branding on the form header
