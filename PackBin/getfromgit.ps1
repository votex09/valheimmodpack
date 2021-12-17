$bepdisabled = "$PSScriptRoot\winhttp.disabled"
$bepenabled = "$PSScriptRoot\winhttp.dll"
$HDEnabled = "$PSScriptRoot\valheim_Data\HDEnabled"
$HDDisabled = "$PSScriptRoot\valheim_Data\HDDisabled"
$pathtoConfig = "$PSScriptRoot\BepInEx\config"
$excludefile = "$PSScriptRoot\PackBin\git\valheimdirtbagmodpack\.git\info\exclude"
$availablelocks = @('manfredo52.CustomizableCamera','randyknapp.mods.equipmentandquickslots','virtuacode.valheim.equipwheel')
if ($args[0] -eq "-enable") {
    #check to see if plugins are disabled
    If (Test-Path -Path $bepdisabled) { #If plugins are disabled, rename winhttp so they are enabled.
        Write-Host "modsEnabled = false : Enabling Mods..."
        Rename-Item -Path $bepdisabled -NewName "winhttp.dll"
        pause
        exit
    }
    Else { #In all other cases, including when plugins are enabled:
        Write-Host "Mods are already enabled."
        pause
        exit
    }
}
if ($args[0] -eq "-disable") {
    #check to see if plugins are enabled
    If (Test-Path -Path $bepenabled) { #If plugins are enabled, rename winhttp so they are disabled.
        Write-Host "modsEnabled = true : Disabling Mods..."
        Rename-Item -Path $bepenabled -NewName "winhttp.disabled"
        pause
        exit
    }
    Else { #In all other cases, including when plugins are disabled:
        Write-Host "Mods are already disabled."
        pause
        exit
    }
}
if ($args[0] -eq "-full") {
    Clear-Host
    If (Test-Path -Path $bepdisabled) { #If plugins are disabled, rename winhttp so they are enabled.
        Write-Host "Enabling Mods before update since they were disabled..." -ForegroundColor Yellow
        Rename-Item -Path $bepdisabled -NewName "winhttp.dll"
    }
    Write-Host "Downloading mod package from git..."
    Invoke-WebRequest "https://github.com/votex09/valheimdirtbagmodpack/archive/main.zip" -O $PSScriptRoot\PackBin\pack.zip
    & "$PSScriptRoot\PackBin\7z\7za.exe" x "$PSScriptRoot\PackBin\pack.zip" "-o$PSScriptRoot\PackBin\unpack\"
    Remove-Item -Path "$PSScriptRoot\BepInEx\Plugins\*" -Recurse
    Robocopy ("$PSScriptRoot\PackBin\unpack\valheimdirtbagmodpack-main\ ") ("$PSScriptRoot ") /E /NFL /NDL /NJH /NJS /nc /ns
    Clear-Host
    Write-Host "Cleaning up..."
    Remove-Item "$PSscriptRoot\PackBin\Unpack\*" -Recurse
    Clear-Host
    Write-Host "Complete." -ForegroundColor Green
    Pause
    exit
}
if ($args[0] -eq "-checkstatus") {
    if ((Test-Path -Path "C:\Program Files\Git\git-cmd.exe")) {
        git -C ("$PSScriptRoot\PackBin\git\valheimdirtbagmodpack\ ") remote update *> $null
        git -C ("$PSScriptRoot\PackBin\git\valheimdirtbagmodpack\ ") status -uno | Out-File -FilePath "$PSScriptRoot\PackBin\gitstatus.txt"
        $updatemessage = Get-Item -Path "$PSScriptRoot\PackBin\gitstatus.txt" | Get-Content -Tail 5
        Write-Host $updatemessage[1].Replace("fast-forwarded.", "updated.").Replace("branch", "modpack version") -ForegroundColor Cyan
        $vers = git -C ("$PSScriptRoot\PackBin\git\valheimdirtbagmodpack\ ") rev-list --count origin/main 
        Write-Host "Current Version : $vers -- Update Log:`n"
        git -C ("$PSScriptRoot\PackBin\git\valheimdirtbagmodpack\ ") log origin/main --no-merges --pretty='format:%cs | %ch | %s' | Out-File -FilePath "$PSScriptRoot\PackBin\gitlog.txt"
        $logshort = Get-Item -Path "$PSScriptRoot\PackBin\gitlog.txt" | Get-Content -Head 6
        Write-Host $logshort[0] -ForegroundColor Blue
        Write-Host $logshort[1] -ForegroundColor Blue
        Write-Host $logshort[2] -ForegroundColor Blue
        Write-Host $logshort[3] -ForegroundColor Blue
        Write-Host $logshort[4] -ForegroundColor Blue
        Write-Host $logshort[5] -ForegroundColor Blue
    }
    <#
    if (Test-Path -Path $PSScriptRoot\PackBin\Version) {
        $updates = Get-Item -Path "$PSScriptRoot\PackBin\Version" | Get-Content -Tail 5
        $vers = Get-Item -Path "$PSScriptRoot\PackBin\Version" | Get-Content -TotalCount 1
        Write-Host "Current Version : $vers -- Update Log:`n" 
        Write-Host $updates[4] -ForegroundColor Blue
        Write-Host $updates[3] -ForegroundColor Blue
        Write-Host $updates[2] -ForegroundColor Blue
        Write-Host $updates[1] -ForegroundColor Blue
        Write-Host $updates[0] -ForegroundColor Blue
    }
    #>
    else {
        Write-Host "No update log found. Please update the pack."
    }
    Write-Host "`n=========================`n"

    If (Test-Path -Path $bepdisabled) { #If plugins are disabled.
        Write-Host "Mods are currently DISABLED" -ForegroundColor Red
    }
    If (Test-Path -Path $bepenabled) { #If plugins are enabled.
        Write-Host "Mods are currently ENABLED" -ForegroundColor Green
    }
    If ((Test-Path -Path $bepenabled) -eq $false -And (Test-Path -Path $bepdisabled) -eq $false) { #If plugins are not installed.
        Write-Host "Mods are not Currently Installed" -ForegroundColor Yellow
    }
    If (Test-Path -Path $HDEnabled) { #If HD is enabled.
        Write-Host "HD Textures are currently ENABLED" -ForegroundColor Green
    }
    If (test-path -path $HDDisabled) { #If HD is disabled.
        Write-Host "HD Textures are currently DISABLED" -ForegroundColor Red
    }
    If ((Test-Path -Path $HDEnabled) -eq $false -And (Test-Path -Path $HDDisabled) -eq $false) { #If HD is not installed.
        Write-Host "HD Textures are not Currently Installed" -ForegroundColor Yellow
    }
}
<#
if ($args[0] -eq "-enableHD") {
    #check to see if textures are disabled
    if ((Test-Path -Path $HDDisabled) -eq $false -And (Test-Path -Path $HDEnabled) -eq $false) { #If HD is not installed.
        New-Item -Path $HDDisabled -Type file
    }
    If (Test-Path -Path $HDDisabled) { #If textures are disabled, rename file so they are enabled.
    Rename-Item -Path $HDDisabled -NewName "HDEnabled"
        If (!(Test-Path -Path $PSScriptRoot\valheim_Data\GoViTextures.7z)) { #If GoViTextures.7z is not present, download it.
            Write-Host "GoViTextures not found. Downloading from host... (651.54MB)"
            #Invoke-WebRequest "https://votex09.tonidoid.com/core/downloadfile?filepath=N%3A%5CGoViTextures%2E7z&filename=GoViTextures.7z&disposition=attachment" -O $PSScriptRoot\valheim_Data\GoViTextures.7z
        }
        Clear-Host
        Write-Host "HDTextures = false : Enabling HD Textures..."
        & "$PSScriptRoot\PackBin\7z\7za.exe" x "$PSScriptRoot\valheim_Data\GoViTextures.7z" "-o$PSScriptRoot\valheim_Data\" -aoa
        exit
    }
    Else { #In all other cases, including when textures are enabled:
        Write-Host "HD textures are already enabled."
        pause
        exit
    }
}
if ($args[0] -eq "-disableHD") {
    #check to see if textures are enabled
    if ((Test-Path -Path $HDDisabled) -eq $false -And (Test-Path -Path $HDEnabled) -eq $false) { #If HD is not installed.
        New-Item -Path $HDEnabled -Type file
    }
    If (Test-Path -Path $HDEnabled) { #If textures are enabled, rename file so they are disabled.
    Rename-Item -Path $HDEnabled -NewName "HDDisabled"
        If (!(Test-Path -Path $PSScriptRoot\valheim_Data\originalTextures.7z)) { #If originalTextures.7z is not present, download it.
            Write-Host "Original textures not found. Downloading from host... (62.73MB)"
            #Invoke-WebRequest "https://votex09.tonidoid.com/core/downloadfile?filepath=N%3A%5CoriginalTextures%2E7z&filename=originalTextures.7z&disposition=attachment" -O $PSScriptRoot\valheim_Data\originalTextures.7z
        }
        Clear-Host
        Write-Host "HDTextures = true : Disabling HD Textures..."
        & "$PSScriptRoot\PackBin\7z\7za.exe" x "$PSScriptRoot\valheim_Data\originalTextures.7z" "-o$PSScriptRoot\valheim_Data\" -aoa
        exit
    }
    Else { #In all other cases, including when textures are disabled:
        Write-Host "HD textures are already disabled."
        pause
        exit
    }
}
#>
if ($args[0] -eq "-update") {
    #check to see if git is installed
    if (!(Test-Path -Path "$PSScriptRoot\PackBin\git.exe")) { #If git is not downloaded, download it.
        clear-host
        Write-Host "Git not found. Downloading from host... " -ForegroundColor Yellow
        if (!(Test-Path -Path "$PSScriptRoot\PackBin\")) {
            New-Item -Path "$PSScriptRoot\PackBin\" -Type directory
        }
        write-host "Current Directory: $PSScriptroot"
        Start-Sleep 2
        Invoke-WebRequest https://github.com/git-for-windows/git/releases/download/v2.34.1.windows.1/Git-2.34.1-64-bit.exe -O $PSScriptRoot\PackBin\git.exe
        Clear-Host
        Write-Host "Installing Git..." -ForegroundColor Green
        Write-Host "Please accept the installation." -ForegroundColor Green
        Start-Process -FilePath "$PSScriptRoot\PackBin\git.exe" -ArgumentList /SILENT
        Write-Host "Please wait for Git to finish installing..." -ForegroundColor Yellow
        pause
    }
    #check to see if user locked configs
    $l = $false
    for ($i = 0; $i -lt $availablelocks.Count; $i++) {
        $SEL = Select-String -Path $excludefile -Pattern "$availablelocks[$i]"
        if ($null -eq $SEL) {
            $l = $true
        }
    }
    #if user locked configs, copy configs to PackBin folder
    if ($l -eq $true) {
        for ($i =0; $i -lt $availablelocks.Count; $i++) {
            Copy-Item -Path "$pathtoConfig\$availablelocks[$i].cfg" -Destination "$PSScriptRoot\PackBin\"
        }
    }
    if ((Test-Path -Path "C:\Program Files\Git\git-cmd.exe")) { #Verify Git is installed.
        Clear-Host
        Write-Host "Git found." -ForegroundColor Green
        if (Test-Path -Path "$PSScriptRoot\PackBin\git\valheimdirtbagmodpack\winhttp.dll") {
            git -C ("$PSScriptRoot\PackBin\git\valheimdirtbagmodpack\ ") pull --progress
            #Start-Process -Filepath $PSScriptRoot\PackBin\git\pull.bat -NoNewWindow
            If ((Test-Path -Path "$PSScriptRoot\BepinEx\Plugins\")) {
                Remove-Item -Path "$PSScriptRoot\BepInEx\Plugins\*" -Recurse
            }
            Robocopy ("$PSScriptRoot\PackBin\git\valheimdirtbagmodpack\ ") ("$PSScriptRoot ") /E /NFL /NDL /NJH /NJS /nc /ns
            #Clear-Host
            Write-Host "Update complete." -ForegroundColor Green
            pause
            exit
        }
        else {
            Write-Host "Pack not found. Cloning repository..." -ForegroundColor Yellow
            New-Item -Path "$PSScriptRoot\PackBin\git\valheimdirtbagmodpack" -Type directory
            git -C ("$PSScriptRoot\PackBin\git\ ") clone ("https://github.com/votex09/valheimdirtbagmodpack") --progress
            #Start-Process -Filepath $PSScriptRoot\PackBin\git\clone.bat -NoNewWindow
            If ((Test-Path -Path "$PSScriptRoot\BepinEx\Plugins"\)) {
                Remove-Item -Path "$PSScriptRoot\BepInEx\Plugins\*" -Recurse
            }
            Robocopy ("$PSScriptRoot\PackBin\git\valheimdirtbagmodpack\ ") ("$PSScriptRoot ") /E /NFL /NDL /NJH /NJS /nc /ns
            #Clear-Host
            #if user locked configs, move configs to config folder
            if ($l -eq $true) {
                for ($i =0; $i -lt $availablelocks.Count; $i++) {
                    Copy-Item -Path "$PSScriptRoot\PackBin\$availablelocks[$i].cfg" -Destination "$pathtoConfig\"
                    Remove-Item -Path "$PSScriptRoot\PackBin\$availablelocks[$i].cfg"
                }
            }
            Write-Host "Update complete." -ForegroundColor Green
            pause
            exit
        }
    }
}
if ($args[0] -eq "-logs") {
    Clear-Host
    Import-Csv "$PSScriptroot\PackBin\gitlog.txt" -delimiter `| -Header 'Date', 'TimeStamp', 'Commit Message' | Out-Gridview -Wait -Title 'Git Commit Log'
    exit
}
if ($args[0] -eq "-cfglock") {
    $menumode = "continue"
    while ($menumode -eq "continue") {
        Clear-Host
        if ((Test-Path -Path "$PSScriptRoot\PackBin\git\valheimdirtbagmodpack\.git\info\exclude")) {
            Write-Host "=============================`nConfig Lock Menu`n============================="
            Write-Host "This menu locks certain configs from changing on update.`nThis is the only way for keybindings for mods to persist between updates.`nEnter [X] to exit`n`n" -ForegroundColor Blue
            Write-Host "Current Locked Configs:"
            #retrieve list of locked configs from file as array@()
            $locked = @(Get-Content -Path "$PSScriptRoot\PackBin\git\valheimdirtbagmodpack\.git\info\exclude")
            #loop through list and print to screen
            for ($i = 0; $i -lt $locked.Count; $i++) {
                Write-Host "$($locked[$i])" -ForegroundColor Yellow
            }
            Write-Host "`n------------------------------`n"
            for ($i = 0; $i -lt $availablelocks.Count; $i++) {
                Write-Host "[$i]$($availablelocks[$i])"
            }
            $usermode = Read-Host "`n`n[L]ock or [U]nlock a config?"
            if ($usermode -eq "x" -or $usermode -eq "X") {
                exit
            }
            $userselection = Read-Host "Enter the number of the config you wish to lock/unlock (Or [A] for all)"
            if ($userselection -eq "x" -or $userselection -eq "X") {
                exit
            }
            #lock config
            if ($usermode -eq "l" -or $usermode -eq "L") {
                if ($userselection -eq "a" -or $userselection -eq "A") {
                    for ($i = 0; $i -lt $availablelocks.Count; $i++) {
                        $SEL = Select-String -Path $excludefile -Pattern "$($availablelocks[$i])"
                        if ($null -ne $SEL) {
                            Write-Host "$($availablelocks[$i]) was already locked."
                            Start-Sleep 1
                        }
                        else {
                            Write-Host "Locking $($availablelocks[$i])..."
                            Add-Content -Path $excludefile -Value $availablelocks[$i]
                        }
                    }
                }
                else {
                    #check if array index is out of bounds
                    if ($userselection -gt $availablelocks.Count -or $userselection -lt 0) {
                        Write-Host "Invalid selection."
                        Start-Sleep 1
                    }
                    else {
                        $SEL = Select-String -Path $excludefile -Pattern "$($availablelocks[$userselection])"
                        if ($null -ne $SEL) {
                            Write-Host "$($availablelocks[$userselection]) was already locked."
                            Start-Sleep 1
                        }
                        else {
                            Write-Host "Locking $($availablelocks[$userselection])..."
                            Add-Content -Path $excludefile -Value "$($availablelocks[$userselection])"
                            Start-Sleep 1
                        }
                    }
                }
            }
            #unlock config
            if ($usermode -eq "u" -or $usermode -eq "U") {
                if ($userselection -eq "a" -or $userselection -eq "A") {
                    for ($i = 0; $i -lt $availablelocks.Count; $i++) {
                        $SEL = Select-String -Path $excludefile -Pattern "$($availablelocks[$i])"
                        if ($null -eq $SEL) {
                            Write-Host "$($availablelocks[$i]) was already unlocked."
                            Start-Sleep 1
                        }
                        else {
                            Write-Host "Unlocking $($availablelocks[$i])..."
                            ((Get-Content -Path $excludefile) -replace "$($availablelocks[$i])", "") | Set-Content -Path $excludefile
                            Start-Sleep 1
                        }
                    }
                }
                else {
                    #check if array index is out of bounds
                    if ($userselection -gt $availablelocks.Count -or $userselection -lt 0) {
                        Write-Host "Invalid selection."
                        Start-Sleep 1
                    }
                    else {
                        $SEL = Select-String -Path $excludefile -Pattern "$($availablelocks[$userselection])"
                        if ($null -eq $SEL) {
                            Write-Host "$($availablelocks[$userselection]) was already unlocked."
                            Start-Sleep 1
                        }
                        else {
                            Write-Host "Unlocking $($availablelocks[$userselection])..."
                            ((Get-Content -Path $excludefile) -replace "$($availablelocks[$userselection])", "") | Set-Content -Path $excludefile
                            Start-Sleep 1
                        }
                    }
                }
            }
        }
        else {
            New-Item -Path "$PSScriptRoot\PackBin\git\valheimdirtbagmodpack\.git\info\exclude" -Type file
        }
    (Get-Content $excludefile) | Where-Object {$_.trim() -ne "" } | set-content $excludefile
    Start-Sleep 2
    }
}
if ($args[0] -eq "-enableHD") {
    Clear-Host
    Write-Host "Not Implemented yet." -ForegroundColor Red
    pause
}
if ($args[0] -eq "-disableHD") {
    Clear-Host
    Write-Host "Not Implemented yet." -ForegroundColor Red
    pause
}