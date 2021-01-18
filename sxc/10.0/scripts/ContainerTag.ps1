<<<<<<< Updated upstream
[cmdletbinding()]
param(
    [string]$envRootPath = (Join-Path $PWD ".."),
    [Parameter(Mandatory)]
    [string]$tag,
    [switch]$keepSourceTag
)

<#
.SYNOPSIS
Script to facilitate the tagging of container images via docker-compose build.

.PARAMETER envRootPath 
The path to the parent (root) directory containing the .env files. If C:\download\XC\xc0 and C:\download\XC\xc1
contain .env files, then the envRootPath is C:\download\XC. Changes are performed in place
Default path is ../

.PARAMETER tag 
[Parameter(Mandatory)]
This is the tag for your docker container image. Typically it includes:
Repository -> ideftdevacr.azurecr.io
Namespace  -> experimental
Image Name -> sitecore-xc-engine, found in the build yml files
Version    -> 10.0.0.60234.10194-pbi-422197-0035-10.0.17763.1282-ltsc2019, a version identifier. This can be anything you like
              Be aware that there can only ever be one. If you have a version 10.0.0-ltsc2019 then this will only ever point to one
              'container'. If you tag another container image with 10.0.0-ltsc2019, the old one is lost.

.PARAMETER keepSourceTag
A degug switch to prevent the removal of the 'latest' tag allowing for multiple runs with out rebuilding the container images.

.EXAMPLE
ContainerTag.ps1 -envRootPath (Join-Path $PWD "..") `
                 -tag "ideftdevacr.azurecr.io/experimental/sitecore-xc-engine:10.0.0.60234.10194-pbi-422197-0035-10.0.17763.1282-ltsc2019"
#>

if (!(Get-Module -Name "powershell-yaml" -ListAvailable)){
    $r = Get-PSRepository
    Install-Module -Name "powershell-yaml" -Repository $r.name -Force
}

$ymlFiles = Get-ChildItem -Path "$envRootPath" -Include 'docker-compose.build.yml' -Recurse
ForEach ($ymlFile in $ymlFiles ) {
    $workingDir = Split-Path $ymlFile.FullName -Parent
    Push-Location -Path $workingDir
    $buildYaml = Get-Content $ymlFile.FullName | Out-String | ConvertFrom-Yaml
    foreach ($service in $buildYaml.services.values) {
        $dockerRepository = $service.image

        Write-Host "Docker Repository: $dockerRepository" -InformationAction Continue

        $sourceTag = "$($dockerRepository):latest"
        foreach ($tag in $tags) {
            Write-Host "Tagging: $sourceTag with $tag" -InformationAction Continue
            & docker image tag $sourceTag $tag

            if ($LASTEXITCODE -gt 0){
                Throw "Error in docker.exe tagging."
            }
        }

        if ($keepSourceTag) {
            Write-Host "Keeping Tag: $sourceTag" -InformationAction Continue
        } else {
            Write-Host "Removing Tag: $sourceTag" -InformationAction Continue
            & docker rmi $sourceTag

            if ($LASTEXITCODE -gt 0){
                Throw "Error removing docker tag."
            }
        }
    }

    Pop-Location
}
=======
[cmdletbinding()]
param(
    [string]$envRootPath = (Join-Path $PWD ".."),
    [Parameter(Mandatory)]
    [string]$tag,
    [switch]$keepSourceTag
)

<#
.SYNOPSIS
Script to facilitate the tagging of container images via docker-compose build.

.PARAMETER envRootPath 
The path to the parent (root) directory containing the .env files. If C:\download\XC\xc0 and C:\download\XC\xc1
contain .env files, then the envRootPath is C:\download\XC. Changes are performed in place
Default path is ../

.PARAMETER tag 
[Parameter(Mandatory)]
This is the tag for your docker container image. Typically it includes:
Repository -> ideftdevacr.azurecr.io
Namespace  -> experimental
Image Name -> sitecore-xc-engine, found in the build yml files
Version    -> 10.0.0.60234.10194-pbi-422197-0035-10.0.17763.1282-ltsc2019, a version identifier. This can be anything you like
              Be aware that there can only ever be one. If you have a version 10.0.0-ltsc2019 then this will only ever point to one
              'container'. If you tag another container image with 10.0.0-ltsc2019, the old one is lost.

.PARAMETER keepSourceTag
A degug switch to prevent the removal of the 'latest' tag allowing for multiple runs with out rebuilding the container images.

.EXAMPLE
ContainerTag.ps1 -envRootPath (Join-Path $PWD "..") `
                 -tag "ideftdevacr.azurecr.io/experimental/sitecore-xc-engine:10.0.0.60234.10194-pbi-422197-0035-10.0.17763.1282-ltsc2019"
#>

if (!(Get-Module -Name "powershell-yaml" -ListAvailable)){
    $r = Get-PSRepository
    Install-Module -Name "powershell-yaml" -Repository $r.name -Force
}

$ymlFiles = Get-ChildItem -Path "$envRootPath" -Include 'docker-compose.build.yml' -Recurse
ForEach ($ymlFile in $ymlFiles ) {
    $workingDir = Split-Path $ymlFile.FullName -Parent
    Push-Location -Path $workingDir
    $buildYaml = Get-Content $ymlFile.FullName | Out-String | ConvertFrom-Yaml
    foreach ($service in $buildYaml.services.values) {
        $dockerRepository = $service.image

        Write-Host "Docker Repository: $dockerRepository" -InformationAction Continue

        $sourceTag = "$($dockerRepository):latest"
        foreach ($tag in $tags) {
            Write-Host "Tagging: $sourceTag with $tag" -InformationAction Continue
            & docker image tag $sourceTag $tag

            if ($LASTEXITCODE -gt 0){
                Throw "Error in docker.exe tagging."
            }
        }

        if ($keepSourceTag) {
            Write-Host "Keeping Tag: $sourceTag" -InformationAction Continue
        } else {
            Write-Host "Removing Tag: $sourceTag" -InformationAction Continue
            & docker rmi $sourceTag

            if ($LASTEXITCODE -gt 0){
                Throw "Error removing docker tag."
            }
        }
    }

    Pop-Location
}
>>>>>>> Stashed changes
