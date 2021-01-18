<<<<<<< Updated upstream
# escape=`
# This Dockerfile is used to generate images for the following roles: bizfx

ARG BASE_IMAGE

FROM ${BASE_IMAGE}

WORKDIR c:/inetpub/wwwroot

RUN NET USER commerce_admin /ADD /expires:never && `
    WMIC USERACCOUNT WHERE Name='commerce_admin' SET PasswordExpires=FALSE && `
    NET LOCALGROUP Administrators commerce_admin /ADD

USER commerce_admin

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

COPY .\InstallPrerequisites.ps1 .\
RUN .\InstallPrerequisites.ps1;

COPY wdp/ .
COPY Init.ps1 "C:\\inetpub\\"
COPY LogMonitorConfig.json "c:\\LogMonitor\\"

EXPOSE 80

HEALTHCHECK --start-period=300s `
    CMD powershell -command `
        try { `
            $response = Invoke-WebRequest http://localhost -UseBasicParsing; `
            if ($response.StatusCode -eq 200) { exit 0 } else { exit 1 }; `
        } catch { exit 1 }

=======
# escape=`
# This Dockerfile is used to generate images for the following roles: bizfx

ARG BASE_IMAGE

FROM ${BASE_IMAGE}

WORKDIR c:/inetpub/wwwroot

RUN NET USER commerce_admin /ADD /expires:never && `
    WMIC USERACCOUNT WHERE Name='commerce_admin' SET PasswordExpires=FALSE && `
    NET LOCALGROUP Administrators commerce_admin /ADD

USER commerce_admin

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

COPY .\InstallPrerequisites.ps1 .\
RUN .\InstallPrerequisites.ps1;

COPY wdp/ .
COPY Init.ps1 "C:\\inetpub\\"
COPY LogMonitorConfig.json "c:\\LogMonitor\\"

EXPOSE 80

HEALTHCHECK --start-period=300s `
    CMD powershell -command `
        try { `
            $response = Invoke-WebRequest http://localhost -UseBasicParsing; `
            if ($response.StatusCode -eq 200) { exit 0 } else { exit 1 }; `
        } catch { exit 1 }

>>>>>>> Stashed changes
ENTRYPOINT ["C:\\LogMonitor\\LogMonitor.exe", "powershell.exe", "C:\\inetpub\\Init.ps1", "C:\\inetpub\\wwwroot\\assets\\config.json"]