# escape=`
# This Dockerfile is used to generate images for the following roles: prc, rep, xdba, xdbc

ARG BASE_IMAGE
ARG ASSETS_IMAGE

FROM ${ASSETS_IMAGE} AS assets

FROM ${BASE_IMAGE}

ARG CONTENT_PATH

WORKDIR /inetpub/wwwroot

COPY --from=assets module/${CONTENT_PATH} C:\module
COPY --from=assets module/${CONTENT_PATH}/App_data .\App_data\

RUN Copy-Item -Path "C:\module\*.dll" -Destination "C:\inetpub\wwwroot\bin"; `
    Remove-Item -Path "C:\module" -Recurse -Force;