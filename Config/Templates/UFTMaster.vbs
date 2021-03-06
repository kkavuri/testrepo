Const HKLM = &H80000002 'HKEY_LOCAL_MACHINE  
strComputer = "." 
strKey = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" 
strEntry1a = "DisplayName" 
strEntry1b = "QuietDisplayName" 
strEntry2 = "InstallDate" 
strEntry3 = "VersionMajor" 
strEntry4 = "VersionMinor" 
strEntry5 = "EstimatedSize" 
Set objReg = GetObject("winmgmts://" & strComputer &"/root/default:StdRegProv") 
objReg.EnumKey HKLM, strKey, arrSubkeys 
'WScript.Echo "Installed Applications" & VbCrLf 
scriptdir = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)
'msgbox scriptdir
'sObjRepoFile = Environment.Value("TestDir")
'msgbox sObjRepoFile

'Set oFso = CreateObject("Scripting.FileSystemObject")
''Environment.Value("RelativePath")=oFso.GetParentFolderName(oFso.GetParentFolderName( sObjRepoFile ))
'scriptpath = Environment.Value("RelativePath")
'msgbox scriptpath

'Path = scriptpath & "\" 
Path = scriptdir & "\" 
'msgbox Path

For Each strSubkey In arrSubkeys 
  intRet1 = objReg.GetStringValue(HKLM, strKey & strSubkey,strEntry1a, strValue1) 
  If intRet1 <> 0 Then 
    objReg.GetStringValue HKLM, strKey & strSubkey, _ 
     strEntry1b, strValue1 
  End If 
  'If strValue1 <> "" And InStr(LCase(strValue1),"hp unified") > 0 Then 
   ' WScript.Echo strValue1&" is installed"
  'End If 
  If strValue1 <> "" Then 
   'msgbox strValue1&" is installed"
  End If
  objReg.GetStringValue HKLM, strKey & strSubkey,strEntry2, strValue2 
  'If strValue2 <> "" Then 
    'WScript.Echo "Install Date: " & strValue2 
  'End If 
  'objReg.GetDWORDValue HKLM, strKey & strSubkey, _ 
   'strEntry3, intValue3 
  'objReg.GetDWORDValue HKLM, strKey & strSubkey, _ 
   'strEntry4, intValue4 
  'If intValue3 <> "" Then 
    ' WScript.Echo "Version: " & intValue3 & "." & intValue4 
  'End If 
  'objReg.GetDWORDValue HKLM, strKey & strSubkey, _ 
   'strEntry5, intValue5 
  'If intValue5 <> "" Then 
    'WScript.Echo "Estimated Size: " & Round(intValue5/1024, 3) & " megabytes" 
  'End If 
Next
'Wscript.quit
Function ReadXMLFileData(sFilePath,sTagName)
	If isFileExist(sFilePath) Then
		Set xmlDoc = CreateObject("Microsoft.XMLDOM")
      		xmlDoc.Async = "False"
      		xmlDoc.Load(sFilePath)
	      Set colNodes=xmlDoc.selectNodes(sTagName)
	     ' Print "Total no.of values are : # "&colNodes.Length
	      cnt = 0
	      For Each objNode in colNodes
		      cnt = cnt + 1
		      'Print cnt&" "&objNode.Text 
		      ReadXMLFileData = objNode.Text 
	      Next
	      cnt = ""
	      Set colNodes = Nothing
	      Set xmlDoc = Nothing
	Else
		shlObjPopup sFilePath&" was not found , please verify the path",3,"File Not found :",64
	End If 
End Function

Function isFileExist(sFilePath)
    isFileExist = False
    Set fso = CreateObject("Scripting.FileSystemObject")
        If fso.FileExists(sFilePath) Then
            isFileExist = True
        End If 
    Set fso = Nothing
End Function

 
' Set objReg = GetObject("winmgmts://" & strComputer & "/root/default:StdRegProv") 
' objReg.EnumKey HKLM, strKey, arrSubkeys 
' blnUFTInstalled = False
' For Each strSubkey In arrSubkeys 
  ' intRet1 = objReg.GetStringValue(HKLM, strKey & strSubkey,strEntry1a, strValue1) 
  ' If intRet1 <> 0 Then 
    ' objReg.GetStringValue HKLM, strKey & strSubkey,strEntry1b, strValue1 
  ' End If 
  ' If strValue1 <> "" And InStr(LCase(strValue1),"hp unified") > 0 Then 
	' blnUFTInstalled = True
  ' End If 
