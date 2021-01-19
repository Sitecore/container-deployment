# escape=`

ARG BASE_IMAGE
ARG SXA_RESOURCES_IMAGE

FROM ${SXA_RESOURCES_IMAGE} AS sxa_resources

FROM ${BASE_IMAGE} AS sxa

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

COPY --from=sxa_resources C:\module\solr C:\sxa_data

RUN C:\Add-SolrCores.ps1 -SolrPath C:\solr -SolrSchemaPath C:\sxa_data\managed-schema -SolrCoreNames 'sitecore_sxa_master_index,sitecore_sxa_web_index'; `
    Remove-Item -Path C:\sxa_data -Recurse -Force;