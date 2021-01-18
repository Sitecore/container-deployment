<<<<<<< Updated upstream
# escape=`
# This Dockerfile is used to generate images for the following roles: solr

ARG BASE_IMAGE

FROM ${BASE_IMAGE}

ARG SOLR_COMMERCE_CORE_NAMES

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

COPY ./wdp ./data-commerce
COPY ./tools/scripts ./

RUN .\Add-Commerce-SolrCores.ps1 -SolrPath C:\solr -SolrCoreNames $env:SOLR_COMMERCE_CORE_NAMES; `
    Remove-Item ./data-commerce -Recurse -Force

# hadolint ignore=DL3025
=======
# escape=`
# This Dockerfile is used to generate images for the following roles: solr

ARG BASE_IMAGE

FROM ${BASE_IMAGE}

ARG SOLR_COMMERCE_CORE_NAMES

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

COPY ./wdp ./data-commerce
COPY ./tools/scripts ./

RUN .\Add-Commerce-SolrCores.ps1 -SolrPath C:\solr -SolrCoreNames $env:SOLR_COMMERCE_CORE_NAMES; `
    Remove-Item ./data-commerce -Recurse -Force

# hadolint ignore=DL3025
>>>>>>> Stashed changes
CMD .\Start-Commerce.ps1 -InstallPath "c:\\solr\\server\\solr" -DataPath $env:SOLR_HOME -Verbose