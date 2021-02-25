param(
        [Parameter(Mandatory)]
        [string]$SolrEndpoint,

        [Parameter(Mandatory)]
        [string[]]$SolrCoreNames,

        [Parameter(Mandatory)]
        [string]$SolrCorePrefix,

        [Parameter(Mandatory)]
        [string]$SolrConfigsetName,

        [Parameter(Mandatory)]
        [string]$SolrReplicationFactor,

        [Parameter(Mandatory)]
        [string]$SolrNumberOfShards,
        
        [Parameter(Mandatory)]
        [string]$SolrMaxShardNumberPerNode,

        $SolrCollectionAliases
)
function Invoke-SolrWebRequest {
    param (
        [Parameter(Mandatory)]
        [string]$Uri
    )

    return Invoke-RestMethod -Credential (Get-SolrCredential) -Uri $Uri `
        -ContentType "application/json" -Method Post
}
foreach($solrCoreName in $SolrCoreNames) {

    $solrCollectionName = ('{0}{1}' -f $SolrCorePrefix, $solrCoreName)
    Write-Host "Creating $solrCollectionName SOLR collection"

    $solrUrl = [System.String]::Concat($SolrEndpoint, "/admin/collections?action=CREATE&name=", $solrCollectionName , 
        "&collection.configName=", $SolrConfigsetName, "&replicationFactor=", $SolrReplicationFactor, 
        "&numShards=", $SolrNumberOfShards, "&maxShardsPerNode=", $SolrMaxShardNumberPerNode, "&property.update.autoCreateFields=false")
    $null = Invoke-SolrWebRequest -Uri $solrUrl

    if( $SolrCollectionAliases.$solrCoreName ) {
        $aliasName = '{0}{1}' -f $SolrCorePrefix, $SolrCollectionAliases.$solrCoreName
        .\New-SolrAlias.ps1 -SolrEndpoint $SolrEndpoint -SolrCollectionName $solrCollectionName -AliasName $aliasName
    }
}