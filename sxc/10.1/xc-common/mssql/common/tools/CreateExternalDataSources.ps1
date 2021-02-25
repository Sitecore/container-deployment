param(
    [Parameter(Mandatory = $true)]
    [string] $SharedDatabaseName,

    [Parameter(Mandatory = $true)]
    [string] $ArchiveDatabaseName,

    [Parameter(Mandatory = $true)]
    [string] $MasterkeyPassword,

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

    $arguments = " -Q ""$Query"" -S '$SqlServer' "

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

function Add-DataSource {
    param(
        [string]$primaryDatabaseName,
        [string]$remoteDatabaseName,
        [string]$masterkeyPassword,
        [string]$sqlServer,
        [string]$sqlAdminUser,
        [string]$sqlAdminPassword,
        [string]$externalDataName
    )
    $sqlcmd =  "CREATE MASTER KEY ENCRYPTION BY PASSWORD = '$masterkeyPassword';
                CREATE DATABASE SCOPED CREDENTIAL ElasticDBQueryCred 
                WITH IDENTITY = '$sqlAdminUser', 
	            SECRET = '$sqlAdminPassword';   

                CREATE EXTERNAL DATA SOURCE $externalDataName WITH
                    (TYPE = RDBMS,
                     LOCATION = '$sqlServer',
                     DATABASE_NAME = '$remoteDatabaseName',
                     CREDENTIAL = ElasticDBQueryCred
                    );"
   
  Invoke-Sqlcmd -SqlDatabase $primaryDatabaseName -SqlServer $sqlServer -SqlAdminUser $sqlAdminUser -SqlAdminPassword $sqlAdminPassword -Query $sqlcmd
    Write-Host "Created external data source: $($externalDataName)."
}

if (-not $SkipStartingServer) {
    Start-Service MSSQLSERVER
}

Add-DataSource -primaryDatabaseName $SharedDatabaseName -remoteDatabaseName $ArchiveDatabaseName -masterkeyPassword $MasterkeyPassword -sqlServer $SqlServer -sqlAdminUser $SqlAdminUser -sqlAdminPassword $SqlAdminPassword -externalDataName 'CommerceArchiveDataSrc'
Add-DataSource -primaryDatabaseName $ArchiveDatabaseName -remoteDatabaseName $SharedDatabaseName -masterkeyPassword $MasterkeyPassword -sqlServer $SqlServer -sqlAdminUser $SqlAdminUser -sqlAdminPassword $SqlAdminPassword -externalDataName 'CommerceSharedDataSrc'

if (-not $SkipStartingServer) {
    Stop-Service MSSQLSERVER
}