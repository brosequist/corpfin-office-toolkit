# Power Platform recipes

Patterns for Power Apps + Power Automate apps commonly built by finance Citizen Developers. These are **documentation, not import packages** — the formulas, data-source schemas, and flow logic are captured here as recipes you can rebuild in your own tenant.

## Why recipes instead of `.zip` packages

Exported PowerApps and Flow packages embed:

- A specific Azure AD tenant ID
- SharePoint site URLs and list GUIDs
- Connection-reference IDs that only exist in the tenant they were built in

Even after stripping employer-specific data, a stranger can't import a sanitized binary into a different tenant without rewiring every connection by hand. So shipping the binaries adds little over a clear recipe.

## Recipes

| Recipe | What it is |
|---|---|
| [`pmo-task-tracker/`](pmo-task-tracker/) | Canvas app + scheduled "rollover" flow + monthly "task reminder" flow over a single SharePoint list. The classic finance-PMO task board. |
| [`incident-tracker/`](incident-tracker/) | Canvas form to log close-process incidents + flow that emails the right people based on impacted segments/functions. |
| [`initiative-tracker/`](initiative-tracker/) | Canvas app over three SharePoint lists (Initiatives → Domains → Tasks) for cross-functional programme tracking. |
| [`intake-tracker/`](intake-tracker/) | Canvas intake form that writes to a SharePoint list. The simplest of the bunch — a good starter. |
| [`flow-call-stored-proc/`](flow-call-stored-proc/) | A Power Automate flow that a canvas app calls to execute a SQL stored procedure and return rows. Generic template. |

## Conventions used in these recipes

Placeholders in formulas and JSON are written as `{{ALL_CAPS}}`:

- `{{TENANT_ID}}` — your Azure AD tenant ID
- `{{SHAREPOINT_SITE_URL}}` — e.g. `https://contoso.sharepoint.com/sites/finance`
- `{{LIST_NAME}}` / `{{LIST_GUID}}` — SharePoint list display name and ID
- `{{TEAMS_CHANNEL_ID}}` / `{{TEAMS_GROUP_ID}}` — Microsoft Teams identifiers
- `{{APP_ID}}` — Power Apps app ID for deep-link URLs

Replace these with your own values when implementing.
