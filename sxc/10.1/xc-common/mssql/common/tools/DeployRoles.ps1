param(
    [Parameter(Mandatory = $true)]
    [string] $coreDatabaseName,

    [string]$SqlServer = "(local)",
    
    [string]$SqlAdminUser = "sa",

    [string]$SqlAdminPassword,

    [switch]$SkipStartingServer
)

function Invoke-Sqlcmd {
    param(
        [string]$SqlDatabase,
        [string]$SqlServer,
        [string]$SqlAdminUser,
        [string]$SqlAdminPassword, 
        [string]$Query
    )

    $arguments = " -Q ""$Query"" -S '$SqlServer' -l 600 -t 600"

    if ($SqlAdminUser -and $SqlAdminPassword) {
        $arguments += " -U '$SqlAdminUser' -P '$SqlAdminPassword'"
    }

    if ($SqlDatabase) {
        $arguments += " -d '$SqlDatabase'"
    }

    Invoke-Expression "sqlcmd $arguments"

    if ($LASTEXITCODE -ne 0) {
        throw "sqlcmd exited with code $LASTEXITCODE"
    }
}

function Add-Role {
    param(
        [string]$coreDatabaseName,
        [string]$roleName,
        [string]$applicationName = "sitecore",
        [string]$sqlServer,
        [string]$sqlAdminUser,
        [string]$sqlAdminPassword
    )

    $sqlcmd = "EXEC [dbo].[aspnet_Roles_CreateRole] '$($applicationName)', '$($roleName)'"    
    Invoke-Sqlcmd -SqlDatabase $coreDatabaseName -SqlServer $sqlServer -SqlAdminUser $sqlAdminUser -SqlAdminPassword $sqlAdminPassword -Query $sqlcmd
    Write-Host "Created role: $($roleName)."
}

function Add-RoleToUser {
    param(
        [string]$coreDatabaseName,
        [string]$roleName,
        [string]$userName,
        [string]$applicationName = "sitecore",
        [string]$sqlServer,
        [string]$sqlAdminUser,
        [string]$sqlAdminPassword
    )

    $sqlcmd = "USE [$($coreDatabaseName)]
               GO
               declare @dt DATETIME
               set @dt = GETUTCDATE()
               EXEC [dbo].[aspnet_UsersInRoles_AddUsersToRoles] '$($applicationName)', '$($userName)', '$($roleName)', @dt
               GO"
    Invoke-Sqlcmd -SqlDatabase $coreDatabaseName -SqlServer $sqlServer -SqlAdminUser $sqlAdminUser -SqlAdminPassword $sqlAdminPassword -Query $sqlcmd
    Write-Host "Role added to user: $($roleName), $($userName)."
}

function Add-RoleToRole {
    param(
        [string]$coreDatabaseName,
        [string]$memberRoleName,
        [string]$targetRoleName,
        [string]$applicationName = "",
        [string]$sqlServer,
        [string]$sqlAdminUser,
        [string]$sqlAdminPassword
    )

    $sqlcmd = "INSERT INTO [dbo].[RolesInRoles] (MemberRoleName, TargetRoleName, ApplicationName, Created) VALUES ('$($memberRoleName)', '$($targetRoleName)', '$($applicationName)', GETUTCDATE())"
    Invoke-Sqlcmd -SqlDatabase $coreDatabaseName -SqlServer $sqlServer -SqlAdminUser $sqlAdminUser -SqlAdminPassword $sqlAdminPassword -Query $sqlcmd
    Write-Host "$($memberRoleName) role added to $($targetRoleName) role."
}

if (-not $SkipStartingServer) {
    Start-Service MSSQLSERVER
}

Add-Role $coreDatabaseName -roleName 'sitecore\Commerce Administrator' -sqlServer $SqlServer -sqlAdminUser $SqlAdminUser -sqlAdminPassword $SqlAdminPassword
Add-Role $coreDatabaseName -roleName 'sitecore\Commerce Business User' -sqlServer $SqlServer -sqlAdminUser $SqlAdminUser -sqlAdminPassword $SqlAdminPassword
Add-Role $coreDatabaseName -roleName 'sitecore\Customer Service Representative' -sqlServer $SqlServer -sqlAdminUser $SqlAdminUser -sqlAdminPassword $SqlAdminPassword
Add-Role $coreDatabaseName -roleName 'sitecore\Customer Service Representative Administrator' -sqlServer $SqlServer -sqlAdminUser $SqlAdminUser -sqlAdminPassword $SqlAdminPassword
Add-Role $coreDatabaseName -roleName 'sitecore\Merchandiser' -sqlServer $SqlServer -sqlAdminUser $SqlAdminUser -sqlAdminPassword $SqlAdminPassword
Add-Role $coreDatabaseName -roleName 'sitecore\Pricer' -sqlServer $SqlServer -sqlAdminUser $SqlAdminUser -sqlAdminPassword $SqlAdminPassword
Add-Role $coreDatabaseName -roleName 'sitecore\Pricer Manager' -sqlServer $SqlServer -sqlAdminUser $SqlAdminUser -sqlAdminPassword $SqlAdminPassword
Add-Role $coreDatabaseName -roleName 'sitecore\Promotioner' -sqlServer $SqlServer -sqlAdminUser $SqlAdminUser -sqlAdminPassword $SqlAdminPassword
Add-Role $coreDatabaseName -roleName 'sitecore\Promotioner Manager' -sqlServer $SqlServer -sqlAdminUser $SqlAdminUser -sqlAdminPassword $SqlAdminPassword
Add-Role $coreDatabaseName -roleName 'sitecore\Relationship Administrator' -sqlServer $SqlServer -sqlAdminUser $SqlAdminUser -sqlAdminPassword $SqlAdminPassword
Add-Role $coreDatabaseName -roleName 'sitecore\QA' -sqlServer $SqlServer -sqlAdminUser $SqlAdminUser -sqlAdminPassword $SqlAdminPassword

