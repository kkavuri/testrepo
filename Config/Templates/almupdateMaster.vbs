dim ArgObj
Set fso = CreateObject("Scripting.FileSystemObject")
Set ArgObj = WScript.Arguments 

strJsonFileName = ArgObj(0)
keyword = ArgObj(1)

x = JsonReadALMUpdate(strJsonFileName)

If instr(lcase(keyword),"api")>0 Then
	
			tapfolder = Ltrim(x(0))
			ALMPlanPath = Ltrim(x(1))
			ALMLabPath = Ltrim(x(2)) & "\"
End If
If instr(lcase(keyword),"func")>0 Then
			tapfolder = Ltrim(x(3))
			ALMPlanPath = Ltrim(x(4))
			ALMLabPath = Ltrim(x(5)) & "\"
End If
			
			
			strQCURL = Ltrim(x(6))
			strUserName = Ltrim(x(7))
			strPWD = Ltrim(x(8))
			strDomain = Ltrim(x(9))
			strProject = Ltrim(x(10))
			strProduct = Ltrim(x(11))
			strTestType = Ltrim(x(12))
			strPlanStatus = Ltrim(x(13))
			timestamp = now()


'--------------------- test plan - Screen-1 ALM update -------------------------

'FileCall3 tapfolder, "Plan_" & timestamp, strQCURL, strUserName, strPWD, strDomain, strProject, strProduct, strTestType,strPlanStatus

FileCall3 tapfolder, "Plan_" & timestamp, strQCURL, strUserName, strPWD, strDomain, strProject, strProduct, strTestType,strPlanStatus




'--------------------- Functions --------------------------------------------------

