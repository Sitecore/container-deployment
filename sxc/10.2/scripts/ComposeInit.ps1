[CmdletBinding()]
Param (
    [ValidateSet("xc0","xc1-cxa")]
    [string] $Topology = "xc1-cxa",

    [ValidateNotNullOrEmpty()]
    [string] $EnvFilePath = "..\$($Topology)\.env",

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $LicenseXmlPath,

    # We do not need to use [SecureString] here since the value will be stored unencrypted in .env,
    # and used only for transient local example environment.
    [string] $SitecoreAdminPassword = "Password12345",

    # We do not need to use [SecureString] here since the value will be stored unencrypted in .env,
    # and used only for transient local example environment.
    [string] $SqlSaPassword = "Password12345",

    [string] $SqlServer = "mssql",
    
    [string] $SqlUserName = "sa",

    [string] $CdHost = "$($Topology)cd.localhost",

    [string] $CmHost = "$($Topology)cm.localhost",

    [string] $IdHost = "$($Topology)id.localhost",

    [string] $BizFxHost = "bizfx.localhost",

    [string] $AuthoringHost = "authoring.localhost",

    [string] $ShopsHost = "shops.localhost",

    [string] $MinionsHost = "minions.localhost",
  
    [string] $SitecoreGalleryRepositoryLocation = "https://sitecore.myget.org/F/sc-powershell/api/v2",

    [string] $TraefikFolder = "..\$($Topology)\traefik",

    [string] $RootCertName = "Sitecore Docker Compose Development Self-Signed Authority",

    [string] $BraintreeEnvironment,

    [string] $BraintreeMerchantId,

    [string] $BraintreePublicKey,

    [string] $BraintreePrivateKey,

    [ValidateSet("default", "process", "hyperv")]
    [string] $Isolation = "process",

    [string] $DockerToolsVersion
)

<#
.SYNOPSIS
Script to facilitate the updating of the .env files for use with docker-compose and required initialization of certificates and hosts entires

.PARAMETER Topology 
[ValidateSet("xc0","xc1-cxa")]
The topology to deploy. Parameter is used to determine paths to other locations (.env file, certificates)

.PARAMETER EnvFilePath 
The path to the parent (root) directory containg the .env file for the specified topology. Default is to use the topology to determine path.

.PARAMETER LicenseXmlPath 
[Parameter(Mandatory)]
Sitecore license file xml path

.PARAMETER SitecoreAdminPassword
The admin password for sitecore

.PARAMETER SqlSaPassword
The SQL sa password

.PARAMETER SqlServer
The SQL server

.PARAMETER SqlUserName
The SQL sa username

.PARAMETER CdHost
The host name for the CD site

.PARAMETER CmHost
The host name for the cm site

.PARAMETER IdHost
The host name for the identity server

.PARAMETER BizFxHost
The host name for the commerce business tools site

.PARAMETER AuthoringHost
The host name for the commerce engine authoring service

.PARAMETER ShopsHost
The host name for the commerce engine shops service

.PARAMETER MinionsHost
The host name for the commerce engine minions service

.PARAMETER SitecoreGalleryRepositoryLocation
Sitecore Gallery repository location. Default is https://sitecore.myget.org/F/sc-powershell/api/v2

.PARAMETER TraefikFolder
Path to the traefik folder. Default is to use the topology to determine path.

.PARAMETER CommonName
The name of the root certificate as it will be displayed in windows certificate manager

.PARAMETER BraintreeEnvironment 
The Braintree environment. E.G. sandbox or production

.PARAMETER BraintreeMerchantId 
Your merchant ID for the Braintreepayment provider.

.PARAMETER BraintreePublicKey 
The public key associated to your Braintree account.

.PARAMETER BraintreePrivateKey
The private key associated to your Braintree account.

.PARAMETER Isolation
[ValidateSet("default", "process", "hyperv")]
Choose the isolation method. default will use the default method determiend by the OS, process will force process isolation, hyperv wil force hyperv isolation. 
To improve performance it is recommened to use "process" as isolation method for Windows 10 as default is hyperv.

.PARAMETER DockerToolsVersion
The version of the Sitecore Docker Tools to use

.EXAMPLE
Example of the required parameters if default values are appropriate
PS> ComposeInit.ps1 -licenseXmlPath "Location of your licence file" `
                  -braintreeEnvironment "sandbox" `
                  -braintreeMerchantId "Your merchant id" `
                  -braintreePublicKey "Your public key" `
                  -braintreePrivateKey "Your private key"
#>

$ErrorActionPreference = "Stop";
[boolean]$RootCertificateCreated = $false;

