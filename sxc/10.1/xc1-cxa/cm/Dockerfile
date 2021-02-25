# escape=`

ARG BASE_IMAGE
ARG SPE_RESOURCES_IMAGE
ARG SXA_RESOURCES_IMAGE

FROM ${SPE_RESOURCES_IMAGE} AS spe_resources

FROM ${SXA_RESOURCES_IMAGE} AS sxa_resources

FROM ${BASE_IMAGE} AS spe

COPY --from=spe_resources C:\module\cm\content C:\inetpub\wwwroot

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

FROM spe AS sxa

COPY --from=sxa_resources C:\module\cm\content C:\inetpub\wwwroot
COPY --from=sxa_resources C:\module\tools C:\module\tools

ARG XC_RESOURCES_CONFIGS

ENV RESOURCES_CONFIGS=${XC_RESOURCES_CONFIGS}

COPY wdp/ C:/inetpub/wwwroot/

RUN c:\tools\scripts\Copy-Resources.ps1 -ResourcesConfigs $env:RESOURCES_CONFIGS -ResourcesPath c:\resources -DestinationPath c:\; `
    c:\tools\scripts\Invoke-XdtTransformations.ps1 -TargetPath c:\inetpub\wwwroot -XdtPath c:\xdts -XdtDllPath c:\tools\Microsoft.Web.Xdt\lib\netstandard2.0\Microsoft.Web.XmlTransform.dll;`
    C:\module\tools\Initialize-Content.ps1 -TargetPath C:\inetpub\wwwroot; `
    Remove-Item -Path C:\module -Recurse -Force;