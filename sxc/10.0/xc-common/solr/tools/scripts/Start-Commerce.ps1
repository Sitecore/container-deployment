
param(
    [Parameter(Mandatory = $true)]
    [ValidateScript( { Test-Path $_ -PathType 'Container' })]
    [string]$InstallPath,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { Test-Path $_ -PathType 'Container' })]
    [string]$DataPath
)

$dataFolderEmpty = ($null -eq (Get-ChildItem -Path $DataPath -Filter "solr.xml"))
if ($dataFolderEmpty)
{
    Write-Host "INFO: Solr configuration not found in '$DataPath', copying clean configuration..."

    Get-ChildItem -Path $InstallPath | ForEach-Object {
        Copy-Item -Recurse -Path $_.FullName -Destination $DataPath
    }
}
else
{
    Write-Host "INFO: Existing Solr configuration found in '$DataPath'..."
}

c:\solr\bin\solr.cmd start -port 8983 -f