function Get-EnvironmentVariableNameList {
    param(
        [string]$EnvFilePath
    )
    
    $envVariableNameList = @()
    $envVariables = Get-Content -Path $EnvFilePath
    foreach ($envVariable in $envVariables) { 
        $envName = $envVariable.Split('=')[0]
        $envVariableNameList += $envName
    }
    return $envVariableNameList
}

function Populate-EnvironmentFile {
    param(
        [string]$EnvFilePath,
        [hashtable]$EnvVariablesTable
    )
    
    Write-Information -MessageData "Starting populating '$EnvFilePath' env file variables..." -InformationAction Continue
    
    $envVariableNameList = Get-EnvironmentVariableNameList -EnvFilePath $EnvFilePath
    foreach ($envVariableName in $envVariableNameList){
        if ($EnvVariablesTable.ContainsKey($envVariableName)) {
            Set-EnvFileVariable $envVariableName -Value $($EnvVariablesTable[$envVariableName]) -Path $EnvFilePath
        }
    }
    
    Write-Information -MessageData "Finish populating '$EnvFilePath' env file variables." -InformationAction Continue
}

function Add-WindowsHostsFileEntries {
    param(
        [string]$EnvFilePath,
        [string]$Topology,
        [string]$CdHost,
        [string]$CmHost,
        [string]$IdHost,
        [string]$BizFxHost,
        [string]$AuthoringHost,
        [string]$ShopsHost,
        [string]$MinionsHost
    )
    
    Write-Information -MessageData "Starting adding Windows hosts file entries for '$Topology' topology..." -InformationAction Continue
    
    Add-HostsEntry "$CmHost"
    Add-HostsEntry "$IdHost"
    if ($Topology -eq "xc1-cxa") {
        Add-HostsEntry "$CdHost"
    }
    Add-HostsEntry "$BizFxHost"
    Add-HostsEntry "$AuthoringHost"
    Add-HostsEntry "$ShopsHost"
    Add-HostsEntry "$MinionsHost"
    
    Write-Information -MessageData "Finish adding Windows hosts file entries for '$Topology' topology." -InformationAction Continue
}

function Create-Certificates {
    param(
        [string]$TraefikFolder,
        [string]$Topology,
        [string]$CdHost,
        [string]$CmHost,
        [string]$IdHost,
        [string]$BizFxHost,
        [string]$AuthoringHost,
        [string]$ShopsHost,
        [string]$MinionsHost
    )
    
    Write-Information -MessageData "Starting create certificates for '$Topology' topology..." -InformationAction Continue
    
	$dnsNames = @("$CdHost", "$CmHost", "$IdHost", "$BizFxHost", "$AuthoringHost", "$ShopsHost", "$MinionsHost")
    
    if ($Topology -eq "xc0") {
        $dnsNames = @("$CmHost", "$IdHost", "$BizFxHost", "$AuthoringHost", "$ShopsHost", "$MinionsHost")
    }

    # Check that Certificate or Key files already exist in the $CertDataFolder 
    $CertDataFolder = "$TraefikFolder\certs"
    $existingCertificateFiles = Get-ChildItem "$CertDataFolder\*" -Include *.crt, *.key

    if (-not $existingCertificateFiles){

        # Create Root Certificate file
        $rootKey = Create-RSAKey -KeyLength 4096
        $rootCertificate = Create-SelfSignedCertificate -Key $rootKey -CommonName $RootCertName
        Create-CertificateFile -Certificate $rootCertificate -OutCertPath "$CertDataFolder\root-ca.crt"

        # Create Certificate and Key files for each Sitecore role
        $dnsNames | ForEach-Object {
            $selfSignedKey = Create-RSAKey
            $certificate = Create-SelfSignedCertificateWithSignature -Key $selfSignedKey -CommonName $_ -DnsName $_ -RootCertificate $rootCertificate
            Create-KeyFile -Key $selfSignedKey -OutKeyPath "$CertDataFolder\$_.key"
            Create-CertificateFile -Certificate $certificate -OutCertPath "$CertDataFolder\$_.crt"
        }

        Write-Information -MessageData "Finish creating certificates for '$Topology' topology." -InformationAction Continue

        return $true
    }
    else {
        Write-Information -MessageData "Certificate files already exist for '$Topology' topology." -InformationAction Continue
        return $false
    }
}

