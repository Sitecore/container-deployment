[CmdletBinding()]
Param (
    [ValidateSet("xm1","xp1")]
    [string]$Topology = "xm1",

    [string]
    [ValidateNotNullOrEmpty()]
    $SecretsFolderPath = ".\configuration",
    
    [Parameter(Mandatory = $true)]
    [string]
    [ValidateNotNullOrEmpty()]
    $LicenseXmlPath,
    
    [Parameter(Mandatory = $true)]
    [string]
    $SqlUserName,
    
    # We do not need to use [SecureString] here since the value will be stored unencrypted in secrets,
    # and used only for transient local example environment.
    [Parameter(Mandatory = $true)]
    [string]
    $SqlUserPassword,
    
    [boolean]
    $IsAlwaysEncrypted = $false,
    
    [string]
    $ProcessingEngineTasksDatabaseUserName = "dbo",
    
    [string]
    $SitecoreGalleryRepositoryLocation = "https://nuget.sitecore.com/resources/v2/",
    
    [string]
    $SpecificVersion
)

$ErrorActionPreference = "Stop";

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
        [hashtable]$K8sSecretArray,
        [string]$Topology
    )
    
    Write-Information -MessageData "Starting populating the secret .txt files to '$SecretsFolderPath' folder for k8s '$Topology' topology..." -InformationAction Continue
    
    $K8sSecretArray.keys | ForEach-Object {
        $secretFilePath = Join-Path $SecretsFolderPath $_
        if (Test-Path $secretFilePath -PathType Leaf) {
            Set-Content $secretFilePath -Value "$($K8sSecretArray[$_])" -Force -NoNewline
        }
    }
    
    Write-Information -MessageData "Finish populating the secret .txt files to '$SecretsFolderPath' folder for k8s '$Topology' topology." -InformationAction Continue
}

function Invoke-K8sInitUpgrade {
    if (-not (Test-Path $LicenseXmlPath)) {
        throw "Did not find $LicenseXmlPath"
    }
    if (-not (Test-Path $LicenseXmlPath -PathType Leaf)) {
        throw "$LicenseXmlPath is not a file"
    }
    
    # Install and Import SitecoreDockerTools
    $ModuleName = "SitecoreDockerTools"
    InstallModule -ModuleName $ModuleName -ModuleVersion $SpecificVersion

    $k8sSecretArray = @{ 
        "sitecore-license.txt" = ConvertTo-CompressedBase64String -Path $LicenseXmlPath
        "sql-password.txt" = $SqlUserPassword
        "sql-user-name.txt" = $SqlUserName
        "processing-engine-tasks-database-user-name.txt" = $ProcessingEngineTasksDatabaseUserName
        "is-always-encrypted.txt" = $IsAlwaysEncrypted
    }
    
    # Populate the .txt secret files
    Populate-ContentSecrets -SecretsFolderPath $SecretsFolderPath -K8sSecretArray $k8sSecretArray -Topology $Topology
}

$logFilePath = Join-Path -path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath "k8s-init-upgrade-$(Get-date -f 'yyyyMMddHHmmss').log";
Invoke-K8sInitUpgrade *>&1 | Tee-Object $logFilePath