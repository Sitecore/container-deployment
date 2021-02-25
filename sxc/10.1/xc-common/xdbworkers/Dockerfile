# This Dockerfile is used to generate images for the following roles: xdbsearchworker, xdbautomationworker

ARG BASE_IMAGE

FROM ${BASE_IMAGE}

WORKDIR /service

ARG CONTENT_PATH

COPY ${CONTENT_PATH} .