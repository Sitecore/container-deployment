<<<<<<< Updated upstream
# delete everything from wwwroot
Write-Host "Emptying c:\inetpub\wwwroot folder"
Remove-Item -Recurse C:\inetpub\wwwroot\*

#Install rewrite module
try {
    Write-Host "Downloading rewrite module"
    Invoke-WebRequest -Uri "https://download.microsoft.com/download/1/2/8/128E2E22-C1B9-44A4-BE2A-5859ED1D4592/rewrite_amd64_en-US.msi" -OutFile rewrite_amd64_en-US.msi -ErrorAction Stop;
    Write-Host "Installing rewrite module"
    Start-Process -NoNewWindow -Wait msiexec.exe -ArgumentList /i, "rewrite_amd64_en-US.msi", /qn
}
catch {
    Write-Error "Installing rewrite module FAILED."
    Write-Error Error[0]
    exit(1)
}

#install logMonitor
try {
    Write-Host "Creating directory for Log Monitor"
    New-Item -Path "c:\\" -Name "LogMonitor" -ItemType "directory"; `
    Write-Host "Installing Log Monitor"
    Invoke-WebRequest -Uri "https://github.com/microsoft/windows-container-tools/releases/download/v1.1/LogMonitor.exe" -OutFile c:\LogMonitor\LogMonitor.exe;
}
catch {
    Write-Error "Installing Log Monitor FAILED"
    Write-Error Error[0]
    exit(1)
}

#remove the rewrite msi
Write-Host "Cleaning up downloaded file"
Remove-Item rewrite_amd64_en-US.msi -Recurse -Force;    
=======
# delete everything from wwwroot
Write-Host "Emptying c:\inetpub\wwwroot folder"
Remove-Item -Recurse C:\inetpub\wwwroot\*

#Install rewrite module
try {
    Write-Host "Downloading rewrite module"
    Invoke-WebRequest -Uri "https://download.microsoft.com/download/1/2/8/128E2E22-C1B9-44A4-BE2A-5859ED1D4592/rewrite_amd64_en-US.msi" -OutFile rewrite_amd64_en-US.msi -ErrorAction Stop;
    Write-Host "Installing rewrite module"
    Start-Process -NoNewWindow -Wait msiexec.exe -ArgumentList /i, "rewrite_amd64_en-US.msi", /qn
}
catch {
    Write-Error "Installing rewrite module FAILED."
    Write-Error Error[0]
    exit(1)
}

#install logMonitor
try {
    Write-Host "Creating directory for Log Monitor"
    New-Item -Path "c:\\" -Name "LogMonitor" -ItemType "directory"; `
    Write-Host "Installing Log Monitor"
    Invoke-WebRequest -Uri "https://github.com/microsoft/windows-container-tools/releases/download/v1.1/LogMonitor.exe" -OutFile c:\LogMonitor\LogMonitor.exe;
}
catch {
    Write-Error "Installing Log Monitor FAILED"
    Write-Error Error[0]
    exit(1)
}

#remove the rewrite msi
Write-Host "Cleaning up downloaded file"
Remove-Item rewrite_amd64_en-US.msi -Recurse -Force;    
>>>>>>> Stashed changes
