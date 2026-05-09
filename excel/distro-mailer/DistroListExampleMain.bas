Attribute VB_Name = "DistroListExampleMain"
Option Explicit

' Demo entry point. Reads the email list starting at the active cell,
' then sends the active workbook to those recipients.
Public Sub DistroListExampleMain()

    Dim Recipients() As String
    Recipients = StoreVerticalListToArray(ActiveCell)

    If Len(Join(Recipients)) = 0 Then
        MsgBox "No values found in the column starting at " & ActiveCell.Address
        Exit Sub
    End If

    Const DefaultSubject As String = "Please see the attached workbook"
    SendToDistributionList Recipients, DefaultSubject
End Sub
