# escape=`
# This Dockerfile is used to generate images for the following roles: mssql

ARG BASE_IMAGE

FROM ${BASE_IMAGE}

ARG TOPOLOGY
ENV TOPOLOGY=${TOPOLOGY}

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

COPY ./dacpacs ./resources
COPY ./tools/StartCommerceInit.ps1 ./tools/DeployRoles.ps1 ./tools/CreateExternalDataSources.ps1  ./

# hadolint ignore=DL3025
ENTRYPOINT .\StartCommerceInit.ps1 -ResourcesDirectory $env:RESOURCES_PATH -SqlServer $env:SQL_SERVER -SqlAdminUser $env:SQL_ADMIN_LOGIN -SqlAdminPassword $env:SQL_ADMIN_PASSWORD -SitecoreAdminPassword $env:sitecore_admin_password -SqlElasticPoolName $env:SQL_ELASTIC_POOL_NAME -CoreDatabaseName $env:SITECORE_CORE_DB -SharedDatabaseName $env:XC_SHARED_DB -ArchiveDatabaseName $env:XC_SHARED_ARCHIVE_DB -MasterkeyPassword $env:XC_DB_Masterkey_Password  `
    -DatabaseUsers @( `
    @{'databaseName' = 'Sitecore.Master'; 'username' = $env:Master_Database_Username; 'password' = $env:Master_Database_Password}, `
    @{'databaseName' = 'Sitecore.Core'; 'username' = $env:Core_Database_Username; 'password' = $env:Core_Database_Password}, `
    @{'databaseName' = 'Sitecore.Web'; 'username' = $env:Web_Database_Username; 'password' = $env:Web_Database_Password}, `
    @{'databaseName' = 'Sitecore.Experienceforms'; 'username' = $env:Forms_Database_Username; 'password' = $env:Forms_Database_Password}, `
    @{'databaseName' = 'Sitecore.Exm.master'; 'username' = $env:Exm_Master_Database_Username; 'password' = $env:Exm_Master_Database_Password}, `
    @{'databaseName' = 'Sitecore.Marketingautomation'; 'username' = $env:Marketing_Automation_Database_Username; 'password' = $env:Marketing_Automation_Database_Password}, `
    @{'databaseName' = 'Sitecore.Messaging'; 'username' = $env:Messaging_Database_Username; 'password' = $env:Messaging_Database_Password }, `
    @{'databaseName' = 'Sitecore.Reporting'; 'username' = $env:Reporting_Database_Username; 'password' = $env:Reporting_Database_Password }, `
    @{'databaseName' = 'Sitecore.Referencedata'; 'username' = $env:Reference_Data_Database_Username; 'password' = $env:Reference_Data_Database_Password }, `
    @{'databaseName' = 'Sitecore.Processing.Pools'; 'username' = $env:Processing_Pools_Database_Username; 'password' = $env:Processing_Pools_Database_Password }, `
    @{'databaseName' = 'Sitecore.Processing.Tasks'; 'username' = $env:Processing_Tasks_Database_Username; 'password' = $env:Processing_Tasks_Database_Password }, `
    @{'databaseName' = 'Sitecore.Processing.Engine.Tasks'; 'username' = $env:Processing_Engine_Tasks_Database_Username; 'password' = $env:Processing_Engine_Tasks_Database_Password }, `
    @{'databaseName' = 'Sitecore.Processing.Engine.Storage'; 'username' = $env:Processing_Engine_Storage_Database_Username; 'password' = $env:Processing_Engine_Storage_Database_Password }, `
    @{'databaseName' = 'Sitecore.Xdb.Collection.ShardMapManager'; 'username' = $env:Collection_ShardMapManager_Database_Username; 'password' = $env:Collection_ShardMapManager_Database_Password }, `
    @{'databaseName' = 'Sitecore.Xdb.Collection.Shard0'; 'username' = $env:Collection_ShardMapManager_Database_Username; 'password' = $env:Collection_ShardMapManager_Database_Password }, `
    @{'databaseName' = 'Sitecore.Xdb.Collection.Shard1'; 'username' = $env:Collection_ShardMapManager_Database_Username; 'password' = $env:Collection_ShardMapManager_Database_Password } `
    )