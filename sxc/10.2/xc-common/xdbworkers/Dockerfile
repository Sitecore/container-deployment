# This Dockerfile is used to generate images for the following roles: xdbsearchworker, xdbautomationworker

ARG BASE_IMAGE
ARG ASSETS_IMAGE

FROM ${ASSETS_IMAGE} AS assets

FROM ${BASE_IMAGE}

WORKDIR /service

ARG CONTENT_PATH

COPY --from=assets module/${CONTENT_PATH} .