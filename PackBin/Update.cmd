@echo off
:Selector
curl -o getfromgit.ps1 https://raw.githubusercontent.com/votex09/valheimdirtbagmodpack/main/PackBin/getfromgit.ps1
cls
ECHO =============================
ECHO    Valheim Updater/Patcher
ECHO =============================
echo.
powershell -executionpolicy bypass -file .\getfromgit.ps1 -checkstatus
echo.
echo [0] Full Download
echo [1] Enable Mods
echo [2] Disable Mods
echo [3] Update Pack
echo [4] Start Game
echo. 
echo Options:
echo [Q]uit and Update Scripts, [E]nable HD, [D]isable HD, [V]iew Update Log, [T]oggle Config Locks
echo.
set /p x="Select an option: "
if /I "%x%" == "0" powershell -executionpolicy bypass -file .\getfromgit.ps1 -full
if /I "%x%" == "1" powershell -executionpolicy bypass -file .\getfromgit.ps1 -enable
if /I "%x%" == "2" powershell -executionpolicy bypass -file .\getfromgit.ps1 -disable
if /I "%x%" == "3" powershell -executionpolicy bypass -file .\getfromgit.ps1 -update
if /I "%x%" == "4" goto startgame
if /I "%x%" == "e" powershell -executionpolicy bypass -file .\getfromgit.ps1 -enableHD
if /I "%x%" == "d" powershell -executionpolicy bypass -file .\getfromgit.ps1 -disableHD
if /I "%x%" == "q" goto end
if /I "%x%" == "v" powershell -executionpolicy bypass -file .\getfromgit.ps1 -logs
if /I "%x%" == "t" powershell -executionpolicy bypass -file .\getfromgit.ps1 -cfglock
goto Selector
:startgame
explorer steam://rungameid/892970
:end
curl -o Update.cmd https://raw.githubusercontent.com/votex09/valheimdirtbagmodpack/main/PackBin/Update.cmd