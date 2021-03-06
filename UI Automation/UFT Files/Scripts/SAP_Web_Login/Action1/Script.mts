﻿'----Retriving relative path to load global and getdata function libraries---
sObjRepoFile = Environment.Value("TestDir")
Set oFso = CreateObject( "Scripting.FileSystemObject" )
Environment.Value("RelativePath")=oFso.GetParentFolderName(oFso.GetParentFolderName( sObjRepoFile ))

'-----Loading Global function library runtime
Environment("GlobLibPath") = Environment.Value("RelativePath") & "\Library_Files\Global\" 
LoadFunctionLibrary Environment("GlobLibPath") &"Global_Functions.qfl"

'-----loading App specific librabry runtime
AppLibPath = Environment.Value("RelativePath") & "\Library_Files\App_Specific\" & Environment.Value("AppVersion") &"\"
LoadFunctionLibrary AppLibPath &"SAP_Web_Specific.qfl"

'-----Log intialization
Call LogInitialization("","New")

'-----Actual scripting starts from here
Set oUcase=readExcelWrite2Dictionary(Local_win_path&"COSTestData.xlsx","SAP_Win_Login","TC_2")
Call LaunchBrowser(oUcase("Browser"),oUcase("Url"))
call SAP_GUI_Login(oUcase("uid"),oUcase("pwd"))

