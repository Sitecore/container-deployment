# escape=`
# This Dockerfile is used to generate images for the following roles: engine-authoring, engine-shops, engine-minions

ARG BASE_IMAGE
ARG ASSETS_IMAGE

FROM ${ASSETS_IMAGE} AS assets

FROM ${BASE_IMAGE}

ARG XC_ENGINE_PORT

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

COPY --from=assets module/tools/LogMonitor  C:\LogMonitor

COPY LogMonitor/ C:\LogMonitor
COPY HealthChecks/ C:\HealthChecks

USER ContainerAdministrator

ADD https://download.visualstudio.microsoft.com/download/pr/b84cc7e8-5bf7-4e35-bc2a-94903c823b5c/12f4767bded70bcfb4d56b3a6bfa005d/dotnet-hosting-3.1.31-win.exe .\install\dotnet.exe

ENV ASPNETCORE_URLS=http://+:${XC_ENGINE_PORT} `
    DOTNET_RUNNING_IN_CONTAINER=true `
    DOTNET_RUNNING_IN_CONTAINERS=true

RUN Start-Process -FilePath '.\install\dotnet.exe' -ArgumentList '/Passive /NoRestart' -Wait;

WORKDIR C:/engine
COPY wdp/ .

USER ContainerUser

EXPOSE ${XC_ENGINE_PORT}

ENTRYPOINT ["C:\\LogMonitor\\LogMonitor.exe", "dotnet.exe", "Sitecore.Commerce.Engine.dll"]