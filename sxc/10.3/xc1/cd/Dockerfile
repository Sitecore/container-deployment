# escape=`
# This Dockerfile is used to generate images for the following roles: cd, cm

ARG BASE_IMAGE
ARG ASSETS_IMAGE

FROM ${ASSETS_IMAGE} AS assets

FROM ${BASE_IMAGE}

ARG XC_ROLE_CONFIGS

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ENV DOTNET_RUNNING_IN_CONTAINER=true

WORKDIR c:/inetpub/wwwroot

COPY --from=assets module/${XC_ROLE_CONFIGS}/content/inetpub/wwwroot .
COPY --from=assets module/sample/content/inetpub/wwwroot .
COPY --from=assets module/${XC_ROLE_CONFIGS}/content/Permissions C:\Permissions
COPY --from=assets module/tools  C:\tools

# Copy any custom files from build location
COPY . .

RUN New-Item -Path C:\inetpub\wwwroot\App_Config -Name Security-Shared -ItemType directory; `
    Push-Location c:/inetpub/wwwroot/App_Config/Include/Y.Commerce.Engine; `
    Rename-Item Sitecore.Commerce.Engine.DataProvider.config.disabled Sitecore.Commerce.Engine.DataProvider.config; `
    Rename-Item Sitecore.Commerce.Engine.Connectors.Index.Common.config.disabled Sitecore.Commerce.Engine.Connectors.Index.Common.config; `
    Rename-Item Sitecore.Commerce.Engine.Connectors.Index.Solr.config.disabled Sitecore.Commerce.Engine.Connectors.Index.Solr.config; `
    Pop-Location; `
    Remove-Item -Path "./XConnectFiles/" -Recurse -Force;

ENTRYPOINT ["C:\\LogMonitor\\LogMonitor.exe", "powershell", "C:\\tools\\scripts\\CopySecurityDomain.ps1; C:\\Run-W3SVCService.ps1"]