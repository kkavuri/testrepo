Set fso 		= CreateObject("Scripting.FileSystemObject")
sFilePath 		= "C:\Users\Administrator\Desktop"
outputLogFile 	= "C:\Users\Administrator\Desktop\TAPAPIMonitorLog.txt"
Set objShell 	= CreateObject("WScript.Shell")
set fileObj 	= fso.CreateTextFile("C:\Users\Administrator\Desktop\sample.bat",True)
set logFilePtr 	= fso.OpenTextFile(sFilePath&"\TAPAPIMonitorLog1.txt",2,True)

'Func_createEnVariable()
Func_VerifyJava()
Func_CreateBatFile()
Func_CheckIfAPIEngineExists()

intCounter1 = iGetProcessesCnt("cmd")

objShell.run "cmd.exe /k C:\Users\Administrator\Desktop\sample.bat"
Wscript.Sleep 3000

Function Func_CreateBatFile()

	fileObj.WriteLine "cd\"
	fileObj.WriteLine "cd Program Files (x86)"
	fileObj.WriteLine "cd ApiEngine"	
	fileObj.WriteLine "java -cp api.jar com.hpe.api.execute <<mainscript>> <<BuildIDValue>>"
	fileobj.WriteLine "exit"
End Function 

'find Java 7 from registry
Function Func_VerifyJava()
logFilePtr.WriteLine "Function Verify Java Availability and version Execution Started at "&now
	logFilePtr.WriteLine objShell.RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\" &"JavaSoft\Java Runtime Environment\1.8\JavaHome")

	'check file version of java.exe
	javaHome = objShell.Environment.item("JAVA_HOME")

	logFilePtr.WriteLine fso.GetFileVersion(javaHome & "\bin\java.exe")
	logFilePtr.WriteLine "Function Verify Java Availability and version Execution Completed at "&now
End Function

Function Func_CheckIfAPIEngineExists()
logFilePtr.WriteLine "Function API Engine Check Execution Started at "&now
'Set FSO 1= CreateObject("Scripting.FileSystemObject")
boolRC = FSO.FileExists("C:\Program Files (x86)\APIEngine\api.jar")
'Set FSO = Nothing
If Not boolRC Then

logFilePtr.WriteLine("API Engine is not available in the provided path.")

else

logFilePtr.WriteLine("API Engine exists.")

End If
logFilePtr.WriteLine "Function API Engine Check Execution Completed at "&now
End Function
Function IsFileExist(sFilePath)
	
	If fso.FileExists(sFilePath) Then
		IsFileExist = True
	Else
		IsFileExist = False
	End If
	
End Function

Function iGetProcessesCnt(strReqProcessName)
	strComputer = "."
	Set objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2") 
	Set colProcess = objWMIService.ExecQuery("Select * from Win32_Process")
	For Each objProcess in colProcess		
		strList = strList&objProcess.Name
	Next
	If InStr(strList,strReqProcessName) > 0 Then
		cnt = (Len(strList)-Len(Replace(strList,strReqProcessName,"")))/Len(strReqProcessName)		
	End If
	iGetProcessesCnt = cnt
End Function

Function Func_createEnVariable()

strVarName 	= "BUILD_ID"
strVarValue = "<<BuildIDValue>>"

Set objVarClass 	 = GetObject( "winmgmts://./root/cimv2:Win32_Environment" )
Set objVar      	 = objVarClass.SpawnInstance_
objVar.Name          = strVarName
objVar.VariableValue = strVarValue
objVar.UserName      = "<SYSTEM>"
objVar.Put_
End Function

''''''''''''''''''''''''
intCounter2 = iGetProcessesCnt("cmd")
logFilePtr.WriteLine "API Script Execution Started " & now
'MsgBox intCounter2
While intCounter2 > intCounter1
	
	intCounter2 = iGetProcessesCnt("cmd")

Wend
While Not IsFileExist(outputLogFile)

Wend

If IsFileExist(outputLogFile)Then
		set fileReaderObj = fso.OpenTextFile(outputLogFile,1)
		While Not fileReaderObj.AtEndOfStream
			logFilePtr.WriteLine fileReaderObj.ReadLine
		Wend
		set fileReaderObj = Nothing
Else


	logFilePtr.WriteLine outputLogFile&" file is not available "&now
End If
logFilePtr.WriteLine  "API Script Execution Completed Successfully "&now

logFilePtr.close

set logFilePtr = Nothing
set objShell = NOThing
set fileObj = Nothing
set fso = Nothing
'****************************


