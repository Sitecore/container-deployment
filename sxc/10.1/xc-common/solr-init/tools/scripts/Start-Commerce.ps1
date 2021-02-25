param(
    [Parameter(Mandatory)]
    [string]$SitecoreSolrConnectionString,

    [Parameter(Mandatory)]
    [string]$SolrSitecoreConfigsetSuffixName,

    [Parameter(Mandatory)]
    [string]$SolrCorePrefix,

    [Parameter(Mandatory)]
    [string]$SolrReplicationFactor,

    [Parameter(Mandatory)]
    [int]$SolrNumberOfShards,
    
    [Parameter(Mandatory)]
    [int]$SolrMaxShardsPerNodes,

    [string]$SolrXdbSchemaFile,

    [Parameter(Mandatory)]
    [string]$CommerceSolrConnectionString,
    
    [string]$SolrCommercePrefix,
    
    [string]$SolrCommercePostfix,

    [string]$SolrCommerceRebuildPostfix
)

function GetCommerceCoreNames {
    param (
        [ValidateSet("commerce")]
        [string]$CoreType
    )

    $resultCoreNames = @()
    Get-ChildItem C:\data -Filter cores*.json | ForEach-Object {
        $coreNames = (Get-Content $_.FullName | Out-String | ConvertFrom-Json).$CoreType
        if ($coreNames) {
            $resultCoreNames += $coreNames
        }
    }

    return $resultCoreNames
}

# XP start
.\Start.ps1 -SitecoreSolrConnectionString $SitecoreSolrConnectionString -SolrCorePrefix $SolrCorePrefix -SolrSitecoreConfigsetSuffixName $SolrSitecoreConfigsetSuffixName -SolrReplicationFactor $SolrReplicationFactor -SolrNumberOfShards $SolrNumberOfShards -SolrMaxShardsPerNodes $SolrMaxShardsPerNodes -SolrXdbSchemaFile .\data\schema.json

# Commerce Start
. .\Get-SolrCredential.ps1

$solrContext = .\Parse-ConnectionString.ps1 -SitecoreSolrConnectionString $CommerceSolrConnectionString
$SolrEndpoint = $solrContext.SolrEndpoint
$env:SOLR_USERNAME = $solrContext.SolrUsername
$env:SOLR_PASSWORD = $solrContext.SolrPassword

$solrBaseConfigDir = "C:\temp\commerce"
.\Download-SolrConfig.ps1 -SolrEndpoint $SolrEndpoint -OutPath $solrBaseConfigDir

$solrCommerceCoreNames = GetCommerceCoreNames("commerce")

foreach ($solrCoreName in $solrCommerceCoreNames) {
    Write-Information -MessageData "Trying to create collections for '$solrCoreName'." -InformationAction:Continue
    $solrCollectionName = ('_{0}{1}' -f $solrCoreName, $SolrCommercePostfix)
    $solrCollectionNameWithPrefix = ('{0}{1}' -f $SolrCommercePrefix, $solrCollectionName)

    $solrRebuildCollectionName = ('{0}{1}' -f $solrCollectionName , $SolrCommerceRebuildPostfix)
    
    if ($solrCollections -contains $solrCollectionName -or $solrCollections -contains $solrRebuildCollectionName) {
        Write-Information -MessageData "Commerce collections already exist. Use a collection name prefix different from '$SolrCommercePrefix'." -InformationAction:Continue
        return
    }

    $solrConfigsetName = ('{0}{1}' -f $solrCollectionNameWithPrefix, $SolrSitecoreConfigsetSuffixName)
    
    $solrConfigDir = Join-Path ".\temp" $solrConfigsetName
    $solrCoreDir =  Join-Path ".\data" $solrCoreName
    
    Copy-Item -Path $solrBaseConfigDir -Destination $solrConfigDir -Recurse -Force
    Copy-Item -Path (Join-Path $solrCoreDir "*") -Destination $solrConfigDir -Recurse -Force

    .\New-SolrConfig.ps1 -SolrEndpoint $SolrEndpoint -SolrConfigName $solrConfigsetName -SolrConfigDir $solrConfigDir

    .\New-SolrCore-Commerce.ps1 -SolrCoreNames $solrCollectionName -SolrEndpoint $SolrEndpoint -SolrCorePrefix $SolrCommercePrefix -SolrConfigsetName $solrConfigsetName -SolrReplicationFactor $SolrReplicationFactor -SolrNumberOfShards $SolrNumberOfShards -SolrMaxShardNumberPerNode $SolrMaxShardsPerNodes
    .\New-SolrCore-Commerce.ps1 -SolrCoreNames $solrRebuildCollectionName -SolrEndpoint $SolrEndpoint -SolrCorePrefix $SolrCommercePrefix -SolrConfigsetName $solrConfigsetName -SolrReplicationFactor $SolrReplicationFactor -SolrNumberOfShards $SolrNumberOfShards -SolrMaxShardNumberPerNode $SolrMaxShardsPerNodes
}

#clean up
Remove-Item "c:\temp" -Recurse -Force