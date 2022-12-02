[cmdletbinding()]
param(
    [string]$jsonFile = (Join-Path '.' 'configltsc2019.json'),
    [string]$k8sRootPath = (Join-Path '..' 'k8s-commerce-*'),
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
    [string]$mediaSecret,
    [Parameter(Mandatory)]
    [string]$graphQLKey,
    [Parameter(Mandatory)]
    [string]$xcIdSecret,
    [Parameter(Mandatory)]
    [string]$idPassword,
    [Parameter(Mandatory)]
    [string]$reportingApiKey,
    [string]$altRegistry = ''
)
<#
.SYNOPSIS
Replaces the variables in the K8S(Kubernetes) yaml files with values from the config json file. K8S is only supported under LTSC 2019.

.DESCRIPTION
Replaces the variables in the K8S(Kubernetes) yaml files with values from the config json file. K8S is only supported under LTSC 2019.

.PARAMETER jsonFile
Path to the configltsc2019.json file that contains the yaml file content needed to populate the K8S files for use in a cluster.
Default path for the configltsc2019 json is co-located with this script

.PARAMETER k8sRootPath
Path to the K8S yaml file templates. Changes are performed in place.
Default path is ..\k8s-commerce-*

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

.PARAMETER mediaSecret
[Parameter(Mandatory)]
Shared secret for media request protection. Length: 64 characters

.PARAMETER graphQLKey
[Parameter(Mandatory)]
Encryption key for Graph QL. Length: 16 characters

.PARAMETER xcIdSecret
[Parameter(Mandatory)]
The client ID assigned to Commerce Engine Connect for Sitecore Identity. This ID is used to identify the Commerce Engine Connectwith Commerce Engine.

.PARAMETER idPassword
[Parameter(Mandatory)]
Password required to open the Identity Server certificate.

.PARAMETER reportingApiKey
[Parameter(Mandatory)]
Symmetric key used to access the Sitecore XDB Reporting Web API. Length: 64-128 characters

.PARAMETER altRegistry
Overrides the registry value from the config json
Default is null

.EXAMPLE
UpdateK8SYaml.ps1

Use the defaults and replace the parameters in the yaml template files

.EXAMPLE
UpdateK8SYaml.ps1 -jsonFile 'C:\download\Commerce.Containers\scripts\configltsc2019.json' `
                  -k8sRootPath 'C:\download\Commerce.Containers' `
                  -licenseFilePath "Location of your licence file" `
                  -braintreeEnvironment "sandbox" `
                  -braintreeMerchantId "Your merchant id" `
                  -braintreePublicKey "Your public key" `
                  -braintreePrivateKey "Your private key" `
                  -telerikKey "Your Telerik Encryption Key" `
                  -idCert "Your Sitecore Identity certificate" `
                  -idSecret "Your Sitecore Identity secret" `
                  -mediaSecret "Your media request protection secret" `
                  -graphQLKey "Your graph QL key" `
                  -idPassword "Your Sitecore Identity password" `
                  -xcIdSecret "Your XC Connect Client Secret" `
                  -reportingApiKey "Your Sitecore Reporting API key"
#>

Function ConvertToCompressedBase64String {
    Param (
        [Parameter(Mandatory)]
        [ValidateScript( {
                if (-Not ($_ | Test-Path) ) { throw "The file or folder $_ does not exist" }
                if (-Not ($_ | Test-Path -PathType Leaf) ) { throw "The Path argument must be a file. Folder paths are not allowed." }
                return $true
            })]
        [string] $Path
    )

    $fileBytes = [System.IO.File]::ReadAllBytes($Path)

    [System.IO.MemoryStream] $memoryStream = New-Object System.IO.MemoryStream

    $gzipStream = New-Object System.IO.Compression.GzipStream $memoryStream, ([IO.Compression.CompressionMode]::Compress)
    $gzipStream.Write($fileBytes, 0, $fileBytes.Length)

    $gzipStream.Close()
    $memoryStream.Close()
    $gzipStream.Dispose()
    $memoryStream.Dispose()

    return [Convert]::ToBase64String($memoryStream.ToArray())
}

#check for the json file
if (Test-Path("$jsonFile")) {

    $license = ConvertToCompressedBase64String -Path $licenseFilePath

    #Read the config json that holds the values to be used to populate the the K8S files
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

    Get-ChildItem -Path (Join-Path $k8sRootPath "k8s-commerce-*") -Directory | ForEach-Object {
        $secretsFolder = Join-Path -Path $_.FullName -ChildPath "secrets"

        Write-Host "Writing secrets for $secretsFolder\xp\sitecore-identitycertificate.txt"
        Set-Content "$secretsFolder\xp\sitecore-identitycertificate.txt" -Value "$idCert" -Force -NoNewline
        Write-Host "Writing secrets for $secretsFolder\xp\sitecore-identitycertificatepassword.txt"
        Set-Content "$secretsFolder\xp\sitecore-identitycertificatepassword.txt" -Value "$idPassword" -Force -NoNewline
        Write-Host "Writing secrets for $secretsFolder\xp\sitecore-identitysecret.txt"
        Set-Content "$secretsFolder\xp\sitecore-identitysecret.txt" -Value "$idSecret" -Force -NoNewline
		Write-Host "Writing secrets for $secretsFolder\xp\sitecore-media-request-protection-shared-secret.txt"
        Set-Content "$secretsFolder\xp\sitecore-media-request-protection-shared-secret.txt" -Value "$mediaSecret" -Force -NoNewline
        Write-Host "Writing secrets for $secretsFolder\xp\sitecore-graphql-uploadmedia_encryptionkey.txt"
        Set-Content "$secretsFolder\xp\sitecore-graphql-uploadmedia_encryptionkey.txt" -Value "$graphQLKey" -Force -NoNewline       
        Write-Host "Writing secrets for $secretsFolder\xp\sitecore-license.txt"
        Set-Content "$secretsFolder\xp\sitecore-license.txt" -Value "$license" -Force -NoNewline
        Write-Host "Writing secrets for $secretsFolder\xp\sitecore-reportingapikey.txt"
        Set-Content "$secretsFolder\xp\sitecore-reportingapikey.txt" -Value "$reportingApiKey" -Force -NoNewline
        Write-Host "Writing secrets for $secretsFolder\xp\sitecore-telerikencryptionkey.txt"
        Set-Content "$secretsFolder\xp\sitecore-telerikencryptionkey.txt" -Value "$telerikKey" -Force -NoNewline
        Write-Host "Writing secrets for $secretsFolder\xc\commerce-connect-clientsecret.txt"
        Set-Content "$secretsFolder\xc\commerce-connect-clientsecret.txt" -Value "$xcIdSecret" -Force -NoNewline
        Write-Host "Writing secrets for $secretsFolder\xc\commerce-engine-braintreeenvironment.txt"
        Set-Content "$secretsFolder\xc\commerce-engine-braintreeenvironment.txt" -Value "$braintreeEnvironment" -Force -NoNewline
        Write-Host "Writing secrets for $secretsFolder\xc\commerce-engine-braintreemerchantid.txt"
        Set-Content "$secretsFolder\xc\commerce-engine-braintreemerchantid.txt" -Value "$braintreeMerchantId" -Force -NoNewline
        Write-Host "Writing secrets for $secretsFolder\xc\commerce-engine-braintreepublickey.txt"
        Set-Content "$secretsFolder\xc\commerce-engine-braintreepublickey.txt" -Value "$braintreePublicKey" -Force -NoNewline
        Write-Host "Writing secrets for$secretsFolder\xc\commerce-engine-braintreeprivatekey.txt"
        Set-Content "$secretsFolder\xc\commerce-engine-braintreeprivatekey.txt" -Value "$braintreePrivateKey" -Force -NoNewline

        #Setup the project for the sxc nonproduction containers 
        $sxcnonprod = "$($containerConfigInfo.sxcproject)/$($containerConfigInfo.nonproductionproject)"

        #Setup the powershell version
        $powershellImage = "mcr.microsoft.com/powershell:lts-nanoserver-$($containerConfigInfo.powershell_image_tag)"
        
        Get-ChildItem -Path $_.FullName -Filter "kustomization.yaml" -Recurse  | ForEach-Object {
    
            Write-Host $_.FullName
    
            (Get-Content $_.FullName -Raw) -replace "{registry}", $registry | Set-Content $_.FullName -NoNewline
            (Get-Content $_.FullName -Raw) -replace "{project}", $($containerConfigInfo.sxpproject) | Set-Content $_.FullName -NoNewline
            (Get-Content $_.FullName -Raw) -replace "{version}", $($containerConfigInfo.sxptag) | Set-Content $_.FullName -NoNewline
            (Get-Content $_.FullName -Raw) -replace "{sxc-project}", $($containerConfigInfo.sxcproject) | Set-Content $_.FullName -NoNewline
            (Get-Content $_.FullName -Raw) -replace "{commerce-version}", $($containerConfigInfo.customercommercetag) | Set-Content $_.FullName -NoNewline           
            (Get-Content $_.FullName -Raw) -replace "{sxc-nonproduction-project}", $sxcnonprod | Set-Content $_.FullName -NoNewline
            (Get-Content $_.FullName -Raw) -replace "{powershell-version}", $powershellImage | Set-Content $_.FullName -NoNewline
        }
    }
} else {
    throw "No JSON file"
}