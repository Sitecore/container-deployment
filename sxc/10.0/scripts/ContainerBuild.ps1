<<<<<<< Updated upstream
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
        #xc1-cxa depends on content that is built in xc-common. So it cannot be 'pulled' from a registry
        #when building the sample container images. Of course if you are using your own pre-build images then
        #you would not need to manipulate the docker-compose.build.yml to force a tag of 'latest' from the images
        if($workingDir.Contains("cxa")) {
            Write-Host "Make a copy of the CXA build yaml for build time"
            Copy-Item -Path '.\docker-compose.build.yml' -Destination '.\docker-compose.build.yml.bck' -Force -Verbose
            Copy-Item -Path '.\commerce.build.yml' -Destination '.\docker-compose.build.yml' -Force -Verbose
        }
        '[Building containers for] {0}' -f $PWD
        Write-Host "docker-compose --no-ansi --file (Join-Path $workingDir 'docker-compose.build.yml') build --parallel"
        & docker-compose --no-ansi -f (Join-Path $workingDir 'docker-compose.build.yml') build --parallel

        if ($LASTEXITCODE -gt 0) {
            Throw "Error in docker-compose build."
        }

        if($workingDir.Contains("cxa")) {
            Write-Host "-------> Return CXA build yaml to release default"
            Copy-Item -Path '.\docker-compose.build.yml.bck' -Destination '.\docker-compose.build.yml' -Force -Verbose
            Remove-Item -Path '.\docker-compose.build.yml.bck' -Force  -Verbose
        }
        Pop-Location
    }
=======
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
        #xc1-cxa depends on content that is built in xc-common. So it cannot be 'pulled' from a registry
        #when building the sample container images. Of course if you are using your own pre-build images then
        #you would not need to manipulate the docker-compose.build.yml to force a tag of 'latest' from the images
        if($workingDir.Contains("cxa")) {
            Write-Host "Make a copy of the CXA build yaml for build time"
            Copy-Item -Path '.\docker-compose.build.yml' -Destination '.\docker-compose.build.yml.bck' -Force -Verbose
            Copy-Item -Path '.\commerce.build.yml' -Destination '.\docker-compose.build.yml' -Force -Verbose
        }
        '[Building containers for] {0}' -f $PWD
        Write-Host "docker-compose --no-ansi --file (Join-Path $workingDir 'docker-compose.build.yml') build --parallel"
        & docker-compose --no-ansi -f (Join-Path $workingDir 'docker-compose.build.yml') build --parallel

        if ($LASTEXITCODE -gt 0) {
            Throw "Error in docker-compose build."
        }

        if($workingDir.Contains("cxa")) {
            Write-Host "-------> Return CXA build yaml to release default"
            Copy-Item -Path '.\docker-compose.build.yml.bck' -Destination '.\docker-compose.build.yml' -Force -Verbose
            Remove-Item -Path '.\docker-compose.build.yml.bck' -Force  -Verbose
        }
        Pop-Location
    }
>>>>>>> Stashed changes
