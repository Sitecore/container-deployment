[CmdletBinding()]
Param (
    [ValidateSet("xm1","xp0","xp1")]
    [string]$Topology = "xp0",

    [string]
    [ValidateNotNullOrEmpty()]
    $EnvFilePath = ".\.env",
    
    [Parameter(Mandatory = $true)]
    [string]
    [ValidateNotNullOrEmpty()]
    $LicenseXmlPath,
    
    # We do not need to use [SecureString] here since the value will be stored unencrypted in .env,
    # and used only for transient local example environment.
    [string]
    $SitecoreAdminPassword = "Password12345",
    
    # We do not need to use [SecureString] here since the value will be stored unencrypted in .env,
    # and used only for transient local example environment.
    [string]
    $SqlSaPassword = "Password12345",
    
    [string]
    $SqlServer = "mssql",
    
    [string]
    $SqlUserName = "sa",
    
    [boolean]
    $IsAlwaysEncrypted = $false,
    
    [string]
    $ProcessingEngineTasksDatabaseUserName = "dbo",
    
    [string]
    $CdHost = "$($Topology)cd.localhost",
    
    [string]
    $CmHost = "$($Topology)cm.localhost",
    
    [string]
    $IdHost = "$($Topology)id.localhost",

    # The link to a source NuGet Feed has been updated.
    # In case of a name conflict with local PSRepository we suggest unregistering previous version from the host.
    [string]
    $SitecoreGalleryRepositoryLocation = "https://nuget.sitecore.com/resources/v2/",
    
    [string]
    $CertDataFolder = ".\traefik\certs",
    
    [string]
    $SpecificVersion
)

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

function Add-WindowsHostsFileEntries{
    param(
        [string]$EnvFilePath,
        [string]$Topology,
        [string]$CdHost,
        [string]$CmHost,
        [string]$IdHost
    )
    
    Write-Information -MessageData "Starting adding Windows hosts file entries for '$Topology' topology..." -InformationAction Continue
    
    Add-HostsEntry "$CmHost"
    Add-HostsEntry "$IdHost"
    if (($Topology -eq "xm1") -or ($Topology -eq "xp1")) {
        Add-HostsEntry "$CdHost"
    }
    
    Write-Information -MessageData "Finish adding Windows hosts file entries for '$Topology' topology." -InformationAction Continue
}

