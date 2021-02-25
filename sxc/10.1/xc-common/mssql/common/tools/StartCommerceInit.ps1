[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ -PathType Container })]
    [string]$ResourcesDirectory,

    [Parameter(Mandatory)]
    [string]$SqlServer,

    [Parameter(Mandatory)]
    [string]$SqlAdminUser,

    [Parameter(Mandatory)]
    [string]$SqlAdminPassword,

    [Parameter(Mandatory)]
    [string]$SitecoreAdminPassword,

    [string]$SqlElasticPoolName,
    [object[]]$DatabaseUsers,

    [string]$CoreDatabaseName,

    [string]$SharedDatabaseName,

    [string]$ArchiveDatabaseName,

    [string]$MasterkeyPassword
)

# Forward all arguments to the XP initialization script for initial database publishing and user creation
.\StartInit.ps1 -ResourcesDirectory $ResourcesDirectory -SqlServer $SqlServer -SqlAdminUser $SqlAdminUser -SqlAdminPassword $SqlAdminPassword -SitecoreAdminPassword $SitecoreAdminPassword -SqlElasticPoolName $SqlElasticPoolName -DatabaseUsers $DatabaseUsers

# Create XC specific roles/users
.\DeployRoles.ps1 -coreDatabaseName $CoreDatabaseName -SqlServer $SqlServer -SqlAdminUser $SqlAdminUser -SqlAdminPassword $SqlAdminPassword -SkipStartingServer

# Create External data sources
.\CreateExternalDataSources.ps1 -SharedDatabaseName $SharedDatabaseName -ArchiveDatabaseName $ArchiveDatabaseName -MasterkeyPassword $MasterkeyPassword -SqlServer $SqlServer -SqlAdminUser $SqlAdminUser -SqlAdminPassword $SqlAdminPassword -SkipStartingServer