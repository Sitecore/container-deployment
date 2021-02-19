[cmdletbinding()]
param(
    [string]$jsonFile = (Join-Path '.' 'configltsc2019.json'),
    [string]$envRootPath = (Join-Path $PWD ".."),
    [string]$altRegistry = '',
    [switch]$useLocalImages
)
<#
.SYNOPSIS
Script to facilitate updating the .env files for use in a docker-compose up and docker-compose build.

.PARAMETER jsonFile 
The path to the configltsc2019.json file. 
Default path is .\configltsc2019.json

.PARAMETER envRootPath 
The path to the parent (root) directory containg the .env files. If C:\download\XC\xc0 and C:\download\XC\xc1
contain .env files, then the envRootPath is C:\download\XC. Changes are performed in place
Default path is ..

.PARAMETER altRegistry
Overrides the registry value from the config json
Default is null

.PARAMETER useLocalImages
A switch to indicate whether latest local images should be used for container deployment.
If specified, XC_SITECORE_DOCKER_REGISTRY parameter will be cleared and XC_PACKAGES_TAG parameter will be set to 'latest'.

.EXAMPLE
UpdateEnvTag.ps1 -jsonFile 'C:\download\Commerce.Containers\scripts\configltsc2019.json' `
                 -envRootPath (Join-Path $PWD "..") 
#>

if (Test-Path("$jsonFile")) {

    #Read the config json that holds the values to be used to populate the environment files
    $json = Get-Content $jsonFile | Out-String | ConvertFrom-Json
    $containerConfigInfo = @{}
    foreach( $property in $json.psobject.properties.name )
    {
        $containerConfigInfo[$property] = $json.$property
    }

    if ([string]::IsNullOrEmpty($altRegistry)) {
        $registry = $($containerConfigInfo.scrdockerregistry)
    } else {
        $registry = $altRegistry
    }
    
    Get-ChildItem -Path $envRootPath -Include '*.env' -Recurse | `
    ForEach-Object {
        Write-Host "Updating [$_] file ..."
    
        $envContent = Get-Content -Path $_
    
        if ($useLocalImages) {
            $envContent = $envContent -replace "XC_SITECORE_DOCKER_REGISTRY=.*", "XC_SITECORE_DOCKER_REGISTRY="
            $envContent = $envContent -replace "XC_PACKAGES_TAG=.*", "XC_PACKAGES_TAG=latest"
        } else {
            $XC_SITECORE_DOCKER_REGISTRY = "XC_SITECORE_DOCKER_REGISTRY=$($registry)/$($containerConfigInfo.sxcproject)/"
            $envContent = $envContent -replace "XC_SITECORE_DOCKER_REGISTRY=.*", $XC_SITECORE_DOCKER_REGISTRY
            $XC_PACKAGES_TAG = "XC_PACKAGES_TAG=$($containerConfigInfo.customercommercetag)"
            $envContent = $envContent -replace "XC_PACKAGES_TAG=.*", $XC_PACKAGES_TAG
        }

        $BASE_SITECORE_DOCKER_REGISTRY = "BASE_SITECORE_DOCKER_REGISTRY=$($registry)/$($containerConfigInfo.baseproject)/"
        $envContent = $envContent -replace "BASE_SITECORE_DOCKER_REGISTRY=.*", $BASE_SITECORE_DOCKER_REGISTRY

        $XP_SITECORE_DOCKER_REGISTRY = "XP_SITECORE_DOCKER_REGISTRY=$($registry)/$($containerConfigInfo.sxpproject)/"
        $envContent = $envContent -replace "XP_SITECORE_DOCKER_REGISTRY=.*", $XP_SITECORE_DOCKER_REGISTRY

        $XP_SITECORE_TAG = "XP_SITECORE_TAG=$($containerConfigInfo.sxptag)"
        $envContent = $envContent -replace "XP_SITECORE_TAG=.*", $XP_SITECORE_TAG

        $XC_NONPRODUCTION_SITECORE_DOCKER_REGISTRY = "XC_NONPRODUCTION_SITECORE_DOCKER_REGISTRY=$($registry)/$($containerConfigInfo.sxcproject)/$($containerConfigInfo.nonproductionproject)/"
        $envContent = $envContent -replace "XC_NONPRODUCTION_SITECORE_DOCKER_REGISTRY=.*", $XC_NONPRODUCTION_SITECORE_DOCKER_REGISTRY

        $MODULES_SITECORE_DOCKER_REGISTRY = "MODULES_SITECORE_DOCKER_REGISTRY=$($registry)/$($containerConfigInfo.sxpproject)/$($containerConfigInfo.modulesproject)/"
        $envContent = $envContent -replace "MODULES_SITECORE_DOCKER_REGISTRY=.*", $MODULES_SITECORE_DOCKER_REGISTRY

        $SPE_SITECORE_TAG = "SPE_SITECORE_TAG=$($containerConfigInfo.spetag)"
        $envContent = $envContent -replace "SPE_SITECORE_TAG=.*", $SPE_SITECORE_TAG

        $SXA_SITECORE_TAG = "SXA_SITECORE_TAG=$($containerConfigInfo.sxatag)"
        $envContent = $envContent -replace "SXA_SITECORE_TAG=.*", $SXA_SITECORE_TAG

        $OS_IMAGE_TAG = "OS_IMAGE_TAG=$($containerConfigInfo.OS_IMAGE_TAG)" 
        $envContent = $envContent -replace "OS_IMAGE_TAG=.*", $OS_IMAGE_TAG

        #Microsoft has not yet update the tags for IIS iamges so we need to continue to use 2009 rather than the 20H2 tag
        if ($($containerConfigInfo.OS_IMAGE_TAG) -eq '20H2') {
            $OS_IMAGE_TAG_IIS = "OS_IMAGE_TAG_IIS=2009"
        } else {
            $OS_IMAGE_TAG_IIS = "OS_IMAGE_TAG_IIS=$($containerConfigInfo.OS_IMAGE_TAG)" 
        }
        write-host "UpdateEnvTag OS_IMAGE_TAG_IIS: $OS_IMAGE_TAG_IIS"
        $envContent = $envContent -replace "OS_IMAGE_TAG_IIS=.*", $OS_IMAGE_TAG_IIS

        Set-Content -Path $_ -Value $envContent -Force
    
        Write-Host ".env file [$_] has been updated"
    }
} else {
    throw "No JSON file"
}