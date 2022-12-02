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

ADD https://download.visualstudio.microsoft.com/download/pr/db07eed5-297a-45b8-bea2-1e93c623a88c/6e5a8d3432e6213f071be3751ae53a08/dotnet-hosting-6.0.11-win.exe .\install\dotnet.exe

ENV ASPNETCORE_URLS=http://+:${XC_ENGINE_PORT} `
    DOTNET_RUNNING_IN_CONTAINER=true `
    DOTNET_RUNNING_IN_CONTAINERS=true

RUN Start-Process -FilePath '.\install\dotnet.exe' -ArgumentList '/Passive /NoRestart' -Wait;

WORKDIR C:/engine
COPY wdp/ .

USER ContainerUser

EXPOSE ${XC_ENGINE_PORT}

ENTRYPOINT ["C:\\LogMonitor\\LogMonitor.exe", "dotnet.exe", "Sitecore.Commerce.Engine.dll"]