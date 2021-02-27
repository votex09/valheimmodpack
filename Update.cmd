:Selector
@echo off
ECHO =============================
ECHO Valheim Updater/Patcher
ECHO =============================
ECHO.
echo [1] Enable Mods
echo [2] Disable Mods
echo [3] Update Pack
echo.
echo.
set /p x="Select an option: "
if /I "%x%" == "1" powershell -executionpolicy bypass -file .\getfromgit.ps1 -enable
if /I "%x%" == "2" powershell -executionpolicy bypass -file .\getfromgit.ps1 -disable
if /I "%x%" == "3" powershell -executionpolicy bypass -file .\getfromgit.ps1 -update
exit
