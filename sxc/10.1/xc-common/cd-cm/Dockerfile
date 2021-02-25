# escape=`
# This Dockerfile is used to generate images for the following roles: cd, cm

ARG BASE_IMAGE
ARG XC_RESOURCES_IMAGE

FROM ${XC_RESOURCES_IMAGE} AS resources

FROM ${BASE_IMAGE}

ARG XC_RESOURCES_CONFIGS

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

COPY --from=resources C:\resources\configs C:\resources\configs
COPY --from=resources C:\resources\content C:\resources\content
COPY --from=resources C:\resources\tools C:\tools

ENV DOTNET_RUNNING_IN_CONTAINER=true `
    RESOURCES_CONFIGS=${XC_RESOURCES_CONFIGS}

WORKDIR c:/inetpub/wwwroot

COPY wdp/ ./

RUN New-Item -Path C:\inetpub\wwwroot\App_Config -Name Security-Shared -ItemType directory; `
    c:\tools\nuget.exe install Microsoft.Web.Xdt -Version 3.0.0 -OutputDirectory C:\tools -ExcludeVersion; `
    c:\tools\scripts\Copy-Resources.ps1 -ResourcesConfigs $env:RESOURCES_CONFIGS -ResourcesPath c:\resources -DestinationPath c:\; `
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