[cmdletbinding()]
param(

    [string]$wdpPath = '.'
)
<#
.SYNOPSIS
Uses the following packages to prepare artifacts for building Commerce Engine and BizFx container images.
- Sitecore.Commerce.Engine.OnPrem.Solr
- Sitecore.BizFx.OnPrem

.DESCRIPTION
Takes the Sitecore.Commerce.Engine.OnPrem.Solr and Sitecore.BizFx.OnPrem WDP's and expands the contents in to the
structure expected by the Sitecore XC container Docker files.

.PARAMETER wdpPath
Path to the location of the WDP files downloaded from dev.sitecore.net.

.EXAMPLE
PrepEngineContainerbuild.ps1

Expands the wdp files in to the respective container directories. Presumes the wdp files are located
in the same directory as this script.

.EXAMPLE
PrepEngineContainerbuild.ps1 -wdpPath 'C:\src\Commerce.Containers\downloads'

Expands the wdp files in to the respective container directories. The wdp files are located in 
the C:\src\Commerce.Containers\downloads directory.
#>

# the following information will be used to expand the wdps during this script execution.
$enginePackages = @"
[
  {
    "WDPs": [
      "Sitecore.Commerce.Engine.OnPrem.Solr"
    ],
    "SourceFolder": "Content/Website",
    "DestinationFolder": [ "xc-common/engine/wdp" ]
  },
  {
    "WDPs": [
      "Sitecore.BizFx.OnPrem"
    ],
    "SourceFolder": "Content/Website",
    "DestinationFolder": [ "xc-common/bizfx/wdp" ]
  }
]
"@

Write-Host "Expanding of Commerce Engine content started."

#Create a tmpDir
Write-Host "Creating temp directory"
$tmpDir = (Join-Path $PSScriptRoot 'tmp')
if (!(Test-Path $tmpDir)){
    New-Item -Path $tmpDir -ItemType Directory | Out-Null
} else {
    Remove-Item -Path $tmpDir -Recurse -Force
    New-Item -Path $tmpDir -ItemType Directory | Out-Null
}

#Cleanup in case this is run multiple times
$json = $enginePackages | ConvertFrom-Json
foreach ($j in $json) {
    Write-Host "Processing Cleanup" $j.DestinationFolder 
    foreach($dest in $j.DestinationFolder) { 
        #Delete the folder that hold the contents of the WDP files prior to starting in case it was run before
        $destinationFolder = Join-Path (Resolve-Path -Path "$PSScriptRoot\..") $dest
        if ((Test-Path $destinationFolder)){
            Remove-Item -Path $destinationFolder -Recurse -Force
        }
    }
}

#Process the contents of the WDP
$json = $enginePackages | ConvertFrom-Json
foreach ($j in $json) {
    Write-Host "Processing" $j.DestinationFolder 

    #Expand the wdp(s) and copy the contents to the destination directory
    foreach($wdp in $j.WDPs)
    {
        #first look for *.scwdp' files with the required WDP name, then if not found a non-scwdp file.
        $wFile = $wdp + '*.scwdp.zip'
        $wdpFile = Get-ChildItem -Path $wdpPath -Filter $wFile -Recurse | Sort-Object | Select-Object -First 1
        if (!$wdpFile) {
            $wFile = $wdp + '*.zip'
            $wdpFile = Get-ChildItem -Path $wdpPath -Filter $wFile -Recurse | Sort-Object | Select-Object -First 1
        }

        #WDP file found
        if (Test-Path $wdpFile.FullName) {
            $expandFolder = (Join-Path (Join-Path $tmpDir "$($wdpfile.BaseName)") "wdp")
            Write-Host "Expanding" $wdpfile.FullName "to" $expandFolder -ForegroundColor Yellow
            Expand-Archive -Path $wdpfile.FullName -DestinationPath $expandFolder -Force
            foreach($dest in $j.DestinationFolder) { 
                #Create a folder to hold the contents of the WDP files that will be copied in to the container image via the Dockerfile
                $destinationFolder = Join-Path (Resolve-Path -Path "$PSScriptRoot\..") $dest
                if (!(Test-Path $destinationFolder)){
                    New-Item -Path $destinationFolder -ItemType Directory | Out-Null
                }

                Write-Host -Message ("Copying folder {0}\{1} to {2}" -f $expandFolder, $j.SourceFolder, $destinationFolder) -ForegroundColor Yellow
                Copy-Item -Path (Join-Path (Join-Path $expandFolder $j.SourceFolder) "*") -Destination $destinationFolder -Recurse -Force
            }
        } else {
            throw "No Matching WDP file found: $wdp"
        }
    }
}

Write-Host "Expanding of Commerce Engine content complete."