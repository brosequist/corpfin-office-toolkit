Attribute VB_Name = "WorksheetLoop"
Option Explicit

' Iterates from StartingWorksheet through every subsequent worksheet in
' the same workbook. Replace the comment with whatever per-sheet work
' you need.
Public Sub LoopFromWorksheet(StartingWorksheet As Worksheet)
    Dim wb As Workbook
    Set wb = StartingWorksheet.Parent

    Dim i As Long
    For i = StartingWorksheet.Index To wb.Worksheets.Count
        Dim sheet As Worksheet
        Set sheet = wb.Worksheets(i)

        ' ENTER PER-SHEET WORK HERE — sheet.Range(...) etc.
        ' Avoid Activate/Select; operate directly on `sheet`.
    Next i
End Sub

' Variant: loop through every worksheet in the workbook unconditionally.
Public Sub LoopAllWorksheets(wb As Workbook)
    Dim sheet As Worksheet
    For Each sheet In wb.Worksheets
        ' ENTER PER-SHEET WORK HERE
    Next sheet
End Sub