' Next 
' If blnUFTInstalled = False Then
' msgbox "no"
	' Wscript.quit
' End If
'Create a filesystemObject
Set oFSOTXT=createobject("Scripting.FileSystemObject")
'Create a non existing file scriptpath&"T:\TAP\bin\UIUseCaseResults.txt"  with overwrite option as True
Set objTextfile=oFSOTXT.CreateTextFile(Path&"UIUseCaseResults.txt",True)
'Set objTextfile=oFSOTXT.OpenTextFile(scriptpath&"\UFT\UseCaseResults.txt",8,True) 
Set oExcel=CreateObject("Excel.Application")
Set objFSO = createobject("Scripting.FileSystemObject")
If not objFSO.FileExists(Path&"UseCaseResults.xlsx") then
	Set oWB=oExcel.Workbooks.Add	
Else
	Set oWB=oExcel.Workbooks.Open(Path&"UseCaseResults.xlsx")
End if

Set oSheet=oWB.WorkSheets("Sheet1")
oSheet.Cells.ClearContents
sUseCase = ReadXMLFileData(Path&"TAP_Output.xml","//UseCaseName")
'msgbox sUseCase
'Environment.LoadFromFile(scriptpath&"\UFT\Config_Files\UseCaseMapping.xml")
'msgbox Environment(""&sUseCase)
sScript = ReadXMLFileData(Path&"\Config_Files\UseCaseMapping.xml","//"&sUseCase)
'msgbox sScript
sScriArr = Split(sScript,",")
'msgbox sScriArr(0)

Set qtApp = CreateObject("QuickTest.Application")
If  qtApp.launched <> True then 
	qtApp.Launch 
End If 
'msgbox "qtp launch"
'Make the QuickTest application visible
qtApp.Visible = True
Set qtResultsOpt = CreateObject("QuickTest.RunResultsOptions")
'qtResultsOpt.ResultsLocation = "C:\Res1"
'Set QuickTest run options
'Instruct QuickTest to perform next step when error occurs

'qtApp.Options.Run.ImageCaptureForTestResults = "OnError"
qtApp.Options.Run.RunMode = "Fast"
qtApp.Options.Run.ViewResults = False
'Open the test in read-only mode

If (IsArray(sScriArr)) Then
	
		xlsLiCount=2
	For iCnt = 0 to UBound(sScriArr) 
	
		
		qtApp.Open Path&"Scripts\"&sScriArr(iCnt), True
		Set qtTest = qtApp.Test
		'Run the test
		qtTest.Run	
		strTestStatus = qtTest.LastRunResults.Status 
		If strTestStatus="Pass" Then
			iCounter= iCounter+1
			strUCStatus="Passed" 
			'Call UpdateStatusXls(xlsLiCount,sUseCase,sScriArr(iCnt),strTestStatus)
			'Call UpdateStatusTxt(sUseCase,sScriArr(iCnt),strTestStatus) 
			objTextfile.Writeline  "Subject\Helion Cloud Suite( HCS) / Cloud Orchestration Suite\HCS.10.16\HCS-TA\Functional\TestCase_Automation\4.7 Use Cases;Root\Helion Cloud Suite( HCS) / Cloud Orchestration Suite\HCS 2016.10\HCS-TA\Sprint 17\Functional;"&sUseCase&";"&sScriArr(iCnt)&";"&strUCStatus
		Else
			strUCStatus="Failed"
			strScriptna=sScriArr(iCnt)&"Failed"
			'Call UpdateStatusXls(xlsLiCount,sUseCase,sScriArr(iCnt),strTestStatus)
			objTextfile.Writeline  "Subject\Helion Cloud Suite( HCS) / Cloud Orchestration Suite\HCS.10.16\HCS-TA\Functional\TestCase_Automation\4.7 Use Cases;Root\Helion Cloud Suite( HCS) / Cloud Orchestration Suite\HCS 2016.10\HCS-TA\Sprint 17\Functional;"&sUseCase&";"&sScriArr(iCnt)&";"&strUCStatus
			'Call UpdateStatusTxt(sUseCase,sScriArr(iCnt),strTestStatus) 
		End if
		'xlsLiCount=xlsLiCount+1
    		qtTest.Close  		
	Next		
	
