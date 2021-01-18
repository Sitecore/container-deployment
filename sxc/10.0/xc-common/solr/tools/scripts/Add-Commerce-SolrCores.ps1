[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ -PathType Container })]
    [string]$SolrPath,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$SolrCoreNames,

    [string]$SolrCommercePostfix = "Scope",

    [string]$SolrCommerceRebuildPostfix = "-Rebuild"
)

function Create-SolrCore {
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $SourceCoreName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $TargetCoreName
    )
    
    $corePath = Join-Path $SolrPath "server\solr\$TargetCoreName"
    Copy-Item -Path (Join-Path $SolrPath "server\solr\configsets\_default\conf") -Destination (Join-Path $corePath "conf") -Recurse -Force
    
    Copy-Item -Path (Join-Path (Join-Path "data-commerce" $SourceCoreName) '\*') -Destination (Join-Path $corePath "conf") 
    
    $corePropertiesPath = Join-Path $corePath "core.properties"
    Set-Content -Path $corePropertiesPath -Value ("name=" + $TargetCoreName + [Environment]::NewLine + `
                                                  "config=solrconfig.xml" + [Environment]::NewLine + `
                                                  "update.autoCreateFields=false" + [Environment]::NewLine + `
                                                  "dataDir=data")
}

$SolrCoreNames -Split ',' | ForEach-Object {
    $name = ('{0}{1}' -f $_, $SolrCommercePostfix)

    Create-SolrCore -SourceCoreName $_ -TargetCoreName $name
    Create-SolrCore -SourceCoreName $_ -TargetCoreName ('{0}{1}' -f $name, $SolrCommerceRebuildPostfix)
}