function Create-Certificates{
    param(
        [string]$CertDataFolder,
        [string]$Topology,
        [string]$CdHost,
        [string]$CmHost,
        [string]$IdHost
    )
    
    Write-Information -MessageData "Starting create certificates for '$Topology' topology..." -InformationAction Continue
    
	$dnsNames = @("$CdHost", "$CmHost", "$IdHost")
    
    if ($Topology -eq "xp0") {
        $dnsNames = @("$CmHost", "$IdHost")
    }
	
	# Check that Certificate or Key files already exist in the $CertDataFolder 
	$existingCertificateFiles = Get-ChildItem "$CertDataFolder\*" -Include *.crt, *.key
	
	if (-not $existingCertificateFiles){
		
		# Create Root Certificate file
		$rootKey = Create-RSAKey -KeyLength 4096
		$rootCertificate = Create-SelfSignedCertificate -Key $rootKey
		Create-CertificateFile -Certificate $rootCertificate -OutCertPath "$CertDataFolder\RootCA.crt"
		
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

function Update-CertsConfigFile{
	param(
        [string]$CertDataFolder,
        [string]$Topology,
        [string]$CdHost,
        [string]$CmHost,
        [string]$IdHost
    )
	
	$certsConfigFile = Join-Path (Split-Path $CertDataFolder -Parent) "config\dynamic\certs_config.yaml"
	$certificatePath = "C:\etc\traefik\certs\"
	
    $customHostNames = @("$CdHost", "$CmHost", "$IdHost")
    if ($Topology -eq "xp0") {
        $customHostNames = @("$CmHost", "$IdHost")
    }

    $newFileContent = @("tls:", "  certificates:")

    foreach ($customHostName in $customHostNames){
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
    Param(
        [String]$ModuleName,
        [String]$ModuleVersion
    )
    try {
        $repository = Get-PSRepository | Where-Object { $_.SourceLocation -eq $SitecoreGalleryRepositoryLocation }
        if (!$repository) {
            $tempRepositoryName = "Temp" + (New-Guid)
            Register-PSRepository -Name $tempRepositoryName -SourceLocation $SitecoreGalleryRepositoryLocation -InstallationPolicy Trusted
            $repository = Get-PSRepository | Where-Object { $_.SourceLocation -eq $SitecoreGalleryRepositoryLocation }
        }
        if (!$ModuleVersion) {
            $ModuleVersion = (Find-Module -Name $ModuleName -Repository $repository.Name -AllowPrerelease).Version
            Write-Host "The Docker tool version was not specified. The latest available '$ModuleVersion' version will be used."  -ForegroundColor Green  
        }

        $moduleInstalled = Get-InstalledModule -Name $ModuleName -RequiredVersion $ModuleVersion -AllowPrerelease -ErrorAction SilentlyContinue
        if (!$moduleInstalled) {
            Write-Host "Installing '$ModuleName' $ModuleVersion" -ForegroundColor Green
            Install-Module -Name $ModuleName -RequiredVersion $ModuleVersion -Repository $repository.Name -AllowClobber -AllowPrerelease -Scope CurrentUser -Force -ErrorAction "Stop"
        }
        $localModulePath = ((Get-Module $ModuleName -ListAvailable) | Where-Object Version -eq $ModuleVersion.Split("-")[0]).Path
        Write-Host "Importing '$ModuleName'  '$ModuleVersion' from '$localModulePath' ..." 
        Import-Module -Name $localModulePath
    }
    finally {
        if ($tempRepositoryName -and ($repository.Name -eq $tempRepositoryName)) {
            Unregister-PSRepository -Name $tempRepositoryName
        }
    }
}

function Invoke-ComposeInit {
    if (-not (Test-Path $LicenseXmlPath)) {
        throw "Did not find $LicenseXmlPath"
    }
    if (-not (Test-Path $LicenseXmlPath -PathType Leaf)) {
        throw "$LicenseXmlPath is not a file"
    }
    
    # Install and Import SitecoreDockerTools
    $ModuleName = "SitecoreDockerTools"
    InstallModule -ModuleName $ModuleName -ModuleVersion $SpecificVersion
    
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
        "IS_ALWAYS_ENCRYPTED" = $IsAlwaysEncrypted
        "PROCESSING_ENGINE_TASKS_DATABASE_USERNAME" = $ProcessingEngineTasksDatabaseUserName
        "CD_HOST" = $CdHost
        "CM_HOST" = $CmHost
        "ID_HOST" = $IdHost
        "SITECORE_GRAPHQL_UPLOADMEDIAOPTIONS_ENCRYPTIONKEY" = Get-SitecoreRandomString 16 -DisallowSpecial
    }
    
    $envFile = Split-Path $EnvFilePath -Leaf
    
    if($envFile -eq "upgrade.env"){
        # Populate the environment file
        Populate-EnvironmentFile -EnvFilePath $EnvFilePath -EnvVariablesTable $envVariablesTable
    }else{
        if (!(Test-Path $CertDataFolder)) {
            Write-Warning -Message "The certificate '$CertDataFolder' path isn't valid. Please, specify another path for certificates."
            return
        }
    
        # Populate the environment file
        Populate-EnvironmentFile -EnvFilePath $EnvFilePath -EnvVariablesTable $envVariablesTable
        
        # Configure TLS/HTTPS certificates
        $RootCertificateCreated = Create-Certificates -CertDataFolder $CertDataFolder -Topology $Topology -CdHost $CdHost -CmHost $CmHost -IdHost $IdHost
        
        # The update for the certs_config.yaml file is if Certificates were created for the custom hostnames.
        if ($RootCertificateCreated){
            Update-CertsConfigFile -CertDataFolder $CertDataFolder -Topology $Topology -CdHost $CdHost -CmHost $CmHost -IdHost $IdHost
        }

        # Install Root Certificate if it was created
        if ($RootCertificateCreated){
            Import-Certificate -FilePath "$CertDataFolder\RootCA.crt" -CertStoreLocation "Cert:\LocalMachine\Root"
        }
        
        # Add Windows hosts file entries
        Add-WindowsHostsFileEntries -EnvFilePath $EnvFilePath -Topology $Topology -CdHost $CdHost -CmHost $CmHost -IdHost $IdHost
    }
}

$logFilePath = Join-Path -path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath "compose-init-$(Get-date -f 'yyyyMMddHHmmss').log";
Invoke-ComposeInit *>&1 | Tee-Object $logFilePath