Else
	qtApp.Open Path&"Scripts\"&sScriArr(iCnt), True
	'set run settings for the test
	Set qtTest = qtApp.Test
	'Run the test
	qtTest.Run
	'Msgbox  sScript
	strUCStatus = qtTest.LastRunResults.Status
	'Call UpdateStatusXls(2,sUseCase,sScript,strUCStatus)
	If(strUCStatus="Pass") Then
		strUCStatus = "Passed"
	Else
		strUCStatus ="Failed"
	End if
	objTextfile.Writeline  "Subject\Helion Cloud Suite( HCS) / Cloud Orchestration Suite\HCS.10.16\HCS-TA\Functional\TestCase_Automation\4.7 Use Cases;Root\Helion Cloud Suite( HCS) / Cloud Orchestration Suite\HCS 2016.10\HCS-TA\Sprint 17\Functional;"&sUseCase&";"&sScriArr&";"&strUCStatus
	'Call UpdateStatusTxt(sUseCase,sScript,strUCStatus) 
	
End If
'Close the files
objTextfile.Close
'Release the allocated objects
Set oTextFile=nothing 
	'Msgbox strTestStatus
	If strUCStatus="Fail" or strUCStatus="Failed"Then 
		Call Fun_WriteXMLData(Path&"UseCaseResults.xml","HOSAutomationExecutionStatus",sUseCase,strUCStatus) 
	Else
		strUCStatus="Pass"
		Call Fun_WriteXMLData(Path&"UseCaseResults.xml","HOSAutomationExecutionStatus",sUseCase,strTestStatus) 
	End if
	
	
Function Fun_WriteXMLData(xmlFilePath,sRootElement,sUseCaseName,sUseCaseStatus)
    'Creating a xml dom object for writing
    Set xmlWrObj = CreateObject("Microsoft.XMLDOM")
    'Creating a root element
    Set objRoot =  xmlWrObj.createElement(sRootElement) 
    xmlWrObj.appendChild objRoot
    'Creating a child element for the root    
    Set var1 = xmlWrObj.CreateElement("UseCaseStatus")
    objRoot.appendChild var1
    'Creating a name tag under root element 
    Set objName1 = xmlWrObj.createElement("UseCaseName")  
    objName1.Text = sUseCaseName
    var1.appendChild objName1 
    'Creating a value tag under root element 
    Set objName1Val = xmlWrObj.createElement("Status")  
    objName1Val.Text = sUseCaseStatus
    var1.appendChild objName1Val
    
    
    Set objIntro = xmlWrObj.createProcessingInstruction("xml","version='1.0'")  
    xmlWrObj.insertBefore objIntro,xmlWrObj.childNodes(0)  
    xmlWrObj.Save xmlFilePath
End Function

Function UpdateStatusXls(strLine,strUseCase,strScriArr,strTestStatus)
	
	oSheet.Cells(1,1)="Test_Type"
	oSheet.Cells(1,2)="UseCase_Name"
	oSheet.Cells(1,3)="TestCaseName"
	oSheet.Cells(1,4)="Status"
	oSheet.Cells.Range("A1:D1").Interior.Color = vbYellow 
	oSheet.Cells.Range("A1:D1").font.bold = True
	oSheet.Cells(strLine,1).Value="Functional"
	oSheet.Cells(strLine,2).Value=strUseCase
	oSheet.Cells(strLine,3).Value=strScriArr
	oSheet.Cells(strLine,4).Value=strTestStatus			
		
	oExcel.DisplayAlerts=False
	oWB.SaveAs(Path&"UseCaseResults.xlsx")
	oWB.Close
	Set objFSO=Nothing
	Set oExcel=Nothing
End Function	

Function UpdateStatusTxt(sUseCase,sScriArr,strUCStatus) 
	Set oFSOTXT=createobject("Scripting.FileSystemObject")
	Set objTextfile=oFSOTXT.OpenTextFile(Path&"UIUseCaseResults.txt",8,True) 
	objTextfile.Writeline  "Subject\Helion Cloud Suite( HCS) / Cloud Orchestration Suite\HCS.10.16\HCS-TA\Functional\TestCase_Automation\4.7 Use Cases;Root\Helion Cloud Suite( HCS) / Cloud Orchestration Suite\HCS 2016.10\HCS-TA\Sprint 17\Functional;"&sUseCase&";"&sScriArr&";"&strUCStatus
End Function