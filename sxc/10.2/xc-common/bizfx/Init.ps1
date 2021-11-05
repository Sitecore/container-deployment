param(
    [Parameter(Mandatory = $true)]
    [string] $ConfigPath
)
$config = Get-Content -Path $ConfigPath | ConvertFrom-Json
$settings = @{
    "EngineUri" = $env:sitecore_xc_bizfx_authoring_url
    "IdentityServerUri" = $env:sitecore_xc_bizfx_identity_server_url
    "BizFxUri" = $env:sitecore_xc_bizfx_bizfx_url
    "Language" = $env:sitecore_xc_bizfx_default_language
    "ContentLanguage" = $env:sitecore_xc_bizfx_default_language
    "Currency" = $env:sitecore_xc_bizfx_default_currency
    "ShopName" = $env:sitecore_xc_bizfx_default_shopname
}
foreach ($key in $settings.Keys) {
    Write-Host "Updating [$configPath] config: Set [$($settings.Item($key))] as [$key]"
    $config.$key = $settings.Item($key)
}
$config | ConvertTo-Json | Set-Content $ConfigPath

& "C:\ServiceMonitor.exe" w3svc
