# escape=`
# This Dockerfile is used to generate images for the following roles: engine-authoring, engine-shops, engine-minions, engine-ops

ARG BASE_IMAGE

FROM ${BASE_IMAGE}

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

USER ContainerAdministrator

ADD http://do-srvc-01-dk1.dk.sitecore.net/dtservice/api/assets/deamon/LogMonitor.exe .\LogMonitor\LogMonitor.exe
ADD https://download.visualstudio.microsoft.com/download/pr/9b9f4a6e-aef8-41e0-90db-bae1b0cf4e34/4ab93354cdff8991d91a9f40d022d450/dotnet-hosting-3.1.6-win.exe .\install\dotnet.exe

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