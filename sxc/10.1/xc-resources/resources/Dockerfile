# escape=`

ARG BASE_IMAGE

FROM ${BASE_IMAGE}

COPY . .\resources

ADD https://dist.nuget.org/win-x86-commandline/v5.2.0/nuget.exe C:\resources\tools

ADD http://do-srvc-01-dk1.dk.sitecore.net/dtservice/api/assets/deamon/LogMonitor.exe C:\resources\tools\LogMonitor\LogMonitor.exe