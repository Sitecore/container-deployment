# escape=`

ARG BASE_IMAGE
ARG SXA_RESOURCES_IMAGE
ARG ASSETS_IMAGE

FROM ${ASSETS_IMAGE} AS assets

FROM ${SXA_RESOURCES_IMAGE} AS sxa_resources

FROM ${BASE_IMAGE} AS sxa

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

COPY --from=assets C:\module\solr C:\data
COPY --from=sxa_resources C:\module\solr\cores-sxa.json C:\data\cores-sxa.json