Add-RoleToUser $coreDatabaseName -roleName 'sitecore\Commerce Administrator' -userName 'sitecore\admin' -sqlServer $SqlServer -sqlAdminUser $SqlAdminUser -sqlAdminPassword $SqlAdminPassword
Add-RoleToUser $coreDatabaseName -roleName 'sitecore\Commerce Business User' -userName 'sitecore\admin' -sqlServer $SqlServer -sqlAdminUser $SqlAdminUser -sqlAdminPassword $SqlAdminPassword

Add-RoleToRole $coreDatabaseName -memberRoleName 'sitecore\Customer Service Representative' -targetRoleName 'sitecore\Commerce Business User' -sqlServer $SqlServer -sqlAdminUser $SqlAdminUser -sqlAdminPassword $SqlAdminPassword
Add-RoleToRole $coreDatabaseName -memberRoleName 'sitecore\Relationship Administrator' -targetRoleName 'sitecore\Commerce Business User' -sqlServer $SqlServer -sqlAdminUser $SqlAdminUser -sqlAdminPassword $SqlAdminPassword
Add-RoleToRole $coreDatabaseName -memberRoleName 'sitecore\Pricer' -targetRoleName 'sitecore\Commerce Business User' -sqlServer $SqlServer -sqlAdminUser $SqlAdminUser -sqlAdminPassword $SqlAdminPassword
Add-RoleToRole $coreDatabaseName -memberRoleName 'sitecore\Promotioner' -targetRoleName 'sitecore\Commerce Business User' -sqlServer $SqlServer -sqlAdminUser $SqlAdminUser -sqlAdminPassword $SqlAdminPassword
Add-RoleToRole $coreDatabaseName -memberRoleName 'sitecore\Merchandiser' -targetRoleName 'sitecore\Relationship Administrator' -sqlServer $SqlServer -sqlAdminUser $SqlAdminUser -sqlAdminPassword $SqlAdminPassword
Add-RoleToRole $coreDatabaseName -memberRoleName 'sitecore\Pricer Manager' -targetRoleName 'sitecore\Pricer' -sqlServer $SqlServer -sqlAdminUser $SqlAdminUser -sqlAdminPassword $SqlAdminPassword
Add-RoleToRole $coreDatabaseName -memberRoleName 'sitecore\Promotioner Manager' -targetRoleName 'sitecore\Promotioner' -sqlServer $SqlServer -sqlAdminUser $SqlAdminUser -sqlAdminPassword $SqlAdminPassword
Add-RoleToRole $coreDatabaseName -memberRoleName 'sitecore\Customer Service Representative Administrator' -targetRoleName 'sitecore\Customer Service Representative' -sqlServer $SqlServer -sqlAdminUser $SqlAdminUser -sqlAdminPassword $SqlAdminPassword
Add-RoleToRole $coreDatabaseName -memberRoleName 'sitecore\Commerce Administrator' -targetRoleName 'sitecore\Customer Service Representative Administrator' -sqlServer $SqlServer -sqlAdminUser $SqlAdminUser -sqlAdminPassword $SqlAdminPassword
Add-RoleToRole $coreDatabaseName -memberRoleName 'sitecore\Commerce Administrator' -targetRoleName 'sitecore\Pricer Manager' -sqlServer $SqlServer -sqlAdminUser $SqlAdminUser -sqlAdminPassword $SqlAdminPassword
Add-RoleToRole $coreDatabaseName -memberRoleName 'sitecore\Commerce Administrator' -targetRoleName 'sitecore\Promotioner Manager' -sqlServer $SqlServer -sqlAdminUser $SqlAdminUser -sqlAdminPassword $SqlAdminPassword
Add-RoleToRole $coreDatabaseName -memberRoleName 'sitecore\Commerce Administrator' -targetRoleName 'sitecore\Merchandiser' -sqlServer $SqlServer -sqlAdminUser $SqlAdminUser -sqlAdminPassword $SqlAdminPassword

if (-not $SkipStartingServer) {
    Stop-Service MSSQLSERVER
}