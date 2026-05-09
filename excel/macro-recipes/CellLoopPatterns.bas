Attribute VB_Name = "CellLoopPatterns"
Option Explicit

' Range-based "walk a column" patterns. None of these touch ActiveCell
' or .Select, so they compose cleanly inside other subs.

' Returns the address of the first non-empty cell at or below StartCell.
' Useful for "find the first row of a table" given a column anchor.
Public Function FirstNonEmptyBelow(StartCell As Range) As Range
    Dim Cursor As Range
    Set Cursor = StartCell.Cells(1, 1)
    Do While IsEmpty(Cursor.Value)
        Set Cursor = Cursor.Offset(1, 0)
    Loop
    Set FirstNonEmptyBelow = Cursor
End Function

' Returns the last cell of a contiguous non-empty run starting at StartCell.
' Useful for "where does this column of data end?".
Public Function LastNonEmptyBelow(StartCell As Range) As Range
    Dim Cursor As Range
    Set Cursor = StartCell.Cells(1, 1)
    If IsEmpty(Cursor.Value) Then
        Set LastNonEmptyBelow = Nothing
        Exit Function
    End If
    Do While Not IsEmpty(Cursor.Offset(1, 0).Value)
        Set Cursor = Cursor.Offset(1, 0)
    Loop
    Set LastNonEmptyBelow = Cursor
End Function

' Walk the column starting at StartCell, calling Action() on each non-empty
' cell. Stops at the first empty cell. Replace the comment with whatever
' work you actually need to do per row.
Public Sub WalkColumnUntilEmpty(StartCell As Range)
    Dim Cursor As Range
    Set Cursor = StartCell.Cells(1, 1)
    Do While Not IsEmpty(Cursor.Value)
        ' ENTER PER-ROW WORK HERE — e.g. Cursor.Offset(0, 1).Value = ...
        Set Cursor = Cursor.Offset(1, 0)
    Loop
End Sub
