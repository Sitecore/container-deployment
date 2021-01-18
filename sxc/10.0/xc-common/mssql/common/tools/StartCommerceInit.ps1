<<<<<<< Updated upstream
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

    [string]$CoreDatabaseName
)

# Forward all arguments to the XP initialization script for initial database publishing and user creation
.\StartInit.ps1 -ResourcesDirectory $ResourcesDirectory -SqlServer $SqlServer -SqlAdminUser $SqlAdminUser -SqlAdminPassword $SqlAdminPassword -SitecoreAdminPassword $SitecoreAdminPassword -SqlElasticPoolName $SqlElasticPoolName -DatabaseUsers $DatabaseUsers

# Create XC specific roles/users
=======
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

    [string]$CoreDatabaseName
)

# Forward all arguments to the XP initialization script for initial database publishing and user creation
.\StartInit.ps1 -ResourcesDirectory $ResourcesDirectory -SqlServer $SqlServer -SqlAdminUser $SqlAdminUser -SqlAdminPassword $SqlAdminPassword -SitecoreAdminPassword $SitecoreAdminPassword -SqlElasticPoolName $SqlElasticPoolName -DatabaseUsers $DatabaseUsers

# Create XC specific roles/users
>>>>>>> Stashed changes
.\DeployRoles.ps1 -coreDatabaseName $CoreDatabaseName -SqlServer $SqlServer -SqlAdminUser $SqlAdminUser -SqlAdminPassword $SqlAdminPassword -SkipStartingServer