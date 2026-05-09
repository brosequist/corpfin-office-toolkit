Attribute VB_Name = "ResetWorksheet"
Option Explicit

' Three patterns for clearing a worksheet's contents.

' Clear everything on the active sheet, then write a fixed header row.
' Edit the header strings inline if you want a different schema.
Public Sub ResetActiveSheetStaticHeaders()
    With ActiveSheet
        .Cells.ClearContents
        .Range("A1").Value = "Column Name 1"
        .Range("B1").Value = "Column Name 2"
        .Range("C1").Value = "Column Name 3"
        .Range("D1").Value = "Column Name 4"
    End With
End Sub

' Clear the active sheet, then write a header row from the supplied array.
'   Dim cols() As String
'   ReDim cols(0 To 2)
'   cols(0) = "Cost Center" : cols(1) = "Account" : cols(2) = "Amount"
'   ResetActiveSheetDynamicHeaders cols
Public Sub ResetActiveSheetDynamicHeaders(HeaderValues() As String)
    Dim sheet As Worksheet
    Set sheet = ActiveSheet
    sheet.Cells.ClearContents

    Dim i As Long
    For i = LBound(HeaderValues) To UBound(HeaderValues)
        sheet.Cells(1, i - LBound(HeaderValues) + 1).Value = HeaderValues(i)
    Next i
End Sub

' Clear the contiguous block starting at StartCell. Stops at the first
' fully-empty column to the right and the first fully-empty row below
' (CurrentRegion semantics).
Public Sub ClearContiguousBlock(StartCell As Range)
    StartCell.Cells(1, 1).CurrentRegion.ClearContents
End Sub
