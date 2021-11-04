# escape=`
# This Dockerfile is used to generate images for the following roles: prc, rep, xdba, xdbc

ARG BASE_IMAGE
ARG ASSETS_IMAGE

FROM ${ASSETS_IMAGE} AS assets

FROM ${BASE_IMAGE}

WORKDIR /inetpub/wwwroot

ARG CONTENT_PATH

COPY --from=assets module/${CONTENT_PATH}/App_data ./App_data/