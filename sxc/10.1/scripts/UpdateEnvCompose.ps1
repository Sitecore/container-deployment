[cmdletbinding()]
param(
    [string] $envRootPath = (Join-Path $PWD ".."),
    [Parameter(Mandatory)]
    [string] $braintreeEnvironment,
    [Parameter(Mandatory)]
    [string] $braintreeMerchantId,
    [Parameter(Mandatory)]
    [string] $braintreePublicKey,
    [Parameter(Mandatory)]
    [string] $braintreePrivateKey,
    [Parameter(Mandatory)]
    [string] $idCert,
    [Parameter(Mandatory)]
    [string] $licenseFilePath,
    [Parameter(Mandatory)]
    [string]$telerikKey,
    [Parameter(Mandatory)]
    [string]$idSecret,
    [Parameter(Mandatory)]
    [string]$xcIdSecret,
    [Parameter(Mandatory)]
    [string]$idPassword,
    [Parameter(Mandatory)]
    [string]$reportingApiKey,
    [ValidateSet("default", "process", "hyperv")]
    [string]$isolation = "process"
)
<#
.SYNOPSIS
Script to facilitate the updating of the .env files for use in a docker-compose up and docker-compose build.

.PARAMETER envRootPath 
The path to the parent (root) directory containg the .env files. If C:\download\XC\xc0 and C:\download\XC\xc1
contain .env files, then the envRootPath is C:\download\XC. Changes are performed in place
Default path is ..

.PARAMETER braintreeEnvironment 
[Parameter(Mandatory)]
The Braintree environment. E.G. sandbox or production

.PARAMETER braintreeMerchantId 
[Parameter(Mandatory)]
Your merchant ID for the Braintreepayment provider.

.PARAMETER braintreePublicKey 
[Parameter(Mandatory)]
The public key associated to your Braintree account.

.PARAMETER braintreePrivateKey
[Parameter(Mandatory)]
The private key associated to your Braintree account.

.PARAMETER idCert 
[Parameter(Mandatory)]
Identity Server certificate used to encryptdata.

.PARAMETER licenseFilePath 
[Parameter(Mandatory)]
Sitecore license file content converted to GZIP Compressed and Base64 encoded string.

.PARAMETER telerikKey
[Parameter(Mandatory)]
Symmetric key used by the Telerik web controls. Length: 64-128 characters

.PARAMETER idSecret
[Parameter(Mandatory)]
Shared secret between the Identity Server and client roles. Length: 64 characters

.PARAMETER xcIdSecret
[Parameter(Mandatory)]
The client ID assigned to Commerce Engine Connect for Sitecore Identity. This ID is used to identify the Commerce Engine Connect with Commerce Engine.

.PARAMETER idPassword
[Parameter(Mandatory)]
Password required to open the Identity Server certificate.

.PARAMETER reportingApiKey
[Parameter(Mandatory)]
Symetric key used to access the Sitecore XDB Reporting Web API. Length: 64-128 characters

.PARAMETER isolation
[ValidateSet("default", "process", "hyperv")]
Choose the isolation method. default will use the default method determiend by the OS, process will force process isolation, hyperv wil force hyperv isolation. To improve performance it is recommened to use "process" as isolation method for Windows 10 as default is hyperv.

.EXAMPLE
PS> UpdateEnvCompose.ps1 -envRootPath (Join-Path $PWD "..") `
                  -licenseFile "Location of your licence file" `
                  -braintreeEnvironment "sandbox" `
                  -braintreeMerchantId "Your merchant id" `
                  -braintreePublicKey "Your public key" `
                  -braintreePrivateKey "Your private key" `
                  -telerikKey "Your Telerik Encryption Key" `
                  -idCert "Your Sitecore Identity certificate" `
                  -idSecret "Your Sitecore Identity secret" `
                  -idPassword "Your Sitecore Identity password" `
                  -xcIdSecret "Your XC Connect Client Secret" `
                  -reportingApiKey "Your Sitecore Reporting API key"
#>

Import-Module (Join-Path $PSScriptRoot "ScriptSupport") -DisableNameChecking -Global

$license = ConvertToCompressedBase64String -Path $licenseFilePath

#Find all the .env files and updated them
Get-ChildItem -Path $envRootPath -Include '*.env' -Recurse | `
ForEach-Object {
    Write-Host "Updating [$_] file ..."

    $envContent = Get-Content -Path $_
    $envContent = $envContent -replace "SITECORE_LICENSE=.*", "SITECORE_LICENSE=$license"
    $envContent = $envContent -replace "SITECORE_IDSECRET=.*", "SITECORE_IDSECRET=$idSecret"
    $envContent = $envContent -replace "SITECORE_ID_CERTIFICATE=.*", "SITECORE_ID_CERTIFICATE=$idCert"
    $envContent = $envContent -replace "SITECORE_ID_CERTIFICATE_PASSWORD=.*", "SITECORE_ID_CERTIFICATE_PASSWORD=$idPassword"
    $envContent = $envContent -replace "TELERIK_ENCRYPTION_KEY=.*", "TELERIK_ENCRYPTION_KEY=$telerikKey"
    $envContent = $envContent -replace "REPORTING_API_KEY=.*", "REPORTING_API_KEY=$reportingApiKey"
    $envContent = $envContent -replace "XC_IDENTITY_COMMERCEENGINECONNECTCLIENT_CLIENTSECRET1=.*", "XC_IDENTITY_COMMERCEENGINECONNECTCLIENT_CLIENTSECRET1=$xcIdSecret"
    $envContent = $envContent -replace "XC_ENGINE_BRAINTREEENVIRONMENT=.*", "XC_ENGINE_BRAINTREEENVIRONMENT=$braintreeEnvironment"
    $envContent = $envContent -replace "XC_ENGINE_BRAINTREEMERCHANTID=.*", "XC_ENGINE_BRAINTREEMERCHANTID=$braintreeMerchantId"
    $envContent = $envContent -replace "XC_ENGINE_BRAINTREEPUBLICKEY=.*", "XC_ENGINE_BRAINTREEPUBLICKEY=$braintreePublicKey"
    $envContent = $envContent -replace "XC_ENGINE_BRAINTREEPRIVATEKEY=.*", "XC_ENGINE_BRAINTREEPRIVATEKEY=$braintreePrivateKey"
    $envContent = $envContent -replace "ISOLATION=.*", "ISOLATION=$isolation"
    $envContent = $envContent -replace "TRAEFIK_ISOLATION=.*", "TRAEFIK_ISOLATION=default" # There is no traefik that supports proces isolation in 1909 so important this stays as default and isn't overwritten by isolation above

    Set-Content -Path $_ -Value $envContent -Force

    Write-Host ".env file [$_] has been updated"
}

#Creates volumes folders in the host
Confirm-VolumeFoldersExist -Path "C:\containers"
