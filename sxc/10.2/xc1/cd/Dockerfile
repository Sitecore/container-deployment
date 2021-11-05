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
COPY --from=assets module/${XC_ROLE_CONFIGS}/content/xdts C:\xdts
COPY --from=assets module/tools  C:\tools

# Copy any custom files from build location
COPY . .

RUN New-Item -Path C:\inetpub\wwwroot\App_Config -Name Security-Shared -ItemType directory; `
    c:\tools\nuget.exe install Microsoft.Web.Xdt -Version 3.0.0 -OutputDirectory C:\tools -ExcludeVersion; ` 
    c:\tools\scripts\Invoke-XdtTransformations.ps1 -TargetPath c:\inetpub\wwwroot -XdtPath c:\xdts -XdtDllPath c:\tools\Microsoft.Web.Xdt\lib\netstandard2.0\Microsoft.Web.XmlTransform.dll;`
    Push-Location c:/inetpub/wwwroot/App_Config/Include/Y.Commerce.Engine; `
    Rename-Item Sitecore.Commerce.Engine.DataProvider.config.disabled Sitecore.Commerce.Engine.DataProvider.config; `
    Rename-Item Sitecore.Commerce.Engine.Connectors.Index.Common.config.disabled Sitecore.Commerce.Engine.Connectors.Index.Common.config; `
    Rename-Item Sitecore.Commerce.Engine.Connectors.Index.Solr.config.disabled Sitecore.Commerce.Engine.Connectors.Index.Solr.config; `
    Pop-Location; `
    Remove-Item -Path "./XConnectFiles/" -Recurse -Force; 

SHELL ["C:\\LogMonitor\\LogMonitor.exe", "powershell.exe"]

# hadolint ignore=DL3025
ENTRYPOINT $env:IIS_APPPOOL_IDENTITY = 'IIS AppPool\DefaultAppPool'; `
        C:\tools\scripts\GrantWritePermission.ps1 -TargetFoldersFile 'C:\Permissions\AdditionalWriteAllowedFolders.txt' -User $env:IIS_APPPOOL_IDENTITY; `
        if (-not (Test-Path C:\inetpub\wwwroot\App_Config\Security-Shared\Domains.config)) { Copy-Item -Path C:\inetpub\wwwroot\App_Config\Security\Domains.config -Destination C:\inetpub\wwwroot\App_Config\Security-Shared\Domains.config }; `
        C:\ServiceMonitor.exe w3svc;