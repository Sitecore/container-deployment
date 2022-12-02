# escape=`
# This Dockerfile is used to generate images for the following roles: mssql

ARG BASE_IMAGE
ARG ASSETS_IMAGE

FROM ${ASSETS_IMAGE} AS assets

FROM ${BASE_IMAGE}

ARG TOPOLOGY
ENV TOPOLOGY=${TOPOLOGY}
ENV SQL_DATABASE_PREFIX=Sitecore

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

COPY --from=assets C:\module\db C:\resources
COPY --from=assets C:\module\tools\scripts\StartCommerceInit.ps1 C:\module\tools\scripts\DeployRoles.ps1 C:\module\tools\scripts\CreateExternalDataSources.ps1  C:\


# hadolint ignore=DL3025
ENTRYPOINT ["powershell.exe", ".\\StartCommerceInit.ps1", "-ResourcesDirectory $env:RESOURCES_PATH", "-SqlServer $env:SQL_SERVER", "-SqlAdminUser $env:SQL_ADMIN_LOGIN", `
    "-SqlAdminPassword $env:SQL_ADMIN_PASSWORD", "-SitecoreAdminPassword $env:sitecore_admin_password", "-SqlDatabasePrefix $env:Sql_Database_Prefix", `
    "-SqlElasticPoolName $env:SQL_ELASTIC_POOL_NAME", " -DatabasesToDeploy $env:DATABASES_TO_DEPLOY", `
    "-PostDeploymentWaitPeriod $env:POST_DEPLOYMENT_WAIT_PERIOD", `
    "-SqlCustomDatabasePrefixUpdateFrom $env:SQL_CUSTOM_DATABASE_PREFIX_UPDATE_FROM", `
    "-CoreDatabaseName Core", "-SharedDatabaseName $env:XC_SHARED_DB", "-ArchiveDatabaseName $env:XC_SHARED_ARCHIVE_DB", "-MasterkeyPassword $env:XC_DB_Masterkey_Password", `
    "-DatabaseUsers @( `
    @{'databaseName' = $env:Sql_Database_Prefix + '.Master'; 'username' = $env:Master_Database_Username; 'password' = $env:Master_Database_Password}, `
    @{'databaseName' = $env:Sql_Database_Prefix + '.Core'; 'username' = $env:Core_Database_Username; 'password' = $env:Core_Database_Password}, `
    @{'databaseName' = $env:Sql_Database_Prefix + '.Web'; 'username' = $env:Web_Database_Username; 'password' = $env:Web_Database_Password}, `
    @{'databaseName' = $env:Sql_Database_Prefix + '.Experienceforms'; 'username' = $env:Forms_Database_Username; 'password' = $env:Forms_Database_Password}, `
    @{'databaseName' = $env:Sql_Database_Prefix + '.Exm.master'; 'username' = $env:Exm_Master_Database_Username; 'password' = $env:Exm_Master_Database_Password}, `
    @{'databaseName' = $env:Sql_Database_Prefix + '.Marketingautomation'; 'username' = $env:Marketing_Automation_Database_Username; 'password' = $env:Marketing_Automation_Database_Password}, `
    @{'databaseName' = $env:Sql_Database_Prefix + '.Messaging'; 'username' = $env:Messaging_Database_Username; 'password' = $env:Messaging_Database_Password }, `
    @{'databaseName' = $env:Sql_Database_Prefix + '.Reporting'; 'username' = $env:Reporting_Database_Username; 'password' = $env:Reporting_Database_Password }, `
    @{'databaseName' = $env:Sql_Database_Prefix + '.Referencedata'; 'username' = $env:Reference_Data_Database_Username; 'password' = $env:Reference_Data_Database_Password }, `
    @{'databaseName' = $env:Sql_Database_Prefix + '.Processing.Pools'; 'username' = $env:Processing_Pools_Database_Username; 'password' = $env:Processing_Pools_Database_Password }, `
    @{'databaseName' = $env:Sql_Database_Prefix + '.Processing.Tasks'; 'username' = $env:Processing_Tasks_Database_Username; 'password' = $env:Processing_Tasks_Database_Password }, `
    @{'databaseName' = $env:Sql_Database_Prefix + '.Processing.Engine.Tasks'; 'username' = $env:Processing_Engine_Tasks_Database_Username; 'password' = $env:Processing_Engine_Tasks_Database_Password }, `
    @{'databaseName' = $env:Sql_Database_Prefix + '.Processing.Engine.Storage'; 'username' = $env:Processing_Engine_Storage_Database_Username; 'password' = $env:Processing_Engine_Storage_Database_Password }, `
    @{'databaseName' = $env:Sql_Database_Prefix + '.Xdb.Collection.ShardMapManager'; 'username' = $env:Collection_ShardMapManager_Database_Username; 'password' = $env:Collection_ShardMapManager_Database_Password }, `
    @{'databaseName' = $env:Sql_Database_Prefix + '.Xdb.Collection.Shard0'; 'username' = $env:Collection_ShardMapManager_Database_Username; 'password' = $env:Collection_ShardMapManager_Database_Password }, `
    @{'databaseName' = $env:Sql_Database_Prefix + '.Xdb.Collection.Shard1'; 'username' = $env:Collection_ShardMapManager_Database_Username; 'password' = $env:Collection_ShardMapManager_Database_Password } `
    )"]