function Update-CertsConfigFile {

    param(
        [string]$TraefikFolder,
        [string]$Topology,
        [string]$CdHost,
        [string]$CmHost,
        [string]$IdHost,
        [string]$BizFxHost,
        [string]$AuthoringHost,
        [string]$ShopsHost,
        [string]$MinionsHost
    )
    
    Write-Information -MessageData "Updating certs_config.yaml file." -InformationAction Continue

    $certsConfigFile = (Get-ChildItem "$TraefikFolder\config\dynamic\certs_config.yaml").FullName
    $certificatePath = "C:\etc\traefik\certs\"

    $customHostNames = @("$CdHost", "$CmHost", "$IdHost", "$BizFxHost", "$AuthoringHost", "$ShopsHost", "$MinionsHost")
    if ($Topology -eq "xc0") {
        $customHostNames = @("$CmHost", "$IdHost", "$BizFxHost", "$AuthoringHost", "$ShopsHost", "$MinionsHost")
    }

    $newFileContent = @("tls:", "  certificates:")
    foreach ($customHostName in $customHostNames) {
        $newFileContent +=  "    - certFile: " + $certificatePath + $customHostName + ".crt"
        $newFileContent +=  "      keyFile: " + $certificatePath + $customHostName + ".key"
    }

    # Clear certs_config.yaml file
    Clear-Content -Path $certsConfigFile

    # Setting new content to the certs_config.yaml file
    $newFileContent | Set-Content $certsConfigFile

    Write-Information -MessageData "certs_config.yaml file was successfully updated." -InformationAction Continue
}

function InstallModule {
    param(
        [string]$ModuleName,
        [string]$ModuleVersion,
        [string]$RepositoryName
    )

    $moduleInstalled = Get-InstalledModule -Name $ModuleName -RequiredVersion $ModuleVersion -AllowPrerelease -ErrorAction SilentlyContinue
    if (-not $moduleInstalled) {
        Write-Host "Installing '$ModuleName' with version $ModuleVersion" -ForegroundColor Green
        Install-Module -Name $ModuleName -RequiredVersion $ModuleVersion -AllowPrerelease -Repository $RepositoryName -Scope CurrentUser
    }
}

Function Confirm-VolumeFoldersExist {
    param (
        [string] $Path
    )
    Write-Host "Verifying Folders for Commerce Engine volumes exist in [$Path]"

    "cm\domains-shared",
    "cd\domains-shared",
    "engine\catalogs",
    "mssql-data",
    "solr-data" |
    ForEach-Object { 
        if (-Not (Test-Path (Join-Path $Path $_))) {
            Write-Verbose "Creating folder [$_]"
            New-Item -Path $Path -Name $_ -ItemType Directory
        }
    }
}

if (-not (Test-Path $LicenseXmlPath)) {
    throw "Did not find $LicenseXmlPath"
}
if (-not (Test-Path $LicenseXmlPath -PathType Leaf)) {
    throw "$LicenseXmlPath is not a file"
}

# Check for Sitecore Gallery
Import-Module PowerShellGet
$SitecoreGalleryName = 'SitecoreGallery'
$SitecoreGallery = Get-PSRepository | Where-Object { $_.Name -eq $SitecoreGalleryName }
if (-not $SitecoreGallery) { 
    Write-Host "Adding Sitecore PowerShell Gallery..." -ForegroundColor Green 
    Register-PSRepository -Name $SitecoreGalleryName -SourceLocation $SitecoreGalleryRepositoryLocation -InstallationPolicy Trusted
    $SitecoreGallery = Get-PSRepository -Name $SitecoreGalleryName
}

# Install and Import SitecoreDockerTools
$moduleName = "SitecoreDockerTools"
$repositoryName = $SitecoreGallery.Name

$module = Find-Module -Name $moduleName -Repository $repositoryName
$latestVersion = $module.Version
$importModuleCommand = "Import-Module $moduleName -RequiredVersion $latestVersion"

if(![string]::IsNullOrEmpty($DockerToolsVersion)){
    $module = Find-Module -Name $moduleName -Repository $repositoryName -RequiredVersion $DockerToolsVersion -AllowPrerelease
    $latestVersion = $module.Version

    if([string]::IsNullOrEmpty($latestVersion)){
        Write-Warning -Message "'$moduleName' module with '$DockerToolsVersion' version doesn't exist."
        return
    }
    InstallModule -ModuleName $moduleName -ModuleVersion $latestVersion -RepositoryName $repositoryName

    $modulePath = ((Get-Module $moduleName -ListAvailable) | where Version -eq $latestVersion.Split("-")[0]).Path
    $importModuleCommand = "Import-Module -Name $modulePath"
}else {
    InstallModule -ModuleName $moduleName -ModuleVersion $latestVersion -RepositoryName $repositoryName
}

Write-Host "Importing '$moduleName'..." -ForegroundColor Green
Invoke-Expression $importModuleCommand

