Attribute VB_Name = "VerticalListToArray"
Option Explicit

' Reads a contiguous vertical list of strings starting at StartCell and
' returns them as a String array. Stops at the first empty cell.
'
' Returns a zero-length allocated array if the first cell is empty, so
' callers can safely Join / LBound / UBound the result without an
' "uninitialised array" runtime error.
Public Function StoreVerticalListToArray(StartCell As Range) As String()

    Dim Cursor As Range
    Set Cursor = StartCell.Cells(1, 1)

    If Len(CStr(Cursor.Value)) = 0 Then
        StoreVerticalListToArray = Split(vbNullString)
        Exit Function
    End If

    Dim RowCount As Long
    RowCount = 0
    Do While Len(CStr(Cursor.Offset(RowCount, 0).Value)) > 0
        RowCount = RowCount + 1
    Loop

    Dim Result() As String
    ReDim Result(RowCount - 1)

    Dim i As Long
    For i = 0 To RowCount - 1
        Result(i) = CStr(Cursor.Offset(i, 0).Value)
    Next i

    StoreVerticalListToArray = Result
End Function
