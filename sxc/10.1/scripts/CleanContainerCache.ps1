<#
.SYNOPSIS
Cleans the container images cache on a Windows machine. Presumes the default location of Docker Desktop installation.

.DESCRIPTION
Cleans the container images cache on a Windows machine. Presumes the default installation location of C:\ProgramData\docker\windowsfilter\
for Docker Desktop cache.

No parameters required.

.EXAMPLE
CleanContainerCache.ps1
#>

#Swallow all the errors
function CleanCache {
    Invoke-Command -Script {
        $ErrorActionPreference="silentlycontinue"
        & docker rmi $allImages --force 2>&1 > $null | Out-Null
    } -ErrorAction SilentlyContinue | Out-Null -ErrorAction SilentlyContinue
}

Write-Host "=======================CACHE INFO============================"
Write-host "Count of images:"((& docker image ls -a | measure).Count -1)
Write-Host "Count of cache directories:"(Get-ChildItem -path C:\ProgramData\docker\windowsfilter\ -force | measure).Count
Write-Host "Diskspace used:"
& docker system df
Write-Host "=============================================================`n"

Write-Host "==============STOPPING RUNNING CONTAINERS===================="
$runningContainers = docker ps -a -q 
if ($null -ne $runningContainers){
  & docker stop $runningContainers
  & docker rm $runningContainers
}
Write-Host "============================================================`n"

Write-Host "=====================CLEANING CACHE========================="
$allImages = docker images -a -q
if ($null -ne $allImages){
    #Try/catch to swallow the writes to stderr, if there are errors,
    #write warnings
    try {
        & docker images -a -q
        CleanCache
    } catch {
        Write-Warning "Warnings: `n"
        Format-list * -InputObject $_ -Force
    } finally {
        Write-Host "Finished"
    }
}
Write-Host "=============================================================`n"

Write-Host "======================PRUNING SYSTEM========================="
Write-Host 'docker system prune -a -f'
docker system prune -a -f
Write-Host "============================================================="

Write-Host "=======================CACHE INFO============================"
Write-host "Count of images:"((docker image ls -a | measure).Count -1)
Write-Host "Count of cache directories:"(Get-ChildItem -path C:\ProgramData\docker\windowsfilter\ -force | measure).Count
Write-Host "Diskspace used:"
docker system df
Write-Host "============================================================="
