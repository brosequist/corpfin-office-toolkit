Attribute VB_Name = "MonthColumns"
Option Explicit

Private Const MONTH_ABBREVS As String = "Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec"

' Writes 3-character month abbreviations from January through CutoffMonth
' starting at StartCell, one per column. CutoffMonth is the full month
' name (e.g. "March"). Errors if CutoffMonth isn't a recognised month.
Public Sub WriteMonthColumns(StartCell As Range, CutoffMonth As String)
    Dim months() As String
    months = Split(MONTH_ABBREVS, ",")

    Dim cutoffIndex As Long
    cutoffIndex = MonthIndex(CutoffMonth)
    If cutoffIndex < 0 Then
        Err.Raise vbObjectError + 513, "WriteMonthColumns", _
            "Unknown month: " & CutoffMonth
    End If

    Dim i As Long
    For i = 0 To cutoffIndex
        StartCell.Offset(0, i).Value = months(i)
    Next i
End Sub

' Two-row YTD header: row 1 holds the year string and row 2 holds the
' three-character month. Spans last December of PreviousYear through
' CutoffMonth of CurrentYear.
'
' PreviousYear / CurrentYear are passed as strings so the caller can
' choose to prefix them with a leading apostrophe (e.g. "'2024") to
' force Essbase to treat the value as a dimension member rather than
' a number.
Public Sub WriteYTDHeader( _
    StartCell As Range, _
    PreviousYear As String, _
    CurrentYear As String, _
    CutoffMonth As String _
)
    Dim months() As String
    months = Split(MONTH_ABBREVS, ",")

    Dim cutoffIndex As Long
    cutoffIndex = MonthIndex(CutoffMonth)
    If cutoffIndex < 0 Then
        Err.Raise vbObjectError + 513, "WriteYTDHeader", _
            "Unknown month: " & CutoffMonth
    End If

    ' Column 0: prior-year December
    StartCell.Offset(0, 0).Value = PreviousYear
    StartCell.Offset(1, 0).Value = "Dec"

    ' Columns 1..n: current year, Jan through cutoff
    Dim i As Long
    For i = 0 To cutoffIndex
        StartCell.Offset(0, i + 1).Value = CurrentYear
        StartCell.Offset(1, i + 1).Value = months(i)
    Next i
End Sub

Private Function MonthIndex(MonthName As String) As Long
    Dim names As Variant
    names = Array( _
        "January", "February", "March", "April", "May", "June", _
        "July", "August", "September", "October", "November", "December" _
    )
    Dim i As Long
    For i = 0 To 11
        If StrComp(MonthName, CStr(names(i)), vbTextCompare) = 0 Then
            MonthIndex = i
            Exit Function
        End If
    Next i
    MonthIndex = -1
End Function
