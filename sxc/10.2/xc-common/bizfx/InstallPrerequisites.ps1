# delete everything from wwwroot
Write-Host "Emptying c:\inetpub\wwwroot folder"
Remove-Item -Recurse C:\inetpub\wwwroot\*

#Install rewrite module
try {
    Write-Host "Installing rewrite module"
    Start-Process -NoNewWindow -Wait msiexec.exe -ArgumentList /i, "c:\rewrite_amd64_en-US.msi", /qn
}
catch {
    Write-Error "Installing rewrite module FAILED."
    Write-Error Error[0]
    exit(1)
}

#remove the rewrite msi
Write-Host "Cleaning up downloaded file"
Remove-Item c:\rewrite_amd64_en-US.msi -Recurse -Force;    
