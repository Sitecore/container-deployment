# escape=`

ARG BASE_IMAGE
ARG SXA_RESOURCES_IMAGE
ARG ASSETS_IMAGE

FROM ${ASSETS_IMAGE} AS assets

FROM ${SXA_RESOURCES_IMAGE} AS sxa_resources

FROM ${BASE_IMAGE}

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

COPY --from=assets C:\module\cd\content\inetpub\wwwroot C:\inetpub\wwwroot
COPY --from=assets C:\module\cd\content\xdts C:\xdts
COPY --from=sxa_resources C:\module\cd\content C:\inetpub\wwwroot
COPY --from=sxa_resources C:\module\tools C:\module\tools

RUN c:\tools\scripts\Invoke-XdtTransformations.ps1 -TargetPath c:\inetpub\wwwroot -XdtPath c:\xdts -XdtDllPath c:\tools\Microsoft.Web.Xdt\lib\netstandard2.0\Microsoft.Web.XmlTransform.dll;`
    C:\module\tools\Initialize-Content.ps1 -TargetPath C:\inetpub\wwwroot; `
    Remove-Item -Path C:\module -Recurse -Force;