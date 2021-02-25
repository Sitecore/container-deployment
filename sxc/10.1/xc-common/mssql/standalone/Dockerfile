# escape=`
# This Dockerfile is used to generate images for the following roles: mssql

ARG BASE_IMAGE

FROM ${BASE_IMAGE}

ARG SITECORE_CORE_DB
ENV SITECORE_CORE_DB=${SITECORE_CORE_DB}

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

COPY ./dacpacs ./dacpacs
COPY ./tools/DeployRoles.ps1 ./xc/tools/

RUN C:\DeployDatabases.ps1 -ResourcesDirectory C:\dacpacs -DatabaseOwner "sa" -EnableContainedDatabaseAuth; `
    .\xc\tools\DeployRoles.ps1 -coreDatabaseName $env:SITECORE_CORE_DB; `
    Remove-Item .\dacpacs -Recurse -Force; `
    Remove-Item .\xc -Recurse -Force;
