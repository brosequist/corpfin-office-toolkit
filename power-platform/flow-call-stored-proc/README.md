# Flow: call a SQL stored procedure from a canvas app

A small Power Automate flow that exposes a SQL Server stored procedure to a canvas Power App. The app calls the flow with `{{FLOW_NAME}}.Run()`, gets back a typed array of records, and uses it to populate a gallery or drop-down.

This is a **template** — almost all real-world canvas-app-to-database integrations end up looking like this.

## When to use it

- Your data already lives in SQL and putting it on SharePoint isn't an option (compliance, volume, joins, security).
- You want server-side logic — joins, computed columns, row-level filtering — to run once on the database, not per-row in the canvas app.
- You want to keep the SQL connection inside Power Automate so the canvas app users don't need direct SQL access.

## Recipe

**Trigger:** *PowerApps (V2)* — manual / called from a canvas app. No input parameters in the example below; add input fields to the trigger if your stored proc takes arguments.

**Actions:**

1. **Execute stored procedure (V2)** — SQL Server connector.
   - Server: `default` (uses the connection's configured server) or an explicit server name.
   - Database: `default` or an explicit database name.
   - Procedure: `[dbo].[{{STORED_PROC_NAME}}]`
   - Parameters: pass through any trigger inputs.
2. **Response** — HTTP response back to the calling app:
   - Status code: `200`
   - Body: `@body('Execute_stored_procedure_(V2)')['ResultSets']['Table1']`
   - Schema: define the columns explicitly so the canvas app gets typed properties on the response. Example for a "folder listing" stored proc:
     ```json
     {
       "type": "array",
       "items": {
         "type": "object",
         "properties": {
           "FolderID":     { "type": "integer" },
           "Mth":          { "type": "integer" },
           "Yr":           { "type": "integer" },
           "TeamID":       { "type": "integer" },
           "FullPath":     { "type": "string"  },
           "CreatedBy":    { "type": "string"  },
           "CreateDate":   { "type": "string"  },
           "Comments":     { "type": "string"  }
         }
       }
     }
     ```

## Calling it from the canvas app

```text
// On the screen's OnVisible (or behind a refresh button):
ClearCollect(colFolders, {{FLOW_NAME}}.Run());

// Bind a gallery to colFolders
Items = colFolders
```

Because the flow's response schema is declared, autocomplete in Power Apps will surface `ThisItem.FolderID`, `ThisItem.FullPath` etc. as if they were native columns.

## Notes

- The connector authenticates as whoever published the flow, not as the calling user. If you need user-context security, filter on `User().Email` *inside* the stored proc using a parameter passed from the trigger.
- For long-running procs, consider an **HTTP** trigger instead and have the canvas app poll a "job status" table — Power Apps will time out long synchronous flows.
- For very chatty queries, move the data to Dataverse or a dedicated SQL view; calling stored procs per gallery refresh adds up under heavy use.

## What you swap for your org

- The SQL connector — point it at your server / database / authentication
- The stored procedure name
- The response schema to match your stored proc's columns
- Trigger input parameters if your proc takes arguments
