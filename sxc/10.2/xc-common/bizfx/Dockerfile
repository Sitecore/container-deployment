# escape=`
# This Dockerfile is used to generate images for the following roles: bizfx

ARG BASE_IMAGE
ARG ASSETS_IMAGE

FROM ${ASSETS_IMAGE} AS assets

FROM ${BASE_IMAGE}

WORKDIR c:/inetpub/wwwroot

RUN NET USER commerce_admin /ADD /expires:never && `
    WMIC USERACCOUNT WHERE Name='commerce_admin' SET PasswordExpires=FALSE && `
    NET LOCALGROUP Administrators commerce_admin /ADD

USER commerce_admin

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

COPY --from=assets module/tools/LogMonitor  C:\LogMonitor

COPY .\InstallPrerequisites.ps1 .\
COPY LogMonitor/ c:\LogMonitor

ADD https://download.microsoft.com/download/1/2/8/128E2E22-C1B9-44A4-BE2A-5859ED1D4592/rewrite_amd64_en-US.msi c:/rewrite_amd64_en-US.msi

RUN .\InstallPrerequisites.ps1; 

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