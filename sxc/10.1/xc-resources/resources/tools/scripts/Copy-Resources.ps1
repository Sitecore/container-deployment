param(
    [Parameter(Mandatory)]
    [string]$ResourcesConfigs,

    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ -PathType Container })]
    [string]$ResourcesPath,

    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ -PathType Container })]
    [string]$DestinationPath
)

Write-Information "resource configs dir $ResourcesConfigs"

$ResourcesConfigs.Split(',') | ForEach-Object {
    $configPath = [System.IO.Path]::Combine($ResourcesPath, "configs", "$_.txt")
    $contentPath = Join-Path $ResourcesPath "content"
    
    Get-Content $configPath | ForEach-Object {
        $resourceRoot = $_.Split([System.IO.Path]::DirectorySeparatorChar)[0]
        $resourceRootPath = Join-Path $contentPath $resourceRoot
        $resourcePath = Join-Path $contentPath $_
        $resourceDestination = $resourcePath.Replace($resourceRootPath, $DestinationPath)
        
        New-Item $resourceDestination -Force | Out-Null
        Copy-Item $resourcePath $resourceDestination -Force
    }
}