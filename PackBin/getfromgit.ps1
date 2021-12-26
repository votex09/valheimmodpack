$ProgressPreference = 'SilentlyContinue'
$bepdisabled = "$PSScriptRoot\winhttp.disabled"
$bepenabled = "$PSScriptRoot\winhttp.dll"
if (!(Test-Path -Path "$PSScriptRoot\BepInEx\Core\BepInEx.dll"))
{
    $bepvers = "Not Installed"
}
else
{
    $bepvers = (Get-Item ".\bepinex\core\bepinex.dll").VersionInfo.ProductVersion
}
$HDEnabled = "$PSScriptRoot\valheim_Data\HDEnabled"
$HDDisabled = "$PSScriptRoot\valheim_Data\HDDisabled"
$PackBin = "$PSScriptRoot\PackBin"
$ModVer = "$PSScriptRoot\PackBin\ModVer"
$pathtoConfig = "$PSScriptRoot\BepInEx\config"
$excludefile = "$PSScriptRoot\PackBin\git\valheimdirtbagmodpack\.git\info\exclude"
$availablelocks = @('manfredo52.CustomizableCamera','randyknapp.mods.equipmentandquickslots','virtuacode.valheim.equipwheel')
function Get-IniFile {
    <#
    .SYNOPSIS
    Read an ini file.
    
    .DESCRIPTION
    Reads an ini file into a hash table of sections with keys and values.
    
    .PARAMETER filePath
    The path to the INI file.
    
    .PARAMETER anonymous
    The section name to use for the anonymous section (keys that come before any section declaration).
    
    .PARAMETER comments
    Enables saving of comments to a comment section in the resulting hash table.
    The comments for each section will be stored in a section that has the same name as the section of its origin, but has the comment suffix appended.
    Comments will be keyed with the comment key prefix and a sequence number for the comment. The sequence number is reset for every section.
    
    .PARAMETER commentsSectionsSuffix
    The suffix for comment sections. The default value is an underscore ('_').
    .PARAMETER commentsKeyPrefix
    The prefix for comment keys. The default value is 'Comment'.
    
    .EXAMPLE
    Get-IniFile /path/to/my/inifile.ini
    
    .NOTES
    The resulting hash table has the form [sectionName->sectionContent], where sectionName is a string and sectionContent is a hash table of the form [key->value] where both are strings.
    This function is largely copied from https://stackoverflow.com/a/43697842/1031534. An improved version has since been pulished at https://gist.github.com/beruic/1be71ae570646bca40734280ea357e3c.
    #>
    
    param(
        [parameter(Mandatory = $true)] [string] $filePath,
        [string] $anonymous = 'NoSection',
        [switch] $comments,
        [string] $commentsSectionsSuffix = '_',
        [string] $commentsKeyPrefix = 'Comment'
    )

    $ini = @{}
    switch -regex -file ($filePath) {
        "^\[(.+)\]$" {
            # Section
            $section = $matches[1]
            $ini[$section] = @{}
            $CommentCount = 0
            if ($comments) {
                $commentsSection = $section + $commentsSectionsSuffix
                $ini[$commentsSection] = @{}
            }
            continue
        }

        "^(;.*)$" {
            # Comment
            if ($comments) {
                if (!($section)) {
                    $section = $anonymous
                    $ini[$section] = @{}
                }
                $value = $matches[1]
                $CommentCount = $CommentCount + 1
                $name = $commentsKeyPrefix + $CommentCount
                $commentsSection = $section + $commentsSectionsSuffix
                $ini[$commentsSection][$name] = $value
            }
            continue
        }

        "^(.+?)\s*=\s*(.*)$" {
            # Key
            if (!($section)) {
                $section = $anonymous
                $ini[$section] = @{}
            }
            $name, $value = $matches[1..2]
            $ini[$section][$name] = $value
            continue
        }
    }

    return $ini
}
Function Get-DLMethod ($xname, $xmethod, $xurl, $xversion, $special, $urlsuffix)
{
    switch ($xmethod)
    {
        "directunpack_thunderstore" #==============================================================================================
        {
            $download_url = $xurl.Replace("/package/", "/package/download/") + "/$xversion"
            #check if the file is already downloaded
            if (!(Test-Path -Path "$PackBin\ModArchive\$xname.zip"))
            {
                #download the file
                $filesize = (((Invoke-WebRequest -Uri $download_url -Method Head).Headers.'Content-Length') / 1024 / 1024).ToString("0.00") + " MB"
                $download_result = Invoke-WebRequest -Uri $download_url -OutFile "$PackBin\ModArchive\$xname.zip" -PassThru
                if ($download_result.StatusCode -eq 200)
                {
                    Write-Host "$xname (v.$xversion) successfully downloaded from valheim.thunderstore.io ($filesize)" -ForegroundColor Green
                }
                else
                {
                    Write-Host "Downloading $xname (v.$xversion) from valheim.thunderstore.io Failed" -ForegroundColor Red
                    Write-Host "Error code: $($download_result.StatusCode)" -ForegroundColor Red
                }
            }
            else
            {
                Write-Host "$xname (v.$xversion) already exists" -ForegroundColor Cyan
            }
            #unpack the file
            & "$PSScriptRoot\PackBin\7z\7za.exe" x "$PackBin\ModArchive\$xname.zip" "-o$PSScriptRoot\BepInEx\plugins\$xname" -aoa *> $null
            #delete the archive on error
            if ($? -eq $false)
            {
                Remove-Item -Path "$PackBin\ModArchive\$xname.zip"
                Write-Host "Unable to extract mod archive - please update again to attempt to correct this." -ForegroundColor Red
            }
            if($? -eq $true)
            {
                New-Item -Path "$ModVer\$xname" -ItemType File -Value "$xversion" -Force
            }
        }
        "directunpack_thunderstore_root" #==============================================================================================
        {
            $download_url = $xurl.Replace("/package/", "/package/download/") + "/$xversion"
            #check if the file is already downloaded
            if (!(Test-Path -Path "$PackBin\ModArchive\$xname.zip"))
            {
                #download the file
                $filesize = (((Invoke-WebRequest -Uri $download_url -Method Head).Headers.'Content-Length') / 1024 / 1024).ToString(".00") + " MB"
                $download_result = Invoke-WebRequest -Uri $download_url -OutFile "$PackBin\ModArchive\$xname.zip" -PassThru
                if ($download_result.StatusCode -eq 200)
                {
                    Write-Host "$xname (v.$xversion) successfully downloaded from valheim.thunderstore.io ($filesize)" -ForegroundColor Green
                }
                else
                {
                    Write-Host "Downloading $xname (v.$xversion) from valheim.thunderstore.io Failed" -ForegroundColor Red
                    Write-Host "Error code: $($download_result.StatusCode)" -ForegroundColor Red
                }
            }
            else
            {
                Write-Host "$xname (v.$xversion) already exists" -ForegroundColor Cyan
            }
            #unpack the file
            & "$PSScriptRoot\PackBin\7z\7za.exe" x "$PackBin\ModArchive\$xname.zip" "-o$PSScriptRoot" -aoa *> $null
            #delete the archive on error
            if ($? -eq $false)
            {
                Remove-Item -Path "$PackBin\ModArchive\$xname.zip"
                Write-Host "Unable to extract mod archive - please update again to attempt to correct this." -ForegroundColor Red
            }
            if($? -eq $true)
            {
                New-Item -Path "$ModVer\$xname" -ItemType File -Value "$xversion" -Force
            }
        }
        "raw" #==============================================================================================
        {
            $download_url = $xurl + ($mod.value.urlsuffix).Replace("<Vers>", "/$xversion")
            #check if the file is already downloaded
            if (!(Test-Path -Path "$PackBin\ModArchive\$xname.dll"))
            {
                #download the file
                $filesize = (((Invoke-WebRequest -Uri $download_url -Method Head).Headers.'Content-Length') / 1024 / 1024).ToString(".00") + " MB"
                $download_result = Invoke-WebRequest -Uri $download_url -OutFile "$PackBin\ModArchive\$xname.dll" -PassThru
                if($? -eq $true)
                {
                    New-Item -Path "$ModVer\$xname" -ItemType File -Value "$xversion" -Force
                }
                if ($download_result.StatusCode -eq 200)
                {
                    Write-Host "$xname (v.$xversion) successfully downloaded from $xurl ($filesize)" -ForegroundColor Green
                }
                else
                {
                    Write-Host "Downloading $xname (v.$xversion) from $xurl Failed" -ForegroundColor Red
                    Write-Host "Error code: $($download_result.StatusCode)" -ForegroundColor Red
                }
            }
            else
            {
                Write-Host "$xname (v.$xversion) already exists" -ForegroundColor Cyan
            }
            Copy-Item -Path "$PackBin\ModArchive\$xname.dll" -Destination "$PSScriptRoot\BepInEx\plugins\$xname.dll" -Force -Verbose
        }
        "directunpack_github" #==============================================================================================
        {
            $download_url = $xurl + "/releases/download/$xversion/$xname" + "_" + "v$xversion.zip"
            #check if the file is already downloaded
            if (!(Test-Path -Path "$PackBin\ModArchive\$xname.zip"))
            {
                #download the file
                $filesize = (((Invoke-WebRequest -Uri $download_url -Method Head).Headers.'Content-Length') / 1024 / 1024).ToString(".00") + " MB"
                $download_result = Invoke-WebRequest -Uri $download_url -OutFile "$PackBin\ModArchive\$xname.zip" -PassThru
                if ($download_result.StatusCode -eq 200)
                {
                    Write-Host "$xname (v.$xversion) successfully downloaded from github  ($filesize)" -ForegroundColor Green
                }
                else
                {
                    Write-Host "Downloading $xname (v.$xversion) from github Failed" -ForegroundColor Red
                    Write-Host "Error code: $($download_result.StatusCode)" -ForegroundColor Red
                }
            }
            else
            {
                Write-Host "$xname (v.$xversion) already exists" -ForegroundColor Cyan
            }
            #unpack the file
            & "$PSScriptRoot\PackBin\7z\7za.exe" x "$PackBin\ModArchive\$xname.zip" "-o$PSScriptRoot\BepInEx\plugins\$xname" -aoa *> $null
            #delete the archive on error
            if ($? -eq $false)
            {
                Remove-Item -Path "$PackBin\ModArchive\$xname.zip"
                Write-Host "Unable to extract mod archive - please update again to attempt to correct this." -ForegroundColor Red
            }
            if($? -eq $true)
            {
                New-Item -Path "$ModVer\$xname" -ItemType File -Value "$xversion" -Force
            }

        }
        "git" #==============================================================================================
        {
            Write-Host "$xname (v.$xversion) exists as part of the git repository" -ForegroundColor Magenta
        }
        "directunpack_thunderstore_bepinex" #==============================================================================================
        {
            $download_url = $xurl.Replace("/package/", "/package/download/") + "/$xversion"
            #check if the file is already downloaded
            if (!(Test-Path -Path "$PackBin\ModArchive\$xname.zip"))
            {
                #download the file
                $filesize = (((Invoke-WebRequest -Uri $download_url -Method Head).Headers.'Content-Length') / 1024 / 1024).ToString("0.00") + " MB"
                $download_result = Invoke-WebRequest -Uri $download_url -OutFile "$PackBin\ModArchive\$xname.zip" -PassThru
                if ($download_result.StatusCode -eq 200)
                {
                    Write-Host "$xname (v.$xversion) successfully downloaded from valheim.thunderstore.io ($filesize)" -ForegroundColor Green
                }
                else
                {
                    Write-Host "Downloading $xname (v.$xversion) from valheim.thunderstore.io Failed" -ForegroundColor Red
                    Write-Host "Error code: $($download_result.StatusCode)" -ForegroundColor Red
                }
            }
            else
            {
                Write-Host "$xname (v.$xversion) already exists" -ForegroundColor Cyan
            }
            #unpack the file
            & "$PSScriptRoot\PackBin\7z\7za.exe" x "$PackBin\ModArchive\$xname.zip" "-o$PSScriptRoot\BepInEx\unpack\$xname" -aoa *> $null
            if (!(Test-Path -Path "$PSScriptRoot\BepInEx\unpack\$xname"))
            {
                New-Item -Path "$PSScriptRoot\BepInEx\unpack\$xname" -ItemType Directory
            }
            Copy-Item -Path "$PSScriptRoot\BepInEx\unpack\$xname\BepInExPack_Valheim\*" -Destination "$PSScriptRoot\" -Recurse -Force
            Remove-Item -Path "$PSScriptRoot\BepInEx\unpack\" -Recurse -Force
            #delete the archive on error
            if ($? -eq $false)
            {
                Remove-Item -Path "$PackBin\ModArchive\$xname.zip"
                Write-Host "Unable to extract mod archive - please update again to attempt to correct this." -ForegroundColor Red
            }
            if($? -eq $true)
            {
                New-Item -Path "$ModVer\$xname" -ItemType File -Value "$xversion" -Force
            }
        }
    }
}
if ($args[0] -eq "-enable") 
{
    #check to see if plugins are disabled
    If (Test-Path -Path $bepdisabled) 
    { #If plugins are disabled, rename winhttp so they are enabled.
        Write-Host "modsEnabled = false : Enabling Mods..."
        Rename-Item -Path $bepdisabled -NewName "winhttp.dll"
        pause
        exit
    }
    Else 
    { #In all other cases, including when plugins are enabled:
        Write-Host "Mods are already enabled."
        pause
        exit
    }
}
if ($args[0] -eq "-disable") 
{
    #check to see if plugins are enabled
    If (Test-Path -Path $bepenabled) 
    { #If plugins are enabled, rename winhttp so they are disabled.
        Write-Host "modsEnabled = true : Disabling Mods..."
        Rename-Item -Path $bepenabled -NewName "winhttp.disabled"
        pause
        exit
    }
    Else 
    { #In all other cases, including when plugins are disabled:
        Write-Host "Mods are already disabled."
        pause
        exit
    }
}
if ($args[0] -eq "-full") 
{
    Clear-Host
    Write-Host "This is disabled for now. Please use update instead." -ForegroundColor Red
    pause
    <# If (Test-Path -Path $bepdisabled) 
    { #If plugins are disabled, rename winhttp so they are enabled.
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
    Pause #>
    exit
}
if ($args[0] -eq "-checkstatus") 
{
    if ((Test-Path -Path "C:\Program Files\Git\git-cmd.exe"))
    {
        Write-Host "Git is installed." -ForegroundColor Green
        git -C ("$PSScriptRoot\PackBin\git\valheimdirtbagmodpack\ ") remote update *> $null
        git -C ("$PSScriptRoot\PackBin\git\valheimdirtbagmodpack\ ") status -uno | Out-File -FilePath "$PSScriptRoot\PackBin\gitstatus.txt"
        $updatemessage = Get-Item -Path "$PSScriptRoot\PackBin\gitstatus.txt" | Get-Content -Tail 5
        Write-Host $updatemessage[1].Replace("fast-forwarded.", "updated.").Replace("branch", "modpack version") -ForegroundColor Cyan
        $vers = git -C ("$PSScriptRoot\PackBin\git\valheimdirtbagmodpack\ ") rev-list --count origin/main 
        Write-Host "Current Version : $vers/$bepvers-- Update Log:`n"
        git -C ("$PSScriptRoot\PackBin\git\valheimdirtbagmodpack\ ") log origin/main --no-merges --pretty='format:%cs | %ch | %s' | Out-File -FilePath "$PSScriptRoot\PackBin\gitlog.txt"
        $logshort = Get-Item -Path "$PSScriptRoot\PackBin\gitlog.txt" | Get-Content -Head 6
        Write-Host $logshort[0] -ForegroundColor Blue
        Write-Host $logshort[1] -ForegroundColor Blue
        Write-Host $logshort[2] -ForegroundColor Blue
        Write-Host $logshort[3] -ForegroundColor Blue
        Write-Host $logshort[4] -ForegroundColor Blue
        Write-Host $logshort[5] -ForegroundColor Blue
    }
    else
    {
        Write-Host "Git is not installed." -ForegroundColor Red 
    }
    <#
    if (Test-Path -Path $PSScriptRoot\PackBin\Version) 
    {
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
    Write-Host "`n=========================`n"

    If (Test-Path -Path $bepdisabled) 
    { #If plugins are disabled.
        Write-Host "Mods are currently DISABLED" -ForegroundColor Red
    }
    If (Test-Path -Path $bepenabled) 
    { #If plugins are enabled.
        Write-Host "Mods are currently ENABLED" -ForegroundColor Green
    }
    If ((Test-Path -Path $bepenabled) -eq $false -And (Test-Path -Path $bepdisabled) -eq $false) 
    { #If plugins are not installed.
        Write-Host "Mods are not Currently Installed" -ForegroundColor Yellow
    }
    If (Test-Path -Path $HDEnabled) 
    { #If HD is enabled.
        Write-Host "HD Textures are currently ENABLED" -ForegroundColor Green
    }
    If (test-path -path $HDDisabled) 
    { #If HD is disabled.
        Write-Host "HD Textures are currently DISABLED" -ForegroundColor Red
    }
    If ((Test-Path -Path $HDEnabled) -eq $false -And (Test-Path -Path $HDDisabled) -eq $false) 
    { #If HD is not installed.
        Write-Host "HD Textures are not Currently Installed" -ForegroundColor Yellow
    }
}
<#
if ($args[0] -eq "-enableHD") 
{
    #check to see if textures are disabled
    if ((Test-Path -Path $HDDisabled) -eq $false -And (Test-Path -Path $HDEnabled) -eq $false) 
    { #If HD is not installed.
        New-Item -Path $HDDisabled -Type file
    }
    If (Test-Path -Path $HDDisabled) 
    { #If textures are disabled, rename file so they are enabled.
    Rename-Item -Path $HDDisabled -NewName "HDEnabled"
        If (!(Test-Path -Path $PSScriptRoot\valheim_Data\GoViTextures.7z)) 
        { #If GoViTextures.7z is not present, download it.
            Write-Host "GoViTextures not found. Downloading from host... (651.54MB)"
            #Invoke-WebRequest "https://votex09.tonidoid.com/core/downloadfile?filepath=N%3A%5CGoViTextures%2E7z&filename=GoViTextures.7z&disposition=attachment" -O $PSScriptRoot\valheim_Data\GoViTextures.7z
        }
        Clear-Host
        Write-Host "HDTextures = false : Enabling HD Textures..."
        & "$PSScriptRoot\PackBin\7z\7za.exe" x "$PSScriptRoot\valheim_Data\GoViTextures.7z" "-o$PSScriptRoot\valheim_Data\" -aoa
        exit
    }
    Else 
    { #In all other cases, including when textures are enabled:
        Write-Host "HD textures are already enabled."
        pause
        exit
    }
}
if ($args[0] -eq "-disableHD") 
{
    #check to see if textures are enabled
    if ((Test-Path -Path $HDDisabled) -eq $false -And (Test-Path -Path $HDEnabled) -eq $false) 
    { #If HD is not installed.
        New-Item -Path $HDEnabled -Type file
    }
    If (Test-Path -Path $HDEnabled) 
    { #If textures are enabled, rename file so they are disabled.
    Rename-Item -Path $HDEnabled -NewName "HDDisabled"
        If (!(Test-Path -Path $PSScriptRoot\valheim_Data\originalTextures.7z)) 
        { #If originalTextures.7z is not present, download it.
            Write-Host "Original textures not found. Downloading from host... (62.73MB)"
            #Invoke-WebRequest "https://votex09.tonidoid.com/core/downloadfile?filepath=N%3A%5CoriginalTextures%2E7z&filename=originalTextures.7z&disposition=attachment" -O $PSScriptRoot\valheim_Data\originalTextures.7z
        }
        Clear-Host
        Write-Host "HDTextures = true : Disabling HD Textures..."
        & "$PSScriptRoot\PackBin\7z\7za.exe" x "$PSScriptRoot\valheim_Data\originalTextures.7z" "-o$PSScriptRoot\valheim_Data\" -aoa
        exit
    }
    Else 
    { #In all other cases, including when textures are disabled:
        Write-Host "HD textures are already disabled."
        pause
        exit
    }
}
#>
if ($args[0] -eq "-update") 
{
    #get ini file content as a dictionary
    $config = Get-IniFile "$PackBin\pack.ini"
    #create needed directories if they don't exist
    if (!(Test-Path -Path $PSScriptRoot\PackBin\ModVer)) 
    {
        New-Item -Path $PSScriptRoot\PackBin\ModVer -Type directory
    }
    if (!(Test-Path -Path $PSScriptRoot\PackBin\ModArchive))
    {
        New-Item -Path $PSScriptRoot\PackBin\ModArchive -Type directory
    }
    #get the filename and content of each file in .\PackBin\ModVer and store them in a dictionary
    $localModList = @{};
    $ModName = Get-ChildItem -Path $ModVer -File
    for ($i = 0; $i -lt $ModName.Count; $i++)
    {
        $localModList.Add("$($ModName[$i])", (Get-Content -Path "$ModVer/$($ModName[$i])"))
    }
    #check to see if git is installed
    if (!(Test-Path -Path "$PSScriptRoot\PackBin\git.exe")) #If git is not downloaded, download it.
    { 
        clear-host
        Write-Host "Git not found. Downloading from host... " -ForegroundColor Yellow
        if (!(Test-Path -Path "$PSScriptRoot\PackBin\")) 
        {
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
    if ((Test-Path -Path "C:\Program Files\Git\git-cmd.exe")) #Verify Git is installed.
    { 
        Clear-Host
        #check to see if user locked configs
        $l = $false
        for ($i = 0; $i -lt $availablelocks.Count; $i++) 
        {
            $SEL = Select-String -Path $excludefile -Pattern "$($availablelocks[$i])"
            if ($null -ne $SEL) 
            {
                $l = $true
            }
        }
        #if user locked configs, copy configs to PackBin folder
        if ($l -eq $true) 
        {
            for ($i =0; $i -lt $availablelocks.Count; $i++) 
            {
                Copy-Item -Path "$pathtoConfig\$($availablelocks[$i]).cfg" -Destination "$PSScriptRoot\PackBin\"
            }
            Write-Host "Config locks found. Preserving user configs..." -ForegroundColor Green
        }
        Write-Host "Git found." -ForegroundColor Green
        foreach ($mod in $config.GetEnumerator())
        {
            #Write-Host "$($mod.name)"
            if (!($localModList."$($mod.name)") -or ($localModList."$($mod.name)".version -ne $mod.value.version))
            {
                if ($config."$($mod.name)".specialinstall = "false")
                {
                    #normal install
                    Get-DLMethod $mod.name $mod.value.method $mod.value.url $mod.value.version $false $mod.value.urlsuffix
                }
                else
                {
                    #special install
                    Get-DLMethod $mod.name $mod.value.method $mod.value.url $mod.value.version $true $mod.value.urlsuffix
                }
            }
        }
        if (Test-Path -Path "$PSScriptRoot\PackBin\git\valheimdirtbagmodpack\winhttp.dll") 
        {
            If ((Test-Path -Path "$PSScriptRoot\BepinEx\Plugins\")) 
            {
                Remove-Item -Path "$PSScriptRoot\BepInEx\Plugins\*" -Recurse
            }
            #Clear-Host
            #$ModName[0] $localModList."$($ModName[0])"      #Example of retrieving the modname and its version from its entry in .\PackBin\ModVer
            #Write-Host $config."$($ModName[0])".url            #Example of retrieving the data from the pack.ini file
            #===========================================================================================================================
            #download mods that are missing or are out of date from ModVer based on the pack.ini file
            git -C ("$PSScriptRoot\PackBin\git\valheimdirtbagmodpack\ ") pull --progress
            #Start-Process -Filepath $PSScriptRoot\PackBin\git\pull.bat -NoNewWindow
            Robocopy ("$PSScriptRoot\PackBin\git\valheimdirtbagmodpack\ ") ("$PSScriptRoot ") /E /NFL /NDL /NJH /NJS /nc /ns
            #if user locked configs, move configs to config folder
            if ($l -eq $true) 
            {
                Write-Host "Reapplying user configs..." -ForegroundColor Green
                for ($i =0; $i -lt $availablelocks.Count; $i++) 
                {
                    Copy-Item -Path "$PSScriptRoot\PackBin\$($availablelocks[$i]).cfg" -Destination "$pathtoConfig\"
                    Remove-Item -Path "$PSScriptRoot\PackBin\$($availablelocks[$i]).cfg"
                }
            }
            Write-Host "Update complete." -ForegroundColor Green
            pause
            exit
        }
        else 
        {
            #check to see if user locked configs
            $l = $false
            for ($i = 0; $i -lt $availablelocks.Count; $i++) 
            {
                $SEL = Select-String -Path $excludefile -Pattern "$($availablelocks[$i])"
                if ($null -ne $SEL) 
                {
                    $l = $true
                }
            }
            #if user locked configs, copy configs to PackBin folder
            if ($l -eq $true) 
            {
                for ($i =0; $i -lt $availablelocks.Count; $i++) 
                {
                    Copy-Item -Path "$pathtoConfig\$($availablelocks[$i]).cfg" -Destination "$PSScriptRoot\PackBin\"
                }
                Write-Host "Config locks found. Preserving user configs..." -ForegroundColor Green
            }
            #Clear-Host
            #$ModName[0] $localModList."$($ModName[0])"      #Example of retrieving the modname and its version from its entry in .\PackBin\ModVer
            #Write-Host $config."$($ModName[0])".url            #Example of retrieving the data from the pack.ini file
            #===========================================================================================================================
            #download mods that are missing or are out of date from ModVer based on the pack.ini file
            foreach ($mod in $config.GetEnumerator())
            {
                #Write-Host "$($mod.name)"
                if (!($localModList."$($mod.name)") -or ($localModList."$($mod.name)".version -ne $mod.value.version))
                {
                    if ($config."$($mod.name)".specialinstall = "false")
                    {
                        #normal install
                        Get-DLMethod $mod.name $mod.value.method $mod.value.url $mod.value.version $false $mod.value.urlsuffix
                    }
                    else
                    {
                        #special install
                        Get-DLMethod $mod.name $mod.value.method $mod.value.url $mod.value.version $true $mod.value.urlsuffix
                    }
                }
            }
            Write-Host "Pack not found. Cloning repository..." -ForegroundColor Yellow
            New-Item -Path "$PSScriptRoot\PackBin\git\valheimdirtbagmodpack" -Type directory
            git -C ("$PSScriptRoot\PackBin\git\ ") clone ("https://github.com/votex09/valheimdirtbagmodpack") --progress
            #Start-Process -Filepath $PSScriptRoot\PackBin\git\clone.bat -NoNewWindow
            If ((Test-Path -Path "$PSScriptRoot\BepinEx\Plugins")) 
            {
                Remove-Item -Path "$PSScriptRoot\BepInEx\Plugins\*" -Recurse
            }
            Robocopy ("$PSScriptRoot\PackBin\git\valheimdirtbagmodpack\ ") ("$PSScriptRoot ") /E /NFL /NDL /NJH /NJS /nc /ns
            #if user locked configs, move configs to config folder
            if ($l -eq $true) 
            {
                Write-Host "Reapplying user configs..." -ForegroundColor Green
                for ($i =0; $i -lt $availablelocks.Count; $i++) 
                {
                    Copy-Item -Path "$PSScriptRoot\PackBin\$($availablelocks[$i]).cfg" -Destination "$pathtoConfig\"
                    Remove-Item -Path "$PSScriptRoot\PackBin\$($availablelocks[$i]).cfg"
                }
            }
            Write-Host "Preliminary Update complete. Please run Update again." -ForegroundColor Green
            pause
            exit
        }
    }
}
if ($args[0] -eq "-logs") 
{
    Clear-Host
    Import-Csv "$PSScriptroot\PackBin\gitlog.txt" -delimiter `| -Header 'Date', 'TimeStamp', 'Commit Message' | Out-Gridview -Wait -Title 'Git Commit Log'
    exit
}
if ($args[0] -eq "-cfglock") 
{
    $menumode = "continue"
    while ($menumode -eq "continue") 
    {
        Clear-Host
        if ((Test-Path -Path "$PSScriptRoot\PackBin\git\valheimdirtbagmodpack\.git\info\exclude")) 
        {
            Write-Host "=============================`nConfig Lock Menu`n============================="
            Write-Host "This menu locks certain configs from changing on update.`nThis is the only way for keybindings for mods to persist between updates.`nEnter [X] to exit`n`n" -ForegroundColor Blue
            Write-Host "Current Locked Configs:"
            #retrieve list of locked configs from file as array@()
            $locked = @(Get-Content -Path "$PSScriptRoot\PackBin\git\valheimdirtbagmodpack\.git\info\exclude")
            #loop through list and print to screen
            for ($i = 0; $i -lt $locked.Count; $i++) 
            {
                Write-Host "$($locked[$i])" -ForegroundColor Yellow
            }
            Write-Host "`n------------------------------`n"
            for ($i = 0; $i -lt $availablelocks.Count; $i++) 
            {
                Write-Host "[$i]$($availablelocks[$i])"
            }
            $usermode = Read-Host "`n`n[L]ock or [U]nlock a config?"
            if ($usermode -eq "x" -or $usermode -eq "X") 
            {
                exit
            }
            $userselection = Read-Host "Enter the number of the config you wish to lock/unlock (Or [A] for all)"
            if ($userselection -eq "x" -or $userselection -eq "X") 
            {
                exit
            }
            #lock config
            if ($usermode -eq "l" -or $usermode -eq "L") 
            {
                if ($userselection -eq "a" -or $userselection -eq "A") 
                {
                    for ($i = 0; $i -lt $availablelocks.Count; $i++) 
                    {
                        $SEL = Select-String -Path $excludefile -Pattern "$($availablelocks[$i])"
                        if ($null -ne $SEL) 
                        {
                            Write-Host "$($availablelocks[$i]) was already locked."
                            Start-Sleep 1
                        }
                        else 
                        {
                            Write-Host "Locking $($availablelocks[$i])..."
                            Add-Content -Path $excludefile -Value $availablelocks[$i]
                        }
                    }
                }
                else 
                {
                    #check if array index is out of bounds
                    if ($userselection -gt $availablelocks.Count -or $userselection -lt 0) 
                    {
                        Write-Host "Invalid selection."
                        Start-Sleep 1
                    }
                    else 
                    {
                        $SEL = Select-String -Path $excludefile -Pattern "$($availablelocks[$userselection])"
                        if ($null -ne $SEL) 
                        {
                            Write-Host "$($availablelocks[$userselection]) was already locked."
                            Start-Sleep 1
                        }
                        else 
                        {
                            Write-Host "Locking $($availablelocks[$userselection])..."
                            Add-Content -Path $excludefile -Value "$($availablelocks[$userselection])"
                            Start-Sleep 1
                        }
                    }
                }
            }
            #unlock config
            if ($usermode -eq "u" -or $usermode -eq "U") 
            {
                if ($userselection -eq "a" -or $userselection -eq "A") 
                {
                    for ($i = 0; $i -lt $availablelocks.Count; $i++) 
                    {
                        $SEL = Select-String -Path $excludefile -Pattern "$($availablelocks[$i])"
                        if ($null -eq $SEL) 
                        {
                            Write-Host "$($availablelocks[$i]) was already unlocked."
                            Start-Sleep 1
                        }
                        else 
                        {
                            Write-Host "Unlocking $($availablelocks[$i])..."
                            ((Get-Content -Path $excludefile) -replace "$($availablelocks[$i])", "") | Set-Content -Path $excludefile
                            Start-Sleep 1
                        }
                    }
                }
                else 
                {
                    #check if array index is out of bounds
                    if ($userselection -gt $availablelocks.Count -or $userselection -lt 0) 
                    {
                        Write-Host "Invalid selection."
                        Start-Sleep 1
                    }
                    else 
                    {
                        $SEL = Select-String -Path $excludefile -Pattern "$($availablelocks[$userselection])"
                        if ($null -eq $SEL) 
                        {
                            Write-Host "$($availablelocks[$userselection]) was already unlocked."
                            Start-Sleep 1
                        }
                        else 
                        {
                            Write-Host "Unlocking $($availablelocks[$userselection])..."
                            ((Get-Content -Path $excludefile) -replace "$($availablelocks[$userselection])", "") | Set-Content -Path $excludefile
                            Start-Sleep 1
                        }
                    }
                }
            }
        }
        else 
        {
            New-Item -Path "$PSScriptRoot\PackBin\git\valheimdirtbagmodpack\.git\info\exclude" -Type file
        }
        (Get-Content $excludefile) | Where-Object {$_.trim() -ne "" } | set-content $excludefile
        Start-Sleep 2
    }
}
if ($args[0] -eq "-enableHD") 
{
    Clear-Host
    Write-Host "Not Implemented yet." -ForegroundColor Red
    pause
}
if ($args[0] -eq "-disableHD") 
{
    Clear-Host
    Write-Host "Not Implemented yet." -ForegroundColor Red
    pause
}