Function FileCall3 (strFilename, planname, strQCURL, strUserName, strPWD, strDomain, strProject, strProduct, strTestType,strPlanStatus)

	Set dict = CreateObject("Scripting.Dictionary")
	Set fso = CreateObject("Scripting.FileSystemObject")
	Set file = fso.OpenTextFile (strFilename, 1)
	row = 0
	Do Until file.AtEndOfStream
	  line = file.Readline
	  dict.Add row, line
	  row = row + 1
	Loop
	
	file.Close
	
	introw =1
	For Each line in dict.Items
	
	 strdata=line
	 rowsplit = split(strdata,";")
	 'msgbox ALMPlanPathAPI
	 testPlanFolder = Replace(trim(ALMPlanPath), "Subject\", "") 'for functional
	 'testPlanFolder = Replace(trim(ALMPlanPathAPI), "Subject\", "") 'for functional
	 
	 
	 'msgbox testPlanFolder
	 strtestName = trim(rowsplit(3)) 
	 
    Set oALMConnObj = funcGetALMConnectionObj (strQCURL, strUserName, strPWD, strDomain, strProject, testPlanFolder, planname ,strtestName,strProduct, strTestType,strPlanStatus)
	
	''Proceeding ahead only if connected
	If oALMConnObj.Connected Then
	    'MsgBox "Connected to QC!"
	    'MsgBox oALMConnObj.ProjectName
	Else
	    'MsgBox "Not connected to QC"
	End If
	introw = introw+1
	Next
	Set fso = nothing
	Set dict = nothing

End Function


Function funcGetALMConnectionObj (sQCServer, sQCUsername, sQCPassword, sQCDomain, sQCProject, sQCTestplanPath, sQCPlanname, sQCTestName,strProduct, strTestType,strPlanStatus)

    Set oALMConnObj = CreateObject("TDAPIOLE80.TDConnection")
    oALMConnObj.InitConnectionEx sQCServer
    oALMConnObj.Login sQCUsername, sQCPassword
    oALMConnObj.Connect sQCDomain, sQCProject

	Set tsf = oALMConnObj.TestFactory
	Set trmgr = oALMConnObj.TreeManager
	Set subjectfldr = trmgr.NodebyPath("Subject")

	folder = sQCTestplanPath
	subfolder = sQCPlanname

	On Error Resume Next
	' create main folder
	Set trfolder = subjectfldr.AddNode(folder)
	trfolder.Post

	Set subjectfldr = trmgr.NodebyPath("Subject\" & folder)
	'create subfolder if specified
	If Not subfolder = "" Then
	Set trfolder = subjectfldr.AddNode(subfolder)
	trfolder.Post
	End If

	'reset error handling
	On Error GoTo 0

	If subfolder = "" Then
	Set trfolder = trmgr.NodebyPath("Subject\" & folder)
	Else
	Set trfolder = trmgr.NodebyPath("Subject\" & folder & "\" & subfolder)
	End If

	' now create a test case
	Set sampleTest = trfolder.TestFactory.AddItem(Null)
	' set mandatory values
	sampleTest.Field("TS_NAME") = Cstr(trim(sQCTestName ))
	sampleTest.Field("TS_TYPE") =  Cstr(trim(strTestType))
	sampleTest.Field("TS_USER_12") = Cstr(trim(strProduct))
	sampleTest.Field("TS_RESPONSIBLE") = Cstr(trim(sQCUsername))
	sampleTest.Field("TS_STATUS") = Cstr(trim(strPlanStatus))
	sampleTest.Post

    ''Returning the object
    Set funcGetALMConnectionObj = oALMConnObj

End Function



Function JsonReadALMUpdate(strJsonFileName)

	Set fsoObj = CreateObject("Scripting.FileSystemObject")
	Set filePtrObj = fsoObj.OpenTextFile(strJsonFileName,1)

	reqArray = Array("ALM")
	
	jsonArray = Array("apifilepath","apialmplanpath","apialmlabpath","funcfilepath","funcalmplanpath","funcalmlabpath","almurl","almusername","almpassword","almdomain","almproject","almproduct","almtesttype","almteststatus","almend")
	
	Dim jsonArrayOut(14)
		
	While filePtrObj.AtEndOfStream = False
	sText =  filePtrObj.ReadLine

	For Each val in reqArray
					
		If InStr(sText,val)>0 Then
			For jsonItertor = 0 To ubound(jsonArray)-1
				sobj = filePtrObj.ReadLine
				sdata = Ltrim(jsonArray(jsonItertor))
				jsonArrayOut(jsonItertor) = jsonreplacedata(sobj, sdata)
			Next
		End If
	
	If almend<>"" Then
		Exit for
	End If
	
	filePtrObj.SkipLine
		
	Next
Wend

filePtrObj.Close

Set filePtrObj = Nothing
Set fsoObj = Nothing
  
JsonReadALMUpdate = jsonArrayOut 
	
End Function

Function jsonreplacedata(sObj,data)
	abc = Split(Replace(Replace(sObj,",",""),data,"")," : ")
	jsonreplacedata = Replace(abc(1),chr(34),"")
End Function












'--------------screen 2 part


'Runname = "Run" & now()
Runname = "Run_" & timestamp

'tapfolder = "T:\TAP\bin\File_Read_API.txt"
tapfolder = tapfolder



'tapfolder = "C:\Users\dadina\Desktop\alm\Dadi\sprint 17\final-copy-for all at once update - fully executed\File_Read_API.txt"
'tapfolder = "C:\Users\dadina\Desktop\alm\Dadi\sprint 17\final-copy-for all at once update - fully executed\File_Read_Func.txt"

			
testPlanFolder = ALMPlanPath
'testPlanFolder = "Subject\Helion Cloud Suite( HCS) / Cloud Orchestration Suite\HCS.10.16\HCS-TA\API\TestCase_Automation\4.7 Use Cases"
'testPlanFolder = "Subject\Helion Cloud Suite( HCS) / Cloud Orchestration Suite\HCS.10.16\HCS-TA\Functional\TestCase_Automation\4.7 Use Cases"


testFolder = ALMLabPath
'testFolder = "Root\Helion Cloud Suite( HCS) / Cloud Orchestration Suite\HCS 2016.10\HCS-TA\Sprint 17\API\"
'testFolder = "Root\Helion Cloud Suite( HCS) / Cloud Orchestration Suite\HCS 2016.10\HCS-TA\Sprint 17\Functional\"


qcServer = strQCURL
 
qcUsername = strUserName
qcPassword = strPWD
 
qcDomain = strDomain
qcProject = strProject

			

FileCall tapfolder,Runname


Function FileCall(strFilename, runname)

Set dict = CreateObject("Scripting.Dictionary")
Set fso = CreateObject("Scripting.FileSystemObject")
Set file = fso.OpenTextFile (strFilename, 1)
row = 0
Do Until file.AtEndOfStream
  line = file.Readline
  dict.Add row, line
  row = row + 1
Loop

file.Close
rowvalue = 1
For Each line in dict.Items
'WScript.Echo line
  strdata=line
  rowsplit = split(strdata,";")
  
'testPlanFolder = trim(rowsplit(0))   
 'testFolder = trim(rowsplit(1)) 
 testSet = trim(rowsplit(2)) 
 strtestName = trim(rowsplit(3)) 
 testInsstatus = trim(rowsplit(4))
 
'testPlanPath = "Subject\Helion Cloud Suite( HCS) / Cloud Orchestration Suite\HCS.10.16\HCS-TA\API\TestCase_Automation\4.7 Use Cases"
testPlanPath = testPlanFolder
 'testLabPath= "Root\Helion Cloud Suite( HCS) / Cloud Orchestration Suite\HCS 2016.10\HCS-TA\Sprint 16\API\"
 testLabPath = testFolder
 'testSetName = "As an API Auotmation Engineer User needs to upgrade existing scripts  to version 4.7"
 testSetName = testSet
 'testname = "As an API Auotmation Engineer User needs to upgrade existing scripts  to version 4.7"
 testname = strtestName
 'teststatus = "Failed"
 teststatus = testInsstatus
 testType ="MANUAL"
 'msgbox testPlanPath
 'msgbox testLabPath
 'msgbox testSetName
 'msgbox testname
 'msgbox teststatus
 
  
 Call MovTests(testPlanPath,testLabPath,testSetName,testType,testname,teststatus, runname, rowvalue)
rowvalue =rowvalue + 1
Next

Set fso = nothing
Set dict = nothing


End Function




Function MovTests(testPlanPath,testLabPath,testSetName,testType,testname,teststatus,runname, rowvalue)


sQCServer = qcServer
sQCUsername = qcUsername
sQCPassword = qcPassword
sQCDomain = qcDomain
sQCProject = qcProject

qcServer =sQCServer

Set tdc = CreateObject("TDAPIOLE80.TDConnection")
If (tdc Is Nothing) Then
    'MsgBox "tdc empty"
Else
    'Msgbox "Connection object created"
End If

tdc.InitConnectionEx qcServer
tdc.Login sQCUsername, sQCPassword
tdc.Connect sQCDomain, sQCProject


    Set QCTreeManager=tdc.TreeManager
    Set TestNode=QCTreeManager.nodebypath(testPlanPath)
    Set TestFact = TestNode.TestFactory
    Set TestsList = TestFact.NewList("")
    
    
    Set QCTSTreeManager = tdc.TestSetTreeManager     
    Set  TreeNode=QCTSTreeManager.NodebyPath(testLabPath)
     newtestfolder = runname
     
     If rowvalue=1 Then
     	
     
        Set labFolder = TreeNode.AddNode(newtestfolder)
        
        TreeNode.Post
        
     End If   
        
    	tdc.Disconnect()

	tdc.Logout()

	tdc.ReleaseConnection()

PortToTestLab testPlanPath, testLabPath & newtestfolder, testSetName, testType, testname, teststatus


'funcGetAndUpdateStatusInALM testLabPath & newtestfolder,testSetName,testname,teststatus
 
    
End Function



Function PortToTestLab(testPlanPath,testLabPath,testSetName,testType,testname, teststatus)


sQCServer = qcServer
sQCUsername = qcUsername
sQCPassword = qcPassword
sQCDomain = qcDomain
sQCProject = qcProject

Set oALMConnObj = CreateObject("TDApiOle80.TDConnection.1")
	
    oALMConnObj.InitConnectionEx sQCServer

    oALMConnObj.ConnectProjectEx sQCDomain, sQCProject,sQCUsername, sQCPassword

    
    Set treeMng     = oALMConnObj.TreeManager
    Set TestNode    = treeMng.nodebypath(testPlanPath)
    Set TestFact    = TestNode.TestFactory
    Set TestsList   = TestFact.NewList("")

    Set TStreeMng   = oALMConnObj.TestSetTreeManager
    Set TreeNode    = TStreeMng.NodebyPath(testLabPath)
    Set TestSetFact = TreeNode.TestSetFactory

    Set NewTestSet=TestSetFact.AddItem(Null)' Creates new testset
    NewTestSet.name = testSetName
    NewTestSet.Field("CY_COMMENT") = testSetName
    NewTestSet.status="Open"
    NewTestSet.post
    

    Set testfac = NewTestSet.TSTestFactory

    For Each tests In TestsList
 
       If tests.Field("TS_TYPE")= testType Then
 
           Set tmptstset = testfac.AddItem(tests.ID)
          if tmptstset.Test.Name = testname then
          ' msgbox tmptstset.Test.Name & "=" & testname
          
           
         
         
          
                 tmptstset.Status = teststatus
'msgbox tmptstset.Status & "=" & teststatus 

      
        	End If
        	tmptstset.Post
        	
        End If 
    Next
    
      
    oALMConnObj.Disconnect()

    oALMConnObj.Logout()

    oALMConnObj.ReleaseConnection()

End Function


FileCall2 tapfolder, Runname


Function FileCall2 (strFilename, Runname)

Set dict = CreateObject("Scripting.Dictionary")
Set fso = CreateObject("Scripting.FileSystemObject")
Set file = fso.OpenTextFile (strFilename, 1)
row = 0
Do Until file.AtEndOfStream
  line = file.Readline
  dict.Add row, line
  row = row + 1
Loop

file.Close

introw =1
For Each line in dict.Items
'WScript.Echo line
  strdata=line
  
  rowsplit = split(strdata,";")
  
'testPlanFolder = trim(rowsplit(0))   
 'testFolder = trim(rowsplit(1)) 
 testSet = trim(rowsplit(2)) 
 strtestName = trim(rowsplit(3)) 
 testInsstatus = trim(rowsplit(4))
 
'testPlanPath = "Subject\Helion Cloud Suite( HCS) / Cloud Orchestration Suite\HCS.10.16\HCS-TA\API\TestCase_Automation\4.7 Use Cases"
testPlanPath = testPlanFolder
 'testLabPath= "Root\Helion Cloud Suite( HCS) / Cloud Orchestration Suite\HCS 2016.10\HCS-TA\Sprint 16\API\"
 testLabPath = testFolder
 'testSetName = "As an API Auotmation Engineer User needs to upgrade existing scripts  to version 4.7"
 testSetName = testSet
 'testname = "As an API Auotmation Engineer User needs to upgrade existing scripts  to version 4.7"
 testname = strtestName
 'teststatus = "Failed"
 teststatus = testInsstatus
 testType ="MANUAL"
 'msgbox testPlanPath
 'msgbox testLabPath
 'msgbox testSetName
 'msgbox testname
 'msgbox teststatus
 'msgbox introw
 
 
 fillstatusWithSteps testLabPath, Runname, introw, teststatus, testname
 
introw = introw+1
Next

Set fso = nothing
Set dict = nothing


End Function


Function fillstatusWithSteps(testLabPath, strSetFolder, itemrow, teststatus, stepname)
	

Set tdc = CreateObject("TDApiOle80.TDConnection")

qcServer = qcServer
tdc.InitConnectionEx qcServer
 
qcUsername = qcUsername
qcPassword = qcPassword
tdc.Login qcUsername, qcPassword
 
qcDomain = qcDomain
qcProject = qcProject
 
tdc.Connect qcDomain, qcProject


'vPath="Root\Helion Cloud Suite( HCS) / Cloud Orchestration Suite\HCS 2016.10\HCS-TA\Sprint 17\API\" & "Run10/25/2016 2:58:38 AM"
vPath = testLabPath & strSetFolder '"Run10/25/2016 2:58:38 AM"

 
'Selecting first Test-Set
Set oTestSet = tdc.TestSetTreeManager.NodeByPath(vpath).TestSetFactory.NewList("").Item(itemrow).TsTestFactory
 
'Selecting first Test from Testset
Set oTest = oTestSet.NewList("").Item(1)
 
'Creating a Run
Set oRunInstance = oTest.RunFactory
Set oRun=oRunInstance.AddItem("Automated")'Run Name
 
oRun.Status = teststatus 'Run Status
oRun.Post   
oRun.Refresh
 
Set oStep = oRun.StepFactory
oStep.AddItem(stepname)'Creating Step
Set oStepDetails = oStep.NewList("")
oStepDetails.Item(1).Field("ST_STATUS") = teststatus 'Updating Step Status
oStepDetails.Item(1).Field("ST_DESCRIPTION") = "Test Desc"'Updating Step Description
oStepDetails.Item(1).Field("ST_EXPECTED") = "Test Expected"'Updating Expected
oStepDetails.Item(1).Field("ST_ACTUAL") = "Test Actual"'Updating Actual
oStepDetails.Post



Set fso = nothing
Set dict = nothing

Set oStep=Nothing
Set oStepDetails=Nothing
Set oRun=Nothing
Set oRunInstance=Nothing
Set oTest=Nothing
Set oTestSet=Nothing
Set tdc=Nothing





End Function
