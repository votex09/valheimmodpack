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
    Invoke-WebRequest https://github.com/votex09/valheimdirtbagmodpack/archive/main.zip -O $PSScriptRoot\PackBin\pack.zip
    & "$PSScriptRoot\PackBin\7z\7za.exe" x "$PSScriptRoot\PackBin\pack.zip" "-o$PSScriptRoot\PackBin\unpack\"
    Remove-Item -Path "$PSScriptRoot\BepInEx\Plugins\*" -Recurse
    Robocopy ("$PSScriptRoot\PackBin\unpack\valheimdirtbagmodpack-main\ ") ("$PSScriptRoot ") /E
    Clear-Host
    Write-Host "Cleaning up..."
    Remove-Item "$PSscriptRoot\PackBin\Unpack\*" -Recurse
    Clear-Host
    Write-Host "Complete." -ForegroundColor Green
    Pause
    exit
}
if ($args[0] -eq "-checkstatus") {
    $updates = Get-Item -Path "$PSScriptRoot\PackBin\Version" | Get-Content -Tail 5
    $vers = Get-Item -Path "$PSScriptRoot\PackBin\Version" | Get-Content -TotalCount 1
    Write-Host "Current Version : $vers" 
    Write-Host "Update Log:`n" 
    Write-Host $updates[4] -ForegroundColor Blue
    Write-Host $updates[3] -ForegroundColor Blue
    Write-Host $updates[2] -ForegroundColor Blue
    Write-Host $updates[1] -ForegroundColor Blue
    Write-Host $updates[0] -ForegroundColor Blue
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
            Write-Host "GoViTextures not found. Downloading from host... (651MB)"
            Invoke-WebRequest https://nerdhaus.asuscomm.com/AICLOUD1710948435/GoViTextures.7z -O $PSScriptRoot\valheim_Data\GoViTextures.7z
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
            Write-Host "Original textures not found. Downloading from host... (62.7MB)"
            Invoke-WebRequest https://nerdhaus.asuscomm.com/AICLOUD1695152053/originalTextures.7z -O $PSScriptRoot\valheim_Data\originalTextures.7z
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
        Invoke-WebRequest https://github.com/git-for-windows/git/releases/download/v2.34.1.windows.1/Git-2.34.1-64-bit.exe -O $PSScriptRoot\PackBin\git.exe
        Clear-Host
        Write-Host "Installing Git..." -ForegroundColor Green
        Write-Host "Please accept the installation.  Once complete," -ForegroundColor Green
        Start-Process "$PSScriptRoot\PackBin\git.exe" /SILENT
        Start-Sleep 20
        Wait-Process -Name git.exe
    }
    if (!(Test-Path -Path "C:\Program Files\Git\git-cmd.exe")) { #Verify Git is installed.
    }
}