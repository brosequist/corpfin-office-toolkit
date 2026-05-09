Attribute VB_Name = "FormattingPatterns"
Option Explicit

' Common cell/row/column formatting patterns, all driven from a passed
' Range so they don't depend on the user's current selection.

Public Sub FormatColumnAsCurrency(AnyCellInColumn As Range)
    AnyCellInColumn.EntireColumn.Style = "Currency"
End Sub

Public Sub FormatColumnAsPercent(AnyCellInColumn As Range)
    AnyCellInColumn.EntireColumn.Style = "Percent"
End Sub

Public Sub FormatColumnAsComma(AnyCellInColumn As Range)
    AnyCellInColumn.EntireColumn.Style = "Comma"
End Sub

' Highlights the entire row containing AnyCellInRow with a yellow fill
' and red, bold, italic font. The TintAndShade properties default to 0
' and ARE 'TintAndShade' (not 'TintAndShare', a common typo).
Public Sub HighlightRowYellow(AnyCellInRow As Range)
    With AnyCellInRow.EntireRow.Interior
        .Pattern = xlSolid
        .PatternColorIndex = xlAutomatic
        .Color = RGB(255, 255, 0)
        .TintAndShade = 0
        .PatternTintAndShade = 0
    End With

    With AnyCellInRow.EntireRow.Font
        .Color = RGB(255, 0, 0)
        .TintAndShade = 0
        .Bold = True
        .Italic = True
    End With
End Sub
