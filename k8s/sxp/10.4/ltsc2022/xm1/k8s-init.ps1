[CmdletBinding()]
Param (
    [ValidateSet("xm1","xp1")]
    [string]$Topology = "xm1",

    [string]
    [ValidateNotNullOrEmpty()]
    $SecretsFolderPath = ".\secrets",
    
    [string]
    $CertDataFolder = ".\secrets\tls",
    
    [string]
    $ConfigmapsDataFolder = ".\configmaps",
    
    [Parameter(Mandatory = $true)]
    [string]
    [ValidateNotNullOrEmpty()]
    $LicenseXmlPath,
    
    [string]
    $CdHost = "cd.globalhost",
    
    [string]
    $CmHost = "cm.globalhost",
    
    [string]
    $IdHost = "id.globalhost",
    
    [Parameter(Mandatory = $true)]
    [string]
    $ExternalIPAddress,
    
    [Parameter(Mandatory = $true)]
    [string]
    $SqlUserName,
    
    # We do not need to use [SecureString] here since the value will be stored unencrypted in secrets,
    # and used only for transient local example environment.
    [Parameter(Mandatory = $true)]
    [string]
    $SqlUserPassword,
    
    [string]
    $SqlServer = "mssql",
    
    # We do not need to use [SecureString] here since the value will be stored unencrypted in secrets,
    # and used only for transient local example environment.
    [Parameter(Mandatory = $true)]
    [string]
    $SitecoreAdminPassword,
    
    # We do not need to use [SecureString] here since the value will be stored unencrypted in secrets,
    # and used only for transient local example environment.
    [string]
    $SqlCoreDatabasePassword,
    
    # We do not need to use [SecureString] here since the value will be stored unencrypted in secrets,
    # and used only for transient local example environment.
    [string]
    $SqlFormsDatabasePassword,
    
    # We do not need to use [SecureString] here since the value will be stored unencrypted in secrets,
    # and used only for transient local example environment.
    [string]
    $SqlMasterDatabasePassword,
    
    # We do not need to use [SecureString] here since the value will be stored unencrypted in secrets,
    # and used only for transient local example environment.
    [string]
    $SqlWebDatabasePassword,
    
    # We do not need to use [SecureString] here since the value will be stored unencrypted in secrets,
    # and used only for transient local example environment.
    [string]
    $SqlCollectionShardmapmanagerDatabasePassword,
    
    # We do not need to use [SecureString] here since the value will be stored unencrypted in secrets,
    # and used only for transient local example environment.
    [string]
    $SqlExmMasterDatabasePassword,
    
    # We do not need to use [SecureString] here since the value will be stored unencrypted in secrets,
    # and used only for transient local example environment.
    [string]
    $SqlMarketingAutomationDatabasePassword,
    
    # We do not need to use [SecureString] here since the value will be stored unencrypted in secrets,
    # and used only for transient local example environment.
    [string]
    $SqlMessagingDatabasePassword,
    
    # We do not need to use [SecureString] here since the value will be stored unencrypted in secrets,
    # and used only for transient local example environment.
    [string]
    $SqlProcessingEngineStorageDatabasePassword,
    
    # We do not need to use [SecureString] here since the value will be stored unencrypted in secrets,
    # and used only for transient local example environment.
    [string]
    $SqlProcessingEngineTasksDatabasePassword,
    
    # We do not need to use [SecureString] here since the value will be stored unencrypted in secrets,
    # and used only for transient local example environment.
    [string]
    $SqlProcessingPoolsDatabasePassword,
    
    # We do not need to use [SecureString] here since the value will be stored unencrypted in secrets,
    # and used only for transient local example environment.
    [string]
    $SqlProcessingTasksDatabasePassword,
    
    # We do not need to use [SecureString] here since the value will be stored unencrypted in secrets,
    # and used only for transient local example environment.
    [string]
    $SqlReferenceDataDatabasePassword,
    
    # We do not need to use [SecureString] here since the value will be stored unencrypted in secrets,
    # and used only for transient local example environment.
    [string]
    $SqlReportingDatabasePassword,
    
    [string]
    $SitecoreGalleryRepositoryLocation = "https://nuget.sitecore.com/resources/v2/",
    
    [string]
    $SpecificVersion
)

$ErrorActionPreference = "Stop";
[boolean]$RootCertificateCreated = $false;

$certDataFolderList = @{
    "$CertDataFolder\global-cd" = "$CdHost"
    "$CertDataFolder\global-cm" = "$CmHost"
    "$CertDataFolder\global-id" = "$IdHost"
}

