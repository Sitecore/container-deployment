# Sitecore Experience Commerce Container Scripts

## Introduction

This folder contains a set of scripts and json files, provided as examples, to facilitate the creation of the Sitecore Experience Commerce container images using Docker.

## Scripts

**CleanContainerCache.ps1** -> cleans the Docker container images cache. The container images cache is used to speed any action that requires container images to be pulling container images from a registry. Some commands that use the container images cache are: <code>docker pull</code>, <code>docker-compose up</code>, <code>docker-compose build</code>. When running containers in a continuous integration pipeline, you should always start from a clean environment.

**ComposeInit.ps1** -> performs the necessary prerequisites on setting up a docker environment including modifying the environment file, creating and installing of certificates, updating of the hosts file, and validation that the volume mapping folders exist. Only a minimum set of parameters are required to perform a default deployment.

**ContainerBuild.ps1** -> builds container images based on the contents of the docker-compose.build.yml files. The results are container images with a tag of "latest".

**ContainerTag.ps1** -> tags container images with provided tag.

**PrepEngineContainerBuild.ps1** -> Takes the Sitecore.Commerce.Engine.OnPrem.Solr and Sitecore.BizFx.OnPrem WDP's from
[dev.sitecore.net](https://dev.sitecore.net) and expands them into the structure expected by the Sitecore XC container Docker files. 
This content will be use when calling <code>docker-compose build</code> to create container images.

**UpdateEnvTag.ps1** -> sets the registry, namespace, project and tag of container images.

**UpdateK8SYaml.ps1** -> sets Kubernetes secrets files with values from the configltsc2019 or configltsc2022 json file. Kubernetes only supports Windows LTSC 2019 and LSTC 2022 images.

## JSON Files

**configltsc2019.json**, and  **configltsc2022.json** -> are used by the update scripts <code>UpdateEnvTag.ps1</code>, <code>UpdateEnvCompose.ps1</code> and <code>UpdateK8SYaml.ps1</code> to override or replace tokens defined in the .env and yaml files. This allows the customized files to be used in the build and run processes.

| Variable        | Value                       | Description                                                  |
| --------------- | --------------------------- | -------------------------------------------------------------|
| sxptag | 10.3-ltsc2019 | Short tag of the SXP container image tag you want to consume. The short tag consists of the SXP version and the operating system version. |
| customercommercetag | 10.3-ltsc2019 | Tag for the XC container images you built with your application. |
| spetag | 6.4-1809 | Sitecore Powershell Extensions container image tag. |
| sxatag | 10.3-1809 | Sitecore Experience Accelerator container image tag. |
| scrdockerregistry | scr.sitecore.com | Sitecore Container Registry name. |
| sxpproject | platform | Sitecore Experience Platform container project name. |
| sxcproject | sxc | Sitecore Experience Commerce container project name. |
| baseproject | base | Container project name for base containers, like operating system containers from Microsoft. |
| modulesproject | modules | Container project name for Sitecore Modules, like Sitecore Experience Accelerator. |
| nonproductionproject | nonproduction | Container project name for container images that are not for production. Provided MSSQL and Solr container images are *not-production* images. It is expected that customers provide suitable MSSQL and Solr environments for production deployments. |
| nonproductiontag | 10.3-ltsc2019 | Image tag for non-production container images. |
| os_image_tag | ltsc2019 | Operating System name on which to build and run containers. Valid values are *ltsc2022*, *ltsc2019* |
| powershell_image_tag | 1809 | Powershell Image to support k8s only. Valid values are *ltsc2022* and *1809* |
