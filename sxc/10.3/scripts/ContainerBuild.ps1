[cmdletbinding()]
param(
    [string]$envRootPath = (Join-Path $PWD "..")
)
<#
.SYNOPSIS
Script to facilitate the creation of container images via docker-compose build. The artifacts produced are ImageName:latest,
where ImageName comes from the docker-compose.build.yml files.

.PARAMETER envRootPath 
The path to the parent (root) directory containing the .env files. If C:\download\XC\xc0 and C:\download\XC\xc1
contain .env files, then the envRootPath is C:\download\XC. Changes are performed in place
Default path is ../

.EXAMPLE
ContainerBuild.ps1 -envRootPath (Join-Path $PWD "..") 
#>

if (!(Get-Module -Name "powershell-yaml" -ListAvailable)){
    $r = Get-PSRepository
    Install-Module -Name "powershell-yaml" -Repository $r.name -Force
}

Get-ChildItem -Path "$envRootPath" -Include 'docker-compose.build.yml' -Recurse |
    ForEach-Object {
        $workingDir = Split-Path $_.FullName -Parent
        
        Push-Location -Path $workingDir
        
        '[Building containers for] {0}' -f $PWD
        Write-Host "docker-compose --ansi never --env-file build.env --file (Join-Path $workingDir 'docker-compose.build.yml') build"
        & docker-compose --ansi never --env-file build.env -f (Join-Path $workingDir 'docker-compose.build.yml') build

        if ($LASTEXITCODE -gt 0) {
            Throw "Error in docker-compose build."
        }

        Pop-Location
    }
