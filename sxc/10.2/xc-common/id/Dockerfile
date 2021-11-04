# This Dockerfile is used to generate images for the following roles: id

ARG BASE_IMAGE
ARG ASSETS_IMAGE

FROM ${ASSETS_IMAGE} AS assets

FROM ${BASE_IMAGE}

WORKDIR c:/Identity

COPY --from=assets module/id/content .