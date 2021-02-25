# Sitecore Experience Commerce Container Scripts

## Introduction

This folder contains a set of scripts and json files, provided as examples, to facilitate the creation of the Sitecore Experience Commerce container images using Docker.

## Scripts

**CleanContainerCache.ps1** -> cleans the Docker container images cache. The container images cache is used to speed any action that requires container images to be pulling container images from a registry. Some commands that use the container images cache are: <code>docker pull</code>, <code>docker-compose up</code>, <code>docker-compose build</code>. When running containers in a continuous integration pipeline, you should always start from a clean environment.

**ContainerBuild.ps1** -> builds container images based on the contents of the docker-compose.build.yml files. The results are container images with a tag of "latest".

**ContainerTag.ps1** -> tags container images with provided tag.

**CreateCertsXC0.cmd** -> deletes existing certificates and creates certifcates for xc0

**CreateCertsXC1-CXA.cmd** -> deletes existing certificates and creates certifcates for xc1-cxa

**PrepContainerBuild.ps1** -> takes the Sitecore Experience Commerce Release Package artifacts from [dev.sitecore.net](https://dev.sitecore.net) and expands them into the source code directory structure. This content will be use when calling <code>docker-compose build</code> to create container images.

**ScriptSupport.psm1** -> contains supporting functions used by the scripts.

**UpdateEnvCompose.ps1** -> updates a /[topology]/.env file with provided values.

**UpdateEnvTag.ps1** -> sets the registry, namespace, project and tag of container images.

**UpdateK8SYaml.ps1** -> sets Kubernetes secrets files with values from the configltsc2019 json file. Kubernetes only supports Windows LTSC 2019 images.

## JSON Files

**WDPMapping.json** -> used by the <code>PrepContainerBuild.ps1</code>. This file contains mapping information that is used to place the content of the release package artifacts in the correct location for use by the <code>docker-compose build</code> process. 
>**NOTE:** You must list packages with similar names starting with more exclusive package name, and ending with the less exclusive package name. For example: 
> ```JSON
>   {
>       "WDPs": [
>           "Sitecore Commerce Experience Accelerator Storefront Themes",
>           "Sitecore Commerce Experience Accelerator Storefront",
>           "Sitecore Commerce Experience Accelerator"
>       ],
>       "DestinationFolder": "xc1-cxa/cd/wdp",
>       "ToCopyFolder": "Content/Website"
>    }
> ```

**configltsc20H2.json**, **config2004.json**, **config2009.json**, and **configltsc2019.json** -> are used by the update scripts <code>UpdateEnvTag.ps1</code>, <code>UpdateEnvCompose.ps1</code> and <code>UpdateK8SYaml.ps1</code> to override or replace tokens defined in the .env and yaml files. This allows the customized files to be used in the build and run processes.

| Variable        | Value                       | Description                                                  |
| --------------- | --------------------------- | -------------------------------------------------------------|
| sxptag | 10.1.0-ltsc201 | Short tag of the SXP container image tag you want to consume. The short tag consists of the SXP version and the operating system version. |
| customercommercetag | 10.1.0-ltsc2019 | Tag for the XC container images you built with your application. |
| spetag | 6.2.0-1809 | Sitecore Powershell Extensions container image tag. |
| sxatag | 10.1.0-1809 | Sitecore Experience Accelerator container image tag. |
| scrdockerregistry | scr.sitecore.com | Sitecore Container Registry name. |
| sxpproject | platform | Sitecore Experience Platform container project name. |
| sxcproject | sxc | Sitecore Experience Commerce container project name. |
| baseproject | base | Container project name for base containers, like operating system containers from Microsoft. |
| modulesproject | modules | Container project name for Sitecore Modules, like Sitecore Experience Accelerator. |
| nonproductionproject | nonproduction | Container project name for container images that are not for production. Provided MSSQL and Solr container images are *not-production* images. It is expected that customers provide suitable MSSQL and Solr environments for production deployments. |
| nonproductiontag | 10.1.0-ltsc2019 | Image tag for non-production container images. |
| os_image_tag | ltsc2019 | Operating System name on which to build and run containers. Valid values are *ltsc2019* and *1909* |

**FakeLicenseFile.txt** -> this fake license file used as a place holder for the proper location to place the license file to be used by the -licenseFilePath command-line parameter.