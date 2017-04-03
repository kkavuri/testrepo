@echo off
set var=${Buildloc}alm.json
set runtype=${runType}
C:\Windows\SysWOW64\cscript.exe ${Buildloc}almupdate${runType}.vbs %var% %runtype%
Exit
