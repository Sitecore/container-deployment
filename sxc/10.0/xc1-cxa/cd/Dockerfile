# escape=`

ARG BASE_IMAGE
ARG SXA_RESOURCES_IMAGE

FROM ${SXA_RESOURCES_IMAGE} AS sxa_resources

FROM ${BASE_IMAGE}

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

COPY --from=sxa_resources C:\module\cd\content C:\inetpub\wwwroot
COPY --from=sxa_resources C:\module\tools C:\module\tools

COPY Content/Website/ wdp/ C:/inetpub/wwwroot/
COPY xdts/ C:/inetpub/wwwroot/App_Data/SxaXdt

RUN C:\module\tools\Initialize-Content.ps1 -TargetPath C:\inetpub\wwwroot; `
    Remove-Item -Path C:\module -Recurse -Force;
   