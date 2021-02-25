# escape=`
# This Dockerfile is used to generate images for the following roles: prc, rep, xdba, xdbc

ARG BASE_IMAGE

FROM ${BASE_IMAGE}

WORKDIR /inetpub/wwwroot

ARG CONTENT_PATH

COPY ${CONTENT_PATH}/App_data ./App_data/
COPY ${CONTENT_PATH}/*.dll ./bin/
