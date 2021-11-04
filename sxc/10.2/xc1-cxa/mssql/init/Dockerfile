# escape=`

ARG BASE_IMAGE
ARG SPE_RESOURCES_IMAGE
ARG ASSETS_IMAGE

FROM ${ASSETS_IMAGE} AS assets

FROM ${SPE_RESOURCES_IMAGE} AS spe_resources

FROM ${BASE_IMAGE} AS spe

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

COPY --from=assets C:\module\db C:\resources

COPY --from=spe_resources C:\module\db C:\resources\spe

FROM spe AS cxa