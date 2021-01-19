[cmdletbinding()]
param(

    [string]$jsonFile = (Join-Path '.' 'WDPMapping.json'),
    [string]$releaseZipPath = '.'
)
<#
.SYNOPSIS
Uses Commerce Release artifacts to prepare the environment for building container images based on XP and XC container images.

.DESCRIPTION
Takes the Sitecore Commerce release zip artifacts and expands the contents in to the structure expected by the Sitecore XC container Docker files.

.PARAMETER jsonFile
Path to the WDPMapping.json file that maps the WDP file content needed build a specific container image. 

.PARAMETER releaseZipPath
Path to the Sitecore XC release zip files downloaded from dev.sitecore.net. Both the Azure and WDP release files are required.

.EXAMPLE
PrepContainerbuild.ps1

Expands the release zip files in to the respective container directories. Presumes the WDPMapping.json and release zip files are located
in the same directory as this script.

.EXAMPLE
PrepContainerbuild.ps1 -jsonFile 'C:\src\Commerce.Containers' -releaseZipPath 'C:\src\Commerce.Containers\downloads'

Expands the release zip files in to the respective container directories. The WDPMapping.json is located in C:\src\Commerce.Containers
and release zip files are located in the C:\src\Commerce.Containers\downloads directory.
#>

#Check for the json file
if (Test-Path("$jsonFile"))
{
    #Create the tmpDir
    $tmpDir = (Join-Path $PSScriptRoot 'tmp')
    if (!(Test-Path $tmpDir)){
        New-Item -Path $tmpDir -ItemType Directory | Out-Null
    } else {
        Remove-Item -Path $tmpDir -Recurse -Force
        New-Item -Path $tmpDir -ItemType Directory | Out-Null
    }

    #Find the release zip archives and expand them into the tmpDir
    $releaseFound = 0
    $releaseZips = Get-ChildItem -Path $releaseZipPath -Filter "Sitecore.Commerce.*.zip" -Recurse
    foreach ($rZip in $releaseZips) {
        if ($rZip.Name -match '(.*WDP\.\d\d\d\d.*|.*Azure\.\d\d\d\d.*)') {
            Expand-Archive -Path $rZip.Fullname -DestinationPath $tmpDir -Force
            $releaseFound += 1
        }
    }

    if ($releaseFound -lt 2) {
        Throw 'Missing one or more Sitecore XC release zip files.'
    }

    $json = Get-Content "$jsonFile" | ConvertFrom-Json
    foreach ($j in $json) {
        Write-Host "Processing" $j.DestinationFolder 

        if((!($j | Get-Member "ToCopyFolder")) -and (!($j | Get-Member "ToCopyFiles"))) {
            Throw "There is no information on what content to copy to $j.DestinationFolder"
        }

        #Create a folder to hold the contents of the WDP files that will be copied in to the container image via the Dockerfile
        $destinationFolder = Join-Path (Resolve-Path -Path "$PSScriptRoot\..") $j.DestinationFolder
        if (!(Test-Path $destinationFolder)){
            New-Item -Path $destinationFolder -ItemType Directory | Out-Null
        } else {
            Remove-Item -Path $destinationFolder -Recurse -Force
            New-Item -Path $destinationFolder -ItemType Directory | Out-Null
        }

        #Expand the wdp(s) and copy the contents to the destination directory
        foreach($wdp in $j.WDPs)
        {
            #first look for *.scwdp' files with the required WDP name, then if not found a non-scwdp file.
            $wFile = $wdp + '*.scwdp.zip'
            $wdpFile = Get-ChildItem -Path $tmpDir -Filter $wFile -Recurse | Sort-Object | Select-Object -First 1
            if (!$wdpFile) {
                $wFile = $wdp + '*.zip'
                $wdpFile = Get-ChildItem -Path $tmpDir -Filter $wFile -Recurse | Sort-Object | Select-Object -First 1
            }
            
            #WDP file found
            if (Test-Path $wdpFile.FullName) {
                $expandFolder = (Join-Path (Join-Path (Split-Path -Path $wdpfile.FullName -Parent) "$($wdpfile.BaseName)") "wdp")
                Write-Host "Expanding" $wdpfile.FullName "to" $expandFolder -ForegroundColor Yellow
                Expand-Archive -Path $wdpfile.FullName -DestinationPath $expandFolder -Force

                #Determine what to copy where either a directory recursively or a specific set of files
                if($j | Get-Member "ToCopyFolder") {
                    Write-Host -Message ("Copying folder {0}\{1} to {2}" -f $expandFolder, $j.ToCopyFolder, $destinationFolder) -ForegroundColor Yellow
                    Copy-Item -Path (Join-Path (Join-Path $expandFolder $j.ToCopyFolder) "*") -Destination $destinationFolder -Recurse -Force
                }

                if($j | Get-Member "ToCopyFiles"){
                    Write-Host -Message ("Copying files {0}\{1} to {2}" -f $expandFolder, $j.ToCopyFiles, $destinationFolder) -ForegroundColor Yellow
                    $files = Get-ChildItem -Path (Join-Path $expandFolder "/*") -Filter $j.ToCopyFiles -Recurse

                    $nameMappings = ConvertTo-Json @()
                    if($j | Get-Member "NameMappings"){
                        $nameMappings = $j.NameMappings
                    }

                    foreach ($file in $files) {
                        $fileName = $($file.BaseName)
                        $nameMapping = $nameMappings | Where-Object { $_.Name -eq $($file.BaseName) } 
                        if($nameMapping -ne $null -and $nameMapping.NewName -ne ""){
                            $fileName = $($nameMapping.NewName)
                        }

                        $fileNameExtension = $($fileName) + $($file.Extension)
                        $fileDFolder = (Join-Path $destinationFolder $wdp)
                        if(!(Test-Path $fileDFolder)){
                            New-Item -Path $fileDFolder -ItemType Directory
                        }

                        $fileDPath = Join-Path $fileDFolder $fileNameExtension
                        Write-Host -Message ("Copying file {0} to {1}" -f $file, $fileDPath)
                        Copy-Item -Path (Join-Path $expandFolder $file) -Destination $fileDPath -Force
                    }
                }
            } else {
                throw "No Matching WDP file found: $wdp"
            }
        }
    }
} else {
    throw "No JSON file"
}

