Attribute VB_Name = "R1C1Formulas"
Option Explicit

' Examples of the FormulaR1C1 property. R1C1 references work two ways:
'   - Absolute: R1C1 means "row 1, column 1" (the same as $A$1).
'   - Relative: R[0]C[-1] means "same row, one column to the left" of
'     the cell containing the formula. Relative offsets go in brackets.
' R1C1 is preferred over A1 when writing macros that drop formulas into
' many cells: the same FormulaR1C1 string works regardless of which cell
' it's written to.

' Set TargetCell to the value of A1 (absolute reference).
Public Sub WriteAbsoluteReference(TargetCell As Range)
    TargetCell.FormulaR1C1 = "=R1C1"
End Sub

' Set TargetCell to the value of the cell immediately to its left.
Public Sub WriteLeftNeighbourReference(TargetCell As Range)
    TargetCell.FormulaR1C1 = "=R[0]C[-1]"
End Sub

' Mixed reference: TargetCell becomes
'   (cell to the left) / (column B value in the same row)
' Useful for "% of B" style ratios.
'
' Caveats with this specific formula:
'   - If TargetCell is in column A, R[0]C[-1] points one column left of
'     column A, which doesn't exist; the formula evaluates to #REF!.
'   - If TargetCell is in column B, the R[0]C2 reference points back at
'     TargetCell itself, creating a circular reference. Move the target
'     to column C or further right.
Public Sub WritePercentOfColumnB(TargetCell As Range)
    TargetCell.FormulaR1C1 = "=R[0]C[-1]/R[0]C2"
End Sub
