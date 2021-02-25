# escape=`
# This Dockerfile is used to generate images for the following roles: bizfx

ARG BASE_IMAGE
ARG XC_RESOURCES_IMAGE

FROM ${XC_RESOURCES_IMAGE} AS resources

FROM ${BASE_IMAGE}

ARG XC_RESOURCES_CONFIGS

COPY --from=resources C:\resources\configs C:\resources\configs
COPY --from=resources C:\resources\content C:\resources\content
COPY --from=resources c:\resources\tools\LogMonitor c:\LogMonitor
COPY --from=resources C:\resources\tools C:\tools

WORKDIR c:/inetpub/wwwroot

RUN NET USER commerce_admin /ADD /expires:never && `
    WMIC USERACCOUNT WHERE Name='commerce_admin' SET PasswordExpires=FALSE && `
    NET LOCALGROUP Administrators commerce_admin /ADD

USER commerce_admin

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

COPY .\InstallPrerequisites.ps1 .\

ENV RESOURCES_CONFIGS=${XC_RESOURCES_CONFIGS}

RUN .\InstallPrerequisites.ps1; `
    c:\tools\scripts\Copy-Resources.ps1 -ResourcesConfigs $env:RESOURCES_CONFIGS -ResourcesPath c:\resources -DestinationPath c:\; 

COPY wdp/ .
COPY Init.ps1 C:\inetpub

EXPOSE 80

HEALTHCHECK --start-period=300s `
    CMD powershell -command `
        try { `
            $response = Invoke-WebRequest http://localhost -UseBasicParsing; `
            if ($response.StatusCode -eq 200) { exit 0 } else { exit 1 }; `
        } catch { exit 1 }

ENTRYPOINT ["C:\\LogMonitor\\LogMonitor.exe", "powershell.exe", "C:\\inetpub\\Init.ps1", "C:\\inetpub\\wwwroot\\assets\\config.json"]