# escape=`

ARG BASE_IMAGE

FROM ${BASE_IMAGE}

COPY . .\resources

ADD https://dist.nuget.org/win-x86-commandline/v5.2.0/nuget.exe C:\resources\tools

ADD https://github.com/microsoft/windows-container-tools/releases/download/v1.1/LogMonitor.exe C:\resources\tools\LogMonitor\LogMonitor.exe