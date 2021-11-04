[cmdletbinding()]
param(
    [string]$jsonFile = (Join-Path '.' 'configltsc2019.json'),
    [string]$k8sRootPath = (Join-Path '..' 'upgrade\k8s-sitecore-xc1'),
    [Parameter(Mandatory)]
    [string] $licenseFilePath,
    [string]$sharedDB = "SitecoreCommerce_SharedEnvironments",
    [string]$globalDB = "SitecoreCommerce_Global",
    [string]$archiveDB = "SitecoreCommerce_ArchiveSharedEnvironments",
    [string]$masterKeyPassword = "Password12345",
    [string]$sqlServer = "mssql",
    [string]$sqlUsername = "sa",
    [string]$sqlPassword = "Password12345",
    [string]$sitecoreDbPrefix = "Sitecore",
    [string]$isAlwaysEncrypted = "false",
    [string]$altRegistry = ''
)
<#
.SYNOPSIS
Replaces the variables in the Upgrade K8S(Kubernetes) yaml files with values from the config json file. K8S is only supported under LTSC 2019.

.DESCRIPTION
Replaces the variables in the Upgrade K8S(Kubernetes) yaml files with values from the config json file. K8S is only supported under LTSC 2019.

.PARAMETER jsonFile
Path to the configltsc2019.json file that contains the yaml file content needed to populate the K8S files for use in a cluster.
Default path for the configltsc2019 json is co-located with this script

.PARAMETER k8sRootPath
Path to the K8S yaml file templates. Changes are performed in place.
Default path is ..\upgrade\k8s-commerce-*

.PARAMETER licenseFilePath 
[Parameter(Mandatory)]
Sitecore license file path to be converted to GZIP Compressed and Base64 encoded string.

.PARAMETER sharedDB
Sitecore XC Shared database name
Default value is SitecoreCommerce_SharedEnvironments

.PARAMETER globalDB
Sitecore XC Global database name
Default value is SitecoreCommerce_Global

.PARAMETER archiveDB
Sitecore XC Archive database name
Default value is SitecoreCommerce_ArchiveSharedEnvironments

.PARAMETER masterKeyPassword
Sitecore XC databse master key password
Default is Password12345

.PARAMETER sqlServer
SQL Server name
Default is mssql

.PARAMETER sqlUsername
SQL Admin username
Default is sa

.PARAMETER sqlPassword
SQL Admin password
Default is Password12345

.PARAMETER sitecoreDbPrefix
Database prefix for Sitecore databases
Default is Sitecore

.PARAMETER isAlwaysEncrypted
Is the sql server always encrypted
Default is false

.PARAMETER altRegistry
Overrides the registry value from the config json
Default is null

.EXAMPLE
UpdateK8SUpgradeYaml.ps1

Use the defaults and replace the parameters in the yaml template files

.EXAMPLE
UpdateK8SUpgradeYaml.ps1 -jsonFile 'C:\download\Commerce.Containers\scripts\configltsc2019.json' `
                -k8sRootPath 'C:\download\Commerce.Containers\upgrade\k8s-sitecore-xc1' `
                -licenseFilePath "Location of your licence file" `
                -sharedDB "Your XC shared database name" `
                -globaldb "Your XC global database name" `
                -archiveDB "Your XC archive database name" `
                -masterKeyPassword "Your XC master key password" `
                -sqlServer "Your sql server instance name" `
                -sqlUsername "Your sql server admin user account name to use" `
                -sqlPassword "The sql server admin account password" `
                -sitecoreDbPrefix "The prefix used for Sitecore databases in your environment" `
                -isAlwaysEncrypted "Is the sql connection always encrypted" `
                -altRegistry "the alternative container regsitry to use is using private images"

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

    $secretsFolder = (Join-Path $k8sRootPath "configuration")

    Write-Host "Writing secrets for $secretsFolder\commerce-engine-shared-databasename.txt"
    Set-Content "$secretsFolder\commerce-engine-shared-databasename.txt" -Value "$sharedDB" -Force -NoNewline
    Write-Host "Writing secrets for $secretsFolder\commerce-engine-global-databasename.txt"
    Set-Content "$secretsFolder\commerce-engine-global-databasename.txt" -Value "$globalDB" -Force -NoNewline
    Write-Host "Writing secrets for $secretsFolder\commerce-engine-archive-databasename.txt"
    Set-Content "$secretsFolder\commerce-engine-archive-databasename.txt" -Value "$archiveDB" -Force -NoNewline
    Write-Host "Writing secrets for $secretsFolder\commerce-engine-database-masterkey-password.txt"
    Set-Content "$secretsFolder\commerce-engine-database-masterkey-password.txt" -Value "$masterKeyPassword" -Force -NoNewline
    Write-Host "Writing secrets for $secretsFolder\is-always-encrypted.txt"
    Set-Content "$secretsFolder\is-always-encrypted.txt" -Value "$isAlwaysEncrypted" -Force -NoNewline
    Write-Host "Writing secrets for $secretsFolder\sitecore-license.txt"
    Set-Content "$secretsFolder\sitecore-license.txt" -Value "$license" -Force -NoNewline
    Write-Host "Writing secrets for $secretsFolder\sql-server.txt"
    Set-Content "$secretsFolder\sql-server.txt" -Value "$sqlServer" -Force -NoNewline
    Write-Host "Writing secrets for $secretsFolder\sql-user-name.txt"
    Set-Content "$secretsFolder\sql-user-name.txt" -Value "$sqlUsername" -Force -NoNewline
    Write-Host "Writing secrets for $secretsFolder\sql-password.txt"
    Set-Content "$secretsFolder\sql-password.txt" -Value "$sqlPassword" -Force -NoNewline
    Write-Host "Writing secrets for $secretsFolder\sql-database-prefix.txt"
    Set-Content "$secretsFolder\sql-database-prefix.txt" -Value "$sitecoreDbPrefix" -Force -NoNewline

    #Set registry and version info 
    Get-ChildItem -Path $k8sRootPath -Filter "kustomization.yaml" -Recurse  | ForEach-Object {

        Write-Host $_.FullName

        (Get-Content $_.FullName -Raw) -replace "{registry}", $registry | Set-Content $_.FullName -NoNewline
        (Get-Content $_.FullName -Raw) -replace "{commerce-version}", $($containerConfigInfo.customercommercetag) | Set-Content $_.FullName -NoNewline           
    }
} else {
    throw "No JSON file"
}