# escape=`
# This Dockerfile is used to generate images for the following roles: prc, rep, xdba, xdbc

ARG BASE_IMAGE
ARG ASSETS_IMAGE

FROM ${ASSETS_IMAGE} AS assets

FROM ${BASE_IMAGE}

ARG ROLE

WORKDIR /inetpub/wwwroot

COPY --from=assets module/${ROLE}/content/inetpub/wwwroot ./