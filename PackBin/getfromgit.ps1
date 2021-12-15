$bepdisabled = "$PSScriptRoot\winhttp.disabled"
$bepenabled = "$PSScriptRoot\winhttp.dll"
$HDEnabled = "$PSScriptRoot\valheim_Data\HDEnabled"
$HDDisabled = "$PSScriptRoot\valheim_Data\HDDisabled"
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
        Write-Host $updatemessage[1].Replace("fast-forwarded.", "updated.").Replace("branch", "modpack version").Replace("'origin/main'", "")
    }
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
if ($args[0] -eq "-enableHD") {
    #check to see if textures are disabled
    if ((Test-Path -Path $HDDisabled) -eq $false -And (Test-Path -Path $HDEnabled) -eq $false) { #If HD is not installed.
        New-Item -Path $HDDisabled -Type file
    }
    If (Test-Path -Path $HDDisabled) { #If textures are disabled, rename file so they are enabled.
    Rename-Item -Path $HDDisabled -NewName "HDEnabled"
        If (!(Test-Path -Path $PSScriptRoot\valheim_Data\GoViTextures.7z)) { #If GoViTextures.7z is not present, download it.
            Write-Host "GoViTextures not found. Downloading from host... (651.54MB)"
            Invoke-WebRequest "https://votex09.tonidoid.com/core/downloadfile?filepath=N%3A%5CGoViTextures%2E7z&filename=GoViTextures.7z&disposition=attachment" -O $PSScriptRoot\valheim_Data\GoViTextures.7z
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
            Invoke-WebRequest "https://votex09.tonidoid.com/core/downloadfile?filepath=N%3A%5CoriginalTextures%2E7z&filename=originalTextures.7z&disposition=attachment" -O $PSScriptRoot\valheim_Data\originalTextures.7z
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
if ($args[0] -eq "-update") {
    #check to see if git is installed
    if (!(Test-Path -Path $PSScriptRoot\PackBin\git.exe)) { #If git is not downloaded, download it.
        clear-host
        Write-Host "Git not found. Downloading from host... " -ForegroundColor Yellow
        if (!(Test-Path -Path $PSScriptRoot\PackBin\)) {
            New-Item -Path $PSScriptRoot\PackBin\ -Type directory
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
    if ((Test-Path -Path "C:\Program Files\Git\git-cmd.exe")) { #Verify Git is installed.
        Clear-Host
        Write-Host "Git found." -ForegroundColor Green
        if (Test-Path -Path $PSScriptRoot\PackBin\git\valheimdirtbagmodpack\winhttp.dll) {
            git -C ("$PSScriptRoot\PackBin\git\valheimdirtbagmodpack\ ") pull --progress
            #Start-Process -Filepath $PSScriptRoot\PackBin\git\pull.bat -NoNewWindow
            If ((Test-Path -Path $PSScriptRoot\BepinEx\Plugins\)) {
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
            New-Item -Path $PSScriptRoot\PackBin\git\valheimdirtbagmodpack -Type directory
            git -C ("$PSScriptRoot\PackBin\git\ ") clone ("https://github.com/votex09/valheimdirtbagmodpack") --progress
            #Start-Process -Filepath $PSScriptRoot\PackBin\git\clone.bat -NoNewWindow
            If ((Test-Path -Path $PSScriptRoot\BepinEx\Plugins\)) {
                Remove-Item -Path "$PSScriptRoot\BepInEx\Plugins\*" -Recurse
            }
            Robocopy ("$PSScriptRoot\PackBin\git\valheimdirtbagmodpack\ ") ("$PSScriptRoot ") /E /NFL /NDL /NJH /NJS /nc /ns
            #Clear-Host
            Write-Host "Update complete." -ForegroundColor Green
            pause
            exit
        }
    }
}