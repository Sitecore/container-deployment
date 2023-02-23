# escape=`
# This Dockerfile is used to generate images for the following roles: engine-authoring, engine-shops, engine-minions, engine-ops

ARG BASE_IMAGE

FROM ${BASE_IMAGE}

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

USER ContainerAdministrator

ADD http://do-srvc-01-dk1.dk.sitecore.net/dtservice/api/assets/deamon/LogMonitor.exe .\LogMonitor\LogMonitor.exe
ADD https://download.visualstudio.microsoft.com/download/pr/b84cc7e8-5bf7-4e35-bc2a-94903c823b5c/12f4767bded70bcfb4d56b3a6bfa005d/dotnet-hosting-3.1.31-win.exe .\install\dotnet.exe

RUN Start-Process -FilePath '.\install\dotnet.exe' -ArgumentList '/Passive /NoRestart' -Wait;

ENV ASPNETCORE_URLS=http://+:5000 `
    DOTNET_RUNNING_IN_CONTAINER=true `
    DOTNET_RUNNING_IN_CONTAINERS=true

COPY /Healthchecks/Healthcheck.ps1 ./Healthchecks/
COPY /LogMonitor ./LogMonitor

WORKDIR C:/engine
COPY wdp/ .

USER ContainerUser

EXPOSE 5000

ENTRYPOINT ["C:\\LogMonitor\\LogMonitor.exe", "dotnet.exe", "Sitecore.Commerce.Engine.dll"]