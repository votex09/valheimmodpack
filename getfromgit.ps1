$bepdisabled = "$PSScriptRoot\BepInEx\plugins(disabled)"
$bepenabled = "$PSScriptRoot\BepInEx\plugins"
if ($args[0] -eq "-enable") {
    #check to see if plugins folder is disabled
    If (Test-Path -Path $bepdisabled) { #If plugins are disabled, rename folder so they are enabled.
        Write-Host "modsEnabled = false : Enabling Mods..."
        Rename-Item -Path $bepdisabled -NewName "plugins"
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
    #check to see if plugins folder is enabled
    If (Test-Path -Path $bepenabled) { #If plugins are enabled, rename folder so they are disabled.
        Write-Host "modsEnabled = true : Disabling Mods..."
        Rename-Item -Path $bepenabled -NewName "plugins(disabled)"
        pause
        exit
    }
    Else { #In all other cases, including when plugins are disabled:
        Write-Host "Mods are already disabled."
        pause
        exit
    }
}
if ($args[0] -eq "-update") {
    Clear-Host
    Write-Host "Downloading mod package from git..."
    Invoke-WebRequest https://github.com/votex09/valheimdirtbagmodpack/archive/main.zip -O $PSScriptRoot\PackBin\pack.zip
    & "$PSScriptRoot\PackBin\7z\7za.exe" x "$PSScriptRoot\PackBin\pack.zip" "-o$PSScriptRoot\PackBin\unpack\"
    Remove-Item -Path "$PSScriptRoot\BepInEx\Plugins\*"
    Robocopy ("$PSScriptRoot\PackBin\unpack\valheimdirtbagmodpack-main\ ") ("$PSScriptRoot ") /E
    Clear-Host
    Write-Host "Cleaning up..."
    Remove-Item "$PSscriptRoot\PackBin\Unpack\*" -Recurse
    Clear-Host
    Write-Host "Complete." -ForegroundColor Green
    Pause
    exit
}
