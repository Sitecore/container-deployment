# escape=`
# This Dockerfile is used to generate images for the following roles: cd, cm

ARG BASE_IMAGE

FROM ${BASE_IMAGE}

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ENV DOTNET_RUNNING_IN_CONTAINER=true

COPY xdts c:/xdts
COPY tools c:/tools
COPY Permissions c:/Permissions

WORKDIR c:/inetpub/wwwroot

COPY Content/Website/ wdp/ ./

ADD https://dist.nuget.org/win-x86-commandline/v5.2.0/nuget.exe c:\tools

RUN New-Item -Path C:\inetpub\wwwroot\App_Config -Name Security-Shared -ItemType directory; `
    c:\tools\nuget.exe install Microsoft.Web.Xdt -Version 3.0.0 -OutputDirectory C:\tools -ExcludeVersion; `
    c:\tools\Invoke-XdtTransformations.ps1 -TargetPath c:\inetpub\wwwroot -XdtPath c:\xdts -XdtDllPath c:\tools\Microsoft.Web.Xdt\lib\netstandard2.0\Microsoft.Web.XmlTransform.dll;`
    Push-Location c:/inetpub/wwwroot/App_Config/Include/Y.Commerce.Engine; `
    Rename-Item Sitecore.Commerce.Engine.DataProvider.config.disabled Sitecore.Commerce.Engine.DataProvider.config; `
    Rename-Item Sitecore.Commerce.Engine.Connectors.Index.Common.config.disabled Sitecore.Commerce.Engine.Connectors.Index.Common.config; `
    Rename-Item Sitecore.Commerce.Engine.Connectors.Index.Solr.config.disabled Sitecore.Commerce.Engine.Connectors.Index.Solr.config; `
    Pop-Location; `
    Remove-Item -Path "./XConnectFiles/" -Recurse -Force;

ENTRYPOINT ["C:\\LogMonitor\\LogMonitor.exe", "powershell", "C:\\tools\\CopySecurityDomain.ps1; C:\\Run-W3SVCService.ps1"]