$idCertPassword = Get-SitecoreRandomString 12 -DisallowSpecial
$envVariablesTable = @{ 
    "SITECORE_ADMIN_PASSWORD" = $SitecoreAdminPassword
    "SQL_SA_PASSWORD" = $SqlSaPassword
    "REPORTING_API_KEY" = "00112233445566778899AABBCCDDEEFF"
    "TELERIK_ENCRYPTION_KEY" = Get-SitecoreRandomString 128 -DisallowSpecial
    "MEDIA_REQUEST_PROTECTION_SHARED_SECRET" = Get-SitecoreRandomString 64 -DisallowSpecial
    "SITECORE_IDSECRET" = Get-SitecoreRandomString 64 -DisallowSpecial
    "SITECORE_ID_CERTIFICATE" = (Get-SitecoreCertificateAsBase64String -DnsName "localhost" -Password (ConvertTo-SecureString -String $idCertPassword -Force -AsPlainText) -KeyLength 2048)
    "SITECORE_ID_CERTIFICATE_PASSWORD" = $idCertPassword
    "SITECORE_LICENSE" = ConvertTo-CompressedBase64String -Path $LicenseXmlPath
    "SQL_SERVER" = $SqlServer
    "SQL_USERNAME" = $SqlUserName
    "SQL_PASSWORD" = $SqlSaPassword
    "CD_HOST" = $CdHost
    "CM_HOST" = $CmHost
    "ID_HOST" = $IdHost
    "BIZFX_HOST" = $BizFxHost
    "AUTHORING_HOST" = $AuthoringHost
    "SHOPS_HOST" = $ShopsHost
    "MINIONS_HOST" = $MinionsHost
    "XC_ENGINE_BRAINTREEENVIRONMENT" = $BraintreeEnvironment
    "XC_ENGINE_BRAINTREEMERCHANTID" = $BraintreeMerchantId
    "XC_ENGINE_BRAINTREEPUBLICKEY" = $BraintreePublicKey
    "XC_ENGINE_BRAINTREEPRIVATEKEY" = $BraintreePrivateKey
    "XC_IDENTITY_COMMERCEENGINECONNECTCLIENT_CLIENTSECRET1" = Get-SitecoreRandomString 12 -DisallowSpecial
    "ISOLATION" = $Isolation
}

$envFile = Split-Path $EnvFilePath -Leaf

if($envFile -eq "upgrade.env") {
    # Populate the environment file
    Populate-EnvironmentFile -EnvFilePath $EnvFilePath -EnvVariablesTable $envVariablesTable
}else {
    if (!(Test-Path $TraefikFolder)) {
        Write-Warning -Message "The certificate '$TraefikFolder' path isn't valid. Please, specify another path for certificates."
        return
    }

    # Populate the environment file
    Populate-EnvironmentFile -EnvFilePath $EnvFilePath -EnvVariablesTable $envVariablesTable

    # Configure TLS/HTTPS certificates
    $RootCertificateCreated = Create-Certificates -TraefikFolder "$TraefikFolder" -Topology $Topology -CdHost $CdHost -CmHost $CmHost -IdHost $IdHost -BizFxHost $BizFxHost -AuthoringHost $AuthoringHost -ShopsHost $ShopsHost -MinionsHost $MinionsHost

    # The update for the certs_config.yaml file is if Certificates were created for the custom hostnames.
    if ($RootCertificateCreated) {
        Update-CertsConfigFile -TraefikFolder $TraefikFolder -Topology $Topology -CdHost $CdHost -CmHost $CmHost -IdHost $IdHost -BizFxHost $BizFxHost -AuthoringHost $AuthoringHost -ShopsHost $ShopsHost -MinionsHost $MinionsHost
    }

    # Install Root Certificate if it was created
    if ($RootCertificateCreated) {
        Write-Information -MessageData "Importing certificate" -InformationAction Continue
        Import-Certificate -FilePath "$TraefikFolder\certs\root-ca.crt" -CertStoreLocation "Cert:\LocalMachine\Root"
        Write-Information -MessageData "Importing certificate complete" -InformationAction Continue
    }

    # Add Windows hosts file entries
    Add-WindowsHostsFileEntries -EnvFilePath $EnvFilePath -Topology $Topology -CdHost $CdHost -CmHost $CmHost -IdHost $IdHost -BizFxHost $BizFxHost -AuthoringHost $AuthoringHost -ShopsHost $ShopsHost -MinionsHost $MinionsHost

    # Creates volumes folders in the host
    Confirm-VolumeFoldersExist -Path "C:\containers"
}