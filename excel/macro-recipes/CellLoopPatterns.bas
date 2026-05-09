Attribute VB_Name = "CellLoopPatterns"
Option Explicit

' Range-based "walk a column" patterns. None of these touch ActiveCell
' or .Select, so they compose cleanly inside other subs. Each loop is
' bounded by the worksheet's last row, so they can't run away on an
' empty (or fully-populated) column.

' Returns the first non-empty cell at or below StartCell, or Nothing
' if every cell from StartCell down to the bottom of the sheet is empty.
Public Function FirstNonEmptyBelow(StartCell As Range) As Range
    Dim Cursor As Range
    Set Cursor = StartCell.Cells(1, 1)

    Dim lastRow As Long
    lastRow = Cursor.Worksheet.Rows.Count

    Do While IsEmpty(Cursor.Value)
        If Cursor.Row >= lastRow Then
            Set FirstNonEmptyBelow = Nothing
            Exit Function
        End If
        Set Cursor = Cursor.Offset(1, 0)
    Loop

    Set FirstNonEmptyBelow = Cursor
End Function

' Returns the last cell of a contiguous non-empty run starting at
' StartCell. Returns Nothing if StartCell itself is empty.
Public Function LastNonEmptyBelow(StartCell As Range) As Range
    Dim Cursor As Range
    Set Cursor = StartCell.Cells(1, 1)

    If IsEmpty(Cursor.Value) Then
        Set LastNonEmptyBelow = Nothing
        Exit Function
    End If

    Dim lastRow As Long
    lastRow = Cursor.Worksheet.Rows.Count

    Do While Not IsEmpty(Cursor.Offset(1, 0).Value)
        If Cursor.Row + 1 >= lastRow Then Exit Do
        Set Cursor = Cursor.Offset(1, 0)
    Loop

    Set LastNonEmptyBelow = Cursor
End Function

' Walk the column starting at StartCell, doing per-row work on each
' non-empty cell. Stops at the first empty cell or at the bottom of
' the worksheet.
Public Sub WalkColumnUntilEmpty(StartCell As Range)
    Dim Cursor As Range
    Set Cursor = StartCell.Cells(1, 1)

    Dim lastRow As Long
    lastRow = Cursor.Worksheet.Rows.Count

    Do While Not IsEmpty(Cursor.Value)
        ' ENTER PER-ROW WORK HERE — e.g. Cursor.Offset(0, 1).Value = ...
        If Cursor.Row >= lastRow Then Exit Do
        Set Cursor = Cursor.Offset(1, 0)
    Loop
End Sub
