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

' variables declaration
sUC_Declare=ReadXMLFileData(Path&"constants.xml","//UC_Declare")
sScripts_Folder=ReadXMLFileData(Path&"constants.xml","//Scripts_Folder")
sConfig_Folder=ReadXMLFileData(Path&"constants.xml","//Config_Folder")
sUseCaseMapping_Xml=ReadXMLFileData(Path&"constants.xml","//UseCaseMapping_Xml")
sUseCaseResults_txt=ReadXMLFileData(Path&"constants.xml","//UseCaseResults_txt")
sUseCaseResults_Xml=ReadXMLFileData(Path&"constants.xml","//UseCaseResults_Xml")

For Each strSubkey In arrSubkeys 
  intRet1 = objReg.GetStringValue(HKLM, strKey & strSubkey,strEntry1a, strValue1) 
  If intRet1 <> 0 Then 
    objReg.GetStringValue HKLM, strKey & strSubkey, _ 
     strEntry1b, strValue1 
  End If 
  If strValue1 <> "" Then 
  End If
  objReg.GetStringValue HKLM, strKey & strSubkey,strEntry2, strValue2 
Next
'Wscript.quit
Function ReadXMLFileData(sFilePath,sTagName)
	If isFileExist(sFilePath) Then
		Set xmlDoc = CreateObject("Microsoft.XMLDOM")
      		xmlDoc.Async = "False"
      		xmlDoc.Load(sFilePath)
	      Set colNodes=xmlDoc.selectNodes(sTagName)
	If colNodes.Length>1 Then
	 tmp=""
	 	For Each objNode in colNodes		
		      tmp=tmp & objNode.Text & ","
	      Next
	      ReadXMLFileData= left(tmp,len(tmp)-1)
	 else
	    For Each objNode in colNodes
		     ReadXMLFileData = objNode.Text 
	      Next
	     
	 End If
	     ' cnt = ""
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

 
'Create a filesystemObject
Set oFSOTXT=createobject("Scripting.FileSystemObject")
'Create a non existing file scriptpath&"T:\TAP\bin\UIUseCaseResults.txt"  with overwrite option as True
Set objTextfile=oFSOTXT.CreateTextFile(Path &sUseCaseResults_txt &".txt",True)
'Set objTextfile=oFSOTXT.OpenTextFile(scriptpath&"\UFT\UseCaseResults.txt",8,True) 
'Set oExcel=CreateObject("Excel.Application")
'Set objFSO = createobject("Scripting.FileSystemObject")
'If not objFSO.FileExists(Path & sUseCaseResults_Xlsx &".xlsx") then
'	Set oWB=oExcel.Workbooks.Add	
'Else
''	Set oWB=oExcel.Workbooks.Open(Path & sUseCaseResults_Xlsx &".xlsx")
'End if
'Set oSheet=oWB.WorkSheets("Sheet1")
'oSheet.Cells.ClearContents
sUseCase = ReadXMLFileData(Path & sUC_Declare &".xml","//UseCaseName")
susecases=split(sUseCase,",")
For each sucase in susecases
	sScript = ReadXMLFileData(Path&"\"&sConfig_Folder&"\"&sUseCaseMapping_Xml&".xml","//"&sucase)
	sScriArr = Split(sScript,",")	
	Set qtApp = CreateObject("QuickTest.Application")
	If  qtApp.launched <> True then 
		qtApp.Launch 
	End If 
	'Make the QuickTest application visible
	qtApp.Visible = True
	Set qtResultsOpt = CreateObject("QuickTest.RunResultsOptions")
	qtApp.Options.Run.RunMode = "Fast"
	qtApp.Options.Run.ViewResults = False
	'Open the test in read-only mode	
	If (IsArray(sScriArr)) Then	
			xlsLiCount=2
		For iCnt = 0 to UBound(sScriArr) 		
			qtApp.Open Path & sScripts_Folder &"\"&sScriArr(iCnt), True
			Set qtTest = qtApp.Test
			'Run the test
			qtTest.Run	
			strUCStatus = qtTest.LastRunResults.Status 
			If strUCStatus="Failed" or strUCStatus= "Fail" Then
				strScriptna=sScriArr(iCnt)&"Failed"				
				objTextfile.Writeline  "Project_Name\Usecases_Status\;"&sucase&";"&sScriArr(iCnt)&";"&strUCStatus
				exit for
			Else
				iCounter= iCounter+1
				strUCStatus="Passed" 				
				objTextfile.Writeline  "Project_Name\Usecases_Status\;"&sucase&";"&sScriArr(iCnt)&";"&strUCStatus
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
			If strUCStatus="Failed" or strUCStatus= "Fail" Then
				strScriptna=sScriArr(iCnt)&"Failed"				
				objTextfile.Writeline  "Project_Name\Usecases_Status\;"&sucase&";"&sScriArr(iCnt)&";"&strUCStatus
				exit for
			Else
				iCounter= iCounter+1
				strUCStatus="Passed" 				
				objTextfile.Writeline  "Project_Name\Usecases_Status\;"&sucase&";"&sScriArr(iCnt)&";"&strUCStatus
			End if				
	End If
	'Call Fun_WriteXMLData(Path & sUseCaseResults_Xml&".xml","AutomationExecutionStatus",sucase,strUCStatus) 
Next 	
	'Close the files
	objTextfile.Close
	qtApp.quit
Function Fun_WriteXMLData(xmlFilePath,sRootElement,sUseCaseName,sUseCaseStatus)
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
	objTextfile.Writeline  "Project_Name\Usecases_Status\;"&sUseCase&";"&sScriArr&";"&strUCStatus
End Function
