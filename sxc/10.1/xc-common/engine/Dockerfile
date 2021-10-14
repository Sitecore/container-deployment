# escape=`
# This Dockerfile is used to generate images for the following roles: engine-authoring, engine-shops, engine-minions, engine-ops

ARG BASE_IMAGE
ARG XC_RESOURCES_IMAGE

FROM ${XC_RESOURCES_IMAGE} AS resources

FROM ${BASE_IMAGE}

ARG XC_RESOURCES_CONFIGS

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

COPY --from=resources C:\resources\configs C:\resources\configs
COPY --from=resources C:\resources\content C:\resources\content
COPY --from=resources c:\resources\tools\LogMonitor c:\LogMonitor
COPY --from=resources C:\resources\tools C:\tools

USER ContainerAdministrator

ADD https://download.visualstudio.microsoft.com/download/pr/c8eabe25-bb2b-4089-992e-48198ff72ad8/a55a5313bfb65ac9bd2e5069dd4de5bc/dotnet-hosting-3.1.15-win.exe .\install\dotnet.exe

ENV ASPNETCORE_URLS=http://+:5000 `
    DOTNET_RUNNING_IN_CONTAINER=true `
    DOTNET_RUNNING_IN_CONTAINERS=true `
    RESOURCES_CONFIGS=${XC_RESOURCES_CONFIGS}

RUN Start-Process -FilePath '.\install\dotnet.exe' -ArgumentList '/Passive /NoRestart' -Wait; `
    c:\tools\scripts\Copy-Resources.ps1 -ResourcesConfigs $env:RESOURCES_CONFIGS -ResourcesPath c:\resources -DestinationPath c:\;

WORKDIR C:/engine
COPY wdp/ .

USER ContainerUser

EXPOSE 5000

ENTRYPOINT ["C:\\LogMonitor\\LogMonitor.exe", "dotnet.exe", "Sitecore.Commerce.Engine.dll"]