# escape=`

ARG BASE_IMAGE
ARG ASSETS_IMAGE

FROM ${ASSETS_IMAGE} AS assets

FROM ${BASE_IMAGE}

ARG XC_TOPOLOGY
ARG SOLR_XDB_SCHEMA_FILE

ENV SOLR_SITECORE_CONFIGSET_SUFFIX_NAME=_config `
    SOLR_REPLICATION_FACTOR=1 `
    SOLR_NUMBER_OF_SHARDS=1 `
    SOLR_MAX_SHARDS_NUMBER_PER_NODES=1 `
    SOLR_CORE_PREFIX_NAME=sitecore `
    SOLR_XDB_SCHEMA_FILE=${SOLR_XDB_SCHEMA_FILE} `
    TOPOLOGY=${XC_TOPOLOGY} `
    SOLR_COMMERCE_PREFIX_NAME=commerce `
    SOLR_COMMERCE_POSTFIX_NAME=Scope `
    SOLR_COMMERCE_REBUILD_POSTFIX_NAME=-Rebuild

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

COPY --from=assets C:\module\solr C:\data
COPY --from=assets C:\module\tools\scripts\New-SolrCore-Commerce.ps1 C:\module\tools\scripts\Start-Commerce.ps1  C:\

ENTRYPOINT .\Start-Commerce.ps1 -SitecoreSolrConnectionString $env:SITECORE_SOLR_CONNECTION_STRING `
-SolrCorePrefix $env:SOLR_CORE_PREFIX_NAME `
-SolrSitecoreConfigsetSuffixName $env:SOLR_SITECORE_CONFIGSET_SUFFIX_NAME `
-SolrReplicationFactor $env:SOLR_REPLICATION_FACTOR `
-SolrNumberOfShards $env:SOLR_NUMBER_OF_SHARDS `
-SolrMaxShardsPerNodes $env:SOLR_MAX_SHARDS_NUMBER_PER_NODES `
-SolrXdbSchemaFile .\data\schema.json `
-CommerceSolrConnectionString $env:Commerce_SOLR_CONNECTION_STRING `
-SolrCommercePrefix $env:SOLR_COMMERCE_PREFIX_NAME `
-SolrCommercePostfix $env:SOLR_COMMERCE_POSTFIX_NAME `
-SolrCommerceRebuildPostfix $env:SOLR_COMMERCE_REBUILD_POSTFIX_NAME 
