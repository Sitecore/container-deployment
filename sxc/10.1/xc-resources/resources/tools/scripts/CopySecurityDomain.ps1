$env:IIS_APPPOOL_IDENTITY = 'IIS AppPool\DefaultAppPool';
C:\tools\scripts\GrantWritePermission.ps1 -TargetFoldersFile 'C:\Permissions\AdditionalWriteAllowedFolders.txt' -User $env:IIS_APPPOOL_IDENTITY;

if (-not (Test-Path C:\inetpub\wwwroot\App_Config\Security-Shared\Domains.config)) { 
    Copy-Item -Path C:\inetpub\wwwroot\App_Config\Security\Domains.config -Destination C:\inetpub\wwwroot\App_Config\Security-Shared\Domains.config 
};