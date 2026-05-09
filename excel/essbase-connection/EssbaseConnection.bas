Attribute VB_Name = "EssbaseConnection"
Option Explicit

' Wrappers around the Oracle SmartView Hyp* VBA functions that handle
' the standard "create a connection, refresh a sheet, drill in/out,
' disconnect, clean up" lifecycle.
'
' Requires the SmartView add-in installed and registered. The Hyp*
' functions live in HsAddin and are exposed once SmartView is loaded;
' you do NOT need to add an explicit reference to make them callable.
'
' Reference docs (these links survive Oracle's reorganisations as of
' early 2026):
'   HypCreateConnection    https://docs.oracle.com/cd/E87655_01/SVDEV/hypcreateconnection.htm
'   HypUIConnect           https://docs.oracle.com/cd/E87655_01/SVDEV/hypuiconnect.htm
'   HypMenuVRefresh        https://docs.oracle.com/cd/E57185_01/SMVDG/ch03s26.html
'   HypZoomIn / HypZoomOut https://docs.oracle.com/cd/E87655_01/SVDEV/hypzoomin.htm
'   HypDisconnect          https://docs.oracle.com/cd/E87655_01/SVDEV/hypdisconnect.htm
'   HypRemoveConnection    https://docs.oracle.com/cd/E87655_01/SVDEV/hypremoveconnection.htm

' Create a reusable named connection, then attach the supplied
' worksheet to it. After this returns 0, call RefreshSheet() (defined
' below) to pull live data.
'
' Returns 0 on full success; otherwise a non-zero step indicator:
'   1 - HypCreateConnection failed
'   2 - HypUIConnect failed
' The underlying Hyp* return code is not surfaced; if you need it,
' inline the calls instead of using this wrapper.
Public Function CreateAndAttachConnection( _
    WorksheetName As String, _
    EssbaseUsername As String, _
    EssbasePassword As String, _
    ProviderName As String, _
    ProviderURL As String, _
    ServerName As String, _
    ApplicationName As String, _
    DatabaseName As String, _
    ConnectionName As String, _
    ConnectionDescription As String _
) As Long
    Dim rc As Long

    rc = HypCreateConnection( _
        Empty, _
        EssbaseUsername, EssbasePassword, _
        ProviderName, ProviderURL, _
        ServerName, ApplicationName, DatabaseName, _
        ConnectionName, ConnectionDescription _
    )
    If rc <> 0 Then
        CreateAndAttachConnection = 1
        Exit Function
    End If

    rc = HypUIConnect(WorksheetName, EssbaseUsername, EssbasePassword, ConnectionName)
    If rc <> 0 Then
        CreateAndAttachConnection = 2
        Exit Function
    End If

    CreateAndAttachConnection = 0
End Function

' Refresh the sheet with current cube values. Wrapper exists so callers
' can centralise their error handling.
Public Function RefreshSheet() As Long
    RefreshSheet = HypMenuVRefresh()
End Function

' Drill the supplied range one level deeper. Level 0 = "next level".
Public Function ZoomInOneLevel(WorksheetName As String, CellRange As Range) As Long
    ZoomInOneLevel = HypZoomIn(WorksheetName, CellRange, 0, Empty)
End Function

' Retract the supplied range up one level (toward the parent member).
Public Function ZoomOutOneLevel(WorksheetName As String, CellRange As Range) As Long
    ZoomOutOneLevel = HypZoomOut(WorksheetName, CellRange)
End Function

' Cleanly tear down a connection: disconnect the worksheet, then drop
' the named connection. Pass LogoffServer:=True to fully sign out of
' the provider (the second arg to HypDisconnect).
Public Function TeardownConnection( _
    WorksheetName As String, _
    ConnectionName As String, _
    Optional LogoffServer As Boolean = True _
) As Long
    Dim rc As Long

    rc = HypDisconnect(WorksheetName, LogoffServer)
    If rc <> 0 Then
        TeardownConnection = 1
        Exit Function
    End If

    rc = HypRemoveConnection(ConnectionName)
    If rc <> 0 Then
        TeardownConnection = 2
        Exit Function
    End If

    TeardownConnection = 0
End Function
