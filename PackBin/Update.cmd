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
echo [5] Enable HD Textures
echo [6] Disable HD Textures
echo [ENTER] Update scripts and restart
echo [x] Exit
echo.
set /p x="Select an option: "
if /I "%x%" == "0" powershell -executionpolicy bypass -file .\getfromgit.ps1 -full
if /I "%x%" == "1" powershell -executionpolicy bypass -file .\getfromgit.ps1 -enable
if /I "%x%" == "2" powershell -executionpolicy bypass -file .\getfromgit.ps1 -disable
if /I "%x%" == "3" powershell -executionpolicy bypass -file .\getfromgit.ps1 -update
if /I "%x%" == "4" goto startgame
if /I "%x%" == "5" powershell -executionpolicy bypass -file .\getfromgit.ps1 -enableHD
if /I "%x%" == "6" powershell -executionpolicy bypass -file .\getfromgit.ps1 -disableHD
if /I "%x%" == "x" goto end
goto Selector
:startgame
explorer steam://rungameid/892970
:end
curl -o Update.cmd https://raw.githubusercontent.com/votex09/valheimdirtbagmodpack/main/PackBin/Update.cmd