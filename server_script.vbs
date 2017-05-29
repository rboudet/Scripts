strSearchFor = "SVC_*"
' strExclude = "server1,OU=Computers"


Dim rootDSE, domainObject
Set rootDSE = GetObject("LDAP://RootDSE")
domainContainer = rootDSE.Get("defaultNamingContext")
Set domainObject = GetObject("LDAP://" & domainContainer)

Set fs = CreateObject ("Scripting.FileSystemObject")
Set resFile = fs.CreateTextFile (".\Results.csv")

resFile.WriteLine "Computer,Service Type,Name,State,Run As"

arrSearchFor = Split(strSearchFor, ",")
arrExclude = Split(strExclude, ",")

Dim arrTextLine(9)
const crlf="<BR>"
Set objExplorer = WScript.CreateObject("InternetExplorer.Application")
objExplorer.Navigate "about:blank"   
objExplorer.ToolBar = 0
objExplorer.StatusBar = 0
objExplorer.Width = 400
objExplorer.Height = 300 
objExplorer.Left = 100
objExplorer.Top = 100

Do While (objExplorer.Busy)
         Wscript.Sleep 200
Loop

objExplorer.Visible = 1    


scanComputers(domainObject)
strNull = MsgBox("Scan completed, check the results.csv file in this directory for the output of this script",vbOK,"Scan Completed")
Wscript.Quit


Sub scanComputers(oObject)
         Dim oComputer
         For Each oComputer in oObject
                 Select Case oComputer.Class
                          Case "computer"
                                   bFound = False
                                   For x = 0 to UBound(arrExclude)
                                            wscript.echo oComputer.distinguishedName & ":" & arrExclude(x)
                                            If InStr(UCase(oComputer.distinguishedName), Trim(UCase(arrExclude(x)))) > 0 Then 
                                                    bFound = True
                                            End If
                                   Next
                                   
                                   If bFound = False Then
                                            bPing = Ping(oComputer.cn)
                                            If bPing = True Then
                                                    scanTasks(oComputer.cn)
                                                    scanServices(oComputer.cn)
                                            End If
                                   End If
                          Case "organizationalUnit" , "container"
                                   scanComputers(oComputer)
                 End select
         Next
End Sub


Sub scanTasks(strComputer)
         progressText strComputer,"Scanning Scheduled Tasks for"
         Set oShell = CreateObject("WScript.Shell")
         strPath = fs.GetParentFolderName(wscript.ScriptFullName)
         strReturn = oShell.Run("cmd /c schtasks.exe /Query /S " & strComputer & " /v /fo csv > " & strPath & "\task.txt", 2, true)
         Set oShell = Nothing
         
         If Not fs.FileExists(".\task.txt") Then
                 Exit Sub
         End If
         
         Set getFile = fs.OpenTextFile(".\task.txt")
         If getFile.AtEndOfStream Then
                 Exit Sub
         End If
         
         strLine = getFile.ReadLine
         If strLine = "" or IsNull(strLine) then 
                 strLine = getFile.ReadLine
         End If
         If Left(strLine, 1) = chr(34) Then
                 Do Until getFile.AtEndOfStream
                          strLine = getFile.ReadLine
                          arrLine = Split(strLine, chr(34) & "," & chr(34))
                          
                          strAs =  arrLine(18)
                          bFound = False
                          For x = 0 to UBound(arrSearchFor)
                                   If InStr(UCase(strAs), Trim(UCase(arrSearchFor(x)))) > 0 Then
                                            bFound = True
                                   End If
                          Next
                          
                          If bFound = True Then
                                   strName =        arrLine(1)
                                   strTask =        arrLine(8)
                                   strState =       arrLine(11)
                                            
                                   resFile.WriteLine strComputer & ",Scheduled Task," & strName & "," & strState & "," & strAs
                          End If
                 Loop
         End If
End Sub


Sub scanServices(strComputer)
         progressText strComputer,"Scanning Services for"
         On Error Resume Next
         Err.Clear
         Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
         If Err.Number <> 0 Then
                 'wscript.echo Err.Number
                 Exit Sub
         End If
         Set colListOfServices = objWMIService.ExecQuery("Select * from Win32_Service")
         If Err.Number <> 0 Then
                 'wscript.echo Err.Number
                 Exit Sub
         End If

         For Each objService in colListOfServices
                 bFound = False
                 For x = 0 to UBound(arrSearchFor)
                          If InStr(UCase(objService.StartName), Trim(Ucase(arrSearchFor(x)))) > 0 Then
                                   bFound = True
                          End If
                 Next
                 
                 If bFound = True Then
                          If objService.Started = True Then
                                   strState = "Started"
                          Else
                                   strState = "Not Running"
                          End If
                          
                          strState = objService.StartMode & "/" & strState
                          resFile.WriteLine strComputer & ",Service," & objService.DisplayName & "," & strState & "," & objService.StartName
                 End If
   Next

   Set objWMIService = Nothing
End Sub


Function Ping(strHost)
   Dim objPing, objRetStatus
   progressText strHost, "Pinging"

   Set objPing = GetObject("winmgmts:{impersonationLevel=impersonate}").ExecQuery("select * from Win32_PingStatus where address = '" & strHost & "' AND ResolveAddressNames = TRUE")

   For Each objRetStatus in objPing
      If IsNull(objRetStatus.StatusCode) or objRetStatus.StatusCode <> 0 then 
         Ping = False
      Else
         Ping = True
      End if
   Next
End Function


Sub progressText(strComputer, strTask)
         intTop = UBound(arrTextLine)
         For z = 0 to intTop - 1
                 arrTextLine(z) = arrTextLine(z + 1)
         Next
         arrTextLine(intTop) = Trim(strTask) & " " & strComputer & "..."

         For z = 0 to intTop
                 strText = strText & "<BR>" & arrTextLine(z)
         Next
         
         objExplorer.Document.Body.InnerHTML = strText
End Sub