$configmapsHostnameList = @{
    "$ConfigmapsDataFolder\cd-hostname" = "$CdHost"
    "$ConfigmapsDataFolder\cm-hostname" = "$CmHost"
    "$ConfigmapsDataFolder\id-hostname" = "$IdHost"
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

function Populate-ContentSecrets {
    param(
        [string]$SecretsFolderPath,
        [hashtable]$K8sSecretArray
    )
    
    Write-Information -MessageData "Starting populating the secret .txt files for '$SecretsFolderPath' folder..." -InformationAction Continue
    
    $K8sSecretArray.keys | ForEach-Object {
        $secretFilePath = Join-Path $SecretsFolderPath $_
        if (Test-Path $secretFilePath -PathType Leaf) {
            Set-Content $secretFilePath -Value "$($K8sSecretArray[$_])" -Force -NoNewline
        }
    }
    
    Write-Information -MessageData "Finish populating the secret .txt files for '$SecretsFolderPath' folder." -InformationAction Continue
}

function Add-WindowsHostsFileEntries{
    param(
        [string]$Topology,
        [string]$CdHost,
        [string]$CmHost,
        [string]$IdHost,
        [string]$ExternalIPAddress
    )
    
    Write-Information -MessageData "Starting adding Windows hosts file entries for k8s '$Topology' topology..." -InformationAction Continue
    
    Add-HostsEntry -Hostname "$CdHost" -IPAddress $ExternalIPAddress
    Add-HostsEntry -Hostname "$CmHost" -IPAddress $ExternalIPAddress
    Add-HostsEntry -Hostname "$IdHost" -IPAddress $ExternalIPAddress
    
    Write-Information -MessageData "Finish adding Windows hosts file entries for k8s '$Topology' topology." -InformationAction Continue
}

function Update-ConfigmapsFolder{
    param(
        [hashtable]$ConfigmapsHostnameList,
        [string]$CdHost,
        [string]$CmHost,
        [string]$IdHost
    )
    
    $ConfigmapsHostnameList.Keys | ForEach-Object {
        $hostnameFile = $_
        $hostName = $ConfigmapsHostnameList[$_]
        
        if (!(Test-Path $hostnameFile)) {
            Write-Warning -Message "The configmaps hostname '$hostnameFile' path isn't valid. Please, specify another path for hostnames configmaps."
            return
        }
        
        # Clear *-hostname file
        Clear-Content -Path $hostnameFile
        
        # Setting new content to the *-hostname file
        $hostName | Set-Content $hostnameFile -NoNewline
        
        Write-Information -MessageData "'$hostnameFile' file was successfully updated." -InformationAction Continue
    }
}

function Create-Certificates{
    param(
        [string]$CertDataFolder,
        [hashtable]$CertDataFolderList,
        [string]$Topology
    )
    
    if (![string]::IsNullOrEmpty($CertDataFolder)) {
    
        Write-Information -MessageData "Starting create certificates for k8s '$Topology' topology..." -InformationAction Continue
        
        # Check that root certificate file already exist in the $CertDataFolder 
        $existingRootCertificateFile = Get-ChildItem "$CertDataFolder\global-authority\*" -Include *.crt
        
        if (-not $existingRootCertificateFile){
            
            # Create Root Certificate file
            $rootKey = Create-RSAKey -KeyLength 4096
            $rootCertificate = Create-SelfSignedCertificate -Key $rootKey -CommonName "Sitecore Kubernetes Development Self-Signed Authority"
            Create-CertificateFile -Certificate $rootCertificate -OutCertPath "$CertDataFolder\global-authority\root.crt"
            
            # Create Certificate and Key files for each Sitecore role
            $CertDataFolderList.Keys | ForEach-Object {
                $certDataFolderName = $_
                $hostName = $CertDataFolderList[$_]
                
                if (!(Test-Path $certDataFolderName)) {
                    Write-Warning -Message "The certificate '$certDataFolderName' path isn't valid. Please, specify another path for certificates."
                    return
                }
                
                $selfSignedKey = Create-RSAKey
                $certificate = Create-SelfSignedCertificateWithSignature -Key $selfSignedKey -CommonName $hostName -DnsName $hostName -RootCertificate $rootCertificate
                Create-KeyFile -Key $selfSignedKey -OutKeyPath "$certDataFolderName\tls.key"
                Create-CertificateFile -Certificate $certificate -OutCertPath "$certDataFolderName\tls.crt"
            }
            
            Write-Information -MessageData "Finish creating certificates for k8s '$Topology' topology." -InformationAction Continue
            return $true
        }
        else {
            Write-Information -MessageData "Certificate files already exist for k8s '$Topology' topology." -InformationAction Continue
            return $false
        }
    
    }else {
        Write-Information -MessageData "The TLS certificate path is empty. '\upgrade\*' folder doen't contains TLS certificates for k8s '$Topology' topology." -InformationAction Continue
    }
}

function ApplyOrGenerate-DatabasePassword{
    param(
        [string]$DatabasePassword
    )
    
    $password = $null
    
    if ([string]::IsNullOrEmpty($DatabasePassword)){ 
        $password = Get-SitecoreRandomString 12 -DisallowSpecial
        $password = "Password0_" + $password
    }else {
        $password = $DatabasePassword
    }
    
    return  $password
}

function Invoke-K8sInit {
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
    $k8sSecretArray = @{ 
        "sitecore-adminpassword.txt" = $SitecoreAdminPassword
        "sitecore-identitycertificate.txt" = (Get-SitecoreCertificateAsBase64String -DnsName "localhost" -Password (ConvertTo-SecureString -String $idCertPassword -Force -AsPlainText) -KeyLength 2048)
        "sitecore-identitysecret.txt" = Get-SitecoreRandomString 64 -DisallowSpecial
        "sitecore-license.txt" = ConvertTo-CompressedBase64String -Path $LicenseXmlPath
        "sitecore-telerikencryptionkey.txt" = Get-SitecoreRandomString 128 -DisallowSpecial
        "sitecore-reportingapikey.txt" = "00112233445566778899AABBCCDDEEFF"
        "sitecore-identitycertificatepassword.txt" = $idCertPassword
        "sitecore-databasepassword.txt" = $SqlUserPassword
        "sitecore-databaseusername.txt" = $SqlUserName
        "sitecore-databaseservername.txt" = $SqlServer
        "sitecore-core-database-password.txt" = ApplyOrGenerate-DatabasePassword -DatabasePassword $SqlCoreDatabasePassword
        "sitecore-forms-database-password.txt" = ApplyOrGenerate-DatabasePassword -DatabasePassword $SqlFormsDatabasePassword
        "sitecore-master-database-password.txt" = ApplyOrGenerate-DatabasePassword -DatabasePassword $SqlMasterDatabasePassword
        "sitecore-web-database-password.txt" = ApplyOrGenerate-DatabasePassword -DatabasePassword $SqlWebDatabasePassword
        "sitecore-collection-shardmapmanager-database-password.txt" = ApplyOrGenerate-DatabasePassword -DatabasePassword $SqlCollectionShardmapmanagerDatabasePassword
        "sitecore-exm-master-database-password.txt" = ApplyOrGenerate-DatabasePassword -DatabasePassword $SqlExmMasterDatabasePassword
        "sitecore-marketing-automation-database-password.txt" = ApplyOrGenerate-DatabasePassword -DatabasePassword $SqlMarketingAutomationDatabasePassword
        "sitecore-messaging-database-password.txt" = ApplyOrGenerate-DatabasePassword -DatabasePassword $SqlMessagingDatabasePassword
        "sitecore-processing-engine-storage-database-password.txt" = ApplyOrGenerate-DatabasePassword -DatabasePassword $SqlProcessingEngineStorageDatabasePassword
        "sitecore-processing-engine-tasks-database-password.txt" = ApplyOrGenerate-DatabasePassword -DatabasePassword $SqlProcessingEngineTasksDatabasePassword
        "sitecore-processing-pools-database-password.txt" = ApplyOrGenerate-DatabasePassword -DatabasePassword $SqlProcessingPoolsDatabasePassword
        "sitecore-processing-tasks-database-password.txt" = ApplyOrGenerate-DatabasePassword -DatabasePassword $SqlProcessingTasksDatabasePassword
        "sitecore-reference-data-database-password.txt" = ApplyOrGenerate-DatabasePassword -DatabasePassword $SqlReferenceDataDatabasePassword
        "sitecore-reporting-database-password.txt" = ApplyOrGenerate-DatabasePassword -DatabasePassword $SqlReportingDatabasePassword
        "sitecore-media-request-protection-shared-secret.txt" = Get-SitecoreRandomString 64 -DisallowSpecial
        "sitecore-graphql-uploadmedia_encryptionkey.txt" = Get-SitecoreRandomString 16 -DisallowSpecial
    }
    
    # Populate the .txt secret files
    Populate-ContentSecrets -SecretsFolderPath $SecretsFolderPath -K8sSecretArray $k8sSecretArray
    
    if (![string]::IsNullOrEmpty($CertDataFolder) -and (Test-Path $CertDataFolder)) {
        
        # Configure TLS/HTTPS certificates
        $RootCertificateCreated = Create-Certificates -CertDataFolder $CertDataFolder -CertDataFolderList $certDataFolderList -Topology $Topology
        
        if ($RootCertificateCreated){
            # The update for the \configmaps\*-hostname files is if Certificates were created for the custom hostnames.
            Update-ConfigmapsFolder -ConfigmapsHostnameList $configmapsHostnameList -CdHost $CdHost -CmHost $CmHost -IdHost $IdHost
            
            # Install root certificate if it was created
            Import-Certificate -FilePath "$CertDataFolder\global-authority\root.crt" -CertStoreLocation "Cert:\LocalMachine\Root"
            
            # Add Windows hosts file entries
            Add-WindowsHostsFileEntries -Topology $Topology -CdHost $CdHost -CmHost $CmHost -IdHost $IdHost -ExternalIPAddress $ExternalIPAddress
        }
    }
}

$logFilePath = Join-Path -path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath "k8s-init-$(Get-date -f 'yyyyMMddHHmmss').log";
Invoke-K8sInit *>&1 | Tee-Object $logFilePath