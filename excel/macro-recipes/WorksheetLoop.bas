Attribute VB_Name = "WorksheetLoop"
Option Explicit

' Iterates from StartingWorksheet through every subsequent worksheet in
' the same workbook. Replace the comment with whatever per-sheet work
' you need.
'
' Implementation note: locate StartingWorksheet by identity (Is) inside
' the Worksheets collection rather than by Worksheet.Index. .Index
' returns position in the parent's Sheets collection, which includes
' chart sheets, so indexing into Worksheets(i) breaks for any workbook
' that has chart sheets interleaved with worksheets.
Public Sub LoopFromWorksheet(StartingWorksheet As Worksheet)
    Dim wb As Workbook
    Set wb = StartingWorksheet.Parent

    Dim startIdx As Long
    startIdx = 0

    Dim i As Long
    For i = 1 To wb.Worksheets.Count
        If wb.Worksheets(i) Is StartingWorksheet Then
            startIdx = i
            Exit For
        End If
    Next i
    If startIdx = 0 Then Exit Sub

    Dim sheet As Worksheet
    For i = startIdx To wb.Worksheets.Count
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
