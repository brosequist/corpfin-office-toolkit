# Initiative Tracker

A canvas Power App over a three-list SharePoint data model for tracking the work of a transformation programme: high-level **Initiatives**, the **Domains** they touch, and the **Tasks** that move them forward.

## What it does

A single canvas app with screens to:

- Browse and filter initiatives.
- Drill into an initiative to see the domains it spans and the tasks under it.
- Add and edit tasks inline.

The app authenticates user identity through the **Office 365 Users** connector so it can show "tasks owned by me" and pre-fill submitter fields.

## Data model

Three SharePoint lists, all on the same site.

### `Initiatives`

| Column | Type | Notes |
|---|---|---|
| `Title` | Single line of text | Initiative name. |
| `Sponsor` | Person or Group | Optional. |
| `Status` | Choice | e.g. Not Started, In Progress, On Hold, Done. |
| `Target Date` | Date | Optional. |

### `Domains`

| Column | Type | Notes |
|---|---|---|
| `Title` | Single line of text | Domain name (e.g. "Reporting", "Reconciliation"). |
| `Initiative` | Lookup → Initiatives | The parent initiative. |

### `Tasks`

| Column | Type | Notes |
|---|---|---|
| `Title` | Single line of text | Task description. |
| `Domain` | Lookup → Domains | Which domain this task is under. |
| `Owner` | Person or Group | |
| `Status` | Choice | |
| `Deadline` | Date | Optional. |

## Canvas app — key formulas

```text
// Browse screen — Initiatives gallery
Items = SortByColumns(Filter('{{LIST_NAME_INITIATIVES}}', Status.Value <> "Done"), "Title", Ascending)

// Drilldown — Domains for selected initiative
Items = Filter('{{LIST_NAME_DOMAINS}}', Initiative.Id = galInitiatives.Selected.ID)

// Drilldown — Tasks for selected domain
Items = Filter('{{LIST_NAME_TASKS}}', Domain.Id = galDomains.Selected.ID)

// Inline new-task
OnSelect = Patch(
    '{{LIST_NAME_TASKS}}',
    Defaults('{{LIST_NAME_TASKS}}'),
    {
        Title: txtNewTask.Text,
        Domain: { Id: galDomains.Selected.ID, Value: galDomains.Selected.Title },
        Owner: { Claims: "i:0#.f|membership|" & Lower(User().Email) },
        Status: { Value: "Not Started" }
    }
)
```

## Notes

- Lookup columns require the `Id` and `Value` shape on `Patch`. Forgetting `Id` is the #1 reason "it saved but the lookup is empty".
- For lists that may exceed the 2000-row Power Apps default, raise the **App settings → Data row limit for non-delegable queries**, or be careful that all your `Filter` predicates are delegable to SharePoint.
- This app pairs well with a "weekly status digest" flow modelled on the [pmo-task-tracker](../pmo-task-tracker/) reminder flow.

## What you swap for your org

- Three SharePoint list names / GUIDs and the site URL
- Choice values for status fields
- Branding / logo on the home screen
