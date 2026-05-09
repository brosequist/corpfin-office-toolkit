Attribute VB_Name = "ArrayToDistributionList"
Option Explicit

' Sends the active workbook to every address in EmailList using the
' workbook's SendMail method.
'
' NOTE: ActiveWorkbook.SendMail uses the legacy MAPI client. On modern
' M365/Outlook installs it often surfaces a security prompt or fails
' silently when no MAPI provider is registered. For production-grade
' delivery prefer Outlook automation
' (CreateObject("Outlook.Application")) or an SMTP library.
Public Sub SendToDistributionList(EmailList() As String, EmailSubject As String)
    ActiveWorkbook.SendMail Recipients:=EmailList, Subject:=EmailSubject
End Sub
