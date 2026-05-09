# Essbase / SmartView Connection Lifecycle

Thin VBA wrappers around Oracle SmartView's `Hyp*` functions that codify the standard "create a connection → attach a worksheet → refresh / zoom → disconnect → clean up" lifecycle.

## Audience

Use this if you're automating Excel workbooks that pull from an Oracle Hyperion / Essbase OLAP cube via the SmartView add-in. SmartView is enterprise BI software — the audience is narrow, but if you have it installed you're probably staring at it daily.

If you've never heard of Essbase or SmartView, you don't need this recipe.

## Prerequisites

- Microsoft Excel (Windows).
- Oracle SmartView for Office add-in installed. Once SmartView is loaded, all `Hyp*` functions are exposed automatically — no extra VBA reference needed.
- A SmartView-compatible provider URL (Essbase, Planning, FCCS, etc.) and credentials.

## Module

| File | Purpose |
|---|---|
| [`EssbaseConnection.bas`](EssbaseConnection.bas) | The lifecycle wrappers. Each public function returns `0` on success and a non-zero step indicator on failure, so callers can centralise their error handling. |

## Typical use

```vba
Sub PullCurrentMonthActuals()
    Dim rc As Long
    rc = CreateAndAttachConnection( _
        WorksheetName:="Actuals", _
        EssbaseUsername:="alice", _
        EssbasePassword:="********", _
        ProviderName:="Essbase", _
        ProviderURL:="https://essbase.contoso.com/aps/SmartView", _
        ServerName:="EssbaseSrv01", _
        ApplicationName:="Finance", _
        DatabaseName:="Actuals", _
        ConnectionName:="FinanceActuals", _
        ConnectionDescription:="Monthly close pull" _
    )
    If rc <> 0 Then
        MsgBox "Connection setup failed at step " & rc
        Exit Sub
    End If

    rc = RefreshSheet()
    If rc <> 0 Then MsgBox "Refresh failed"

    ' ... do whatever you need, then ...

    rc = TeardownConnection("Actuals", "FinanceActuals")
End Sub
```

## Notes

- `HypCreateConnection` registers the named connection in the user's SmartView client; `HypRemoveConnection` (called from `TeardownConnection`) cleans it up so you don't leave stale connections behind.
- `HypUIConnect` will *prompt* the user for credentials if you pass empty username / password — useful for shared workbooks where each user authenticates as themselves.
- `HypMenuVRefresh` refreshes whichever sheet is currently active; if you need to refresh a specific sheet, `Worksheets("Foo").Activate` it first or use the more granular `HypRetrieve` from the SmartView API.
- Reference docs:
  - [HypCreateConnection](https://docs.oracle.com/cd/E87655_01/SVDEV/hypcreateconnection.htm)
  - [HypUIConnect](https://docs.oracle.com/cd/E87655_01/SVDEV/hypuiconnect.htm)
  - [HypMenuVRefresh](https://docs.oracle.com/cd/E57185_01/SMVDG/ch03s26.html)
  - [HypZoomIn](https://docs.oracle.com/cd/E87655_01/SVDEV/hypzoomin.htm)
  - [HypDisconnect](https://docs.oracle.com/cd/E87655_01/SVDEV/hypdisconnect.htm)
  - [HypRemoveConnection](https://docs.oracle.com/cd/E87655_01/SVDEV/hypremoveconnection.htm)

## Caveats

- Hardcoded credentials in a workbook are a non-starter for any production use — keep `EssbasePassword` empty and let `HypUIConnect` prompt, or read it from a per-user store.
- `HypZoomIn` / `HypZoomOut` operate on whatever range you pass; they don't know about your sheet's structure. If your zoom target moves between refreshes (a common problem with dynamic ad-hoc grids), find the anchor by data, not by absolute address.
