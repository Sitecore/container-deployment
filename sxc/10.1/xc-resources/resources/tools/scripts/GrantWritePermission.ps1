param(
    [Parameter(Mandatory=$true, ParameterSetName="Array")]
    [string[]] $TargetFolders,

    [Parameter(Mandatory=$true, ParameterSetName="File")]
    [string] $TargetFoldersFile,

    [Parameter(Mandatory=$true)]
    [string] $User
)

if ($TargetFoldersFile) {
    $TargetFolders = Get-Content -Path $TargetFoldersFile
}

$TargetFolders | ForEach-Object {
    If (-not [string]::IsNullOrEmpty($_)) {
        If (!(Test-Path $_)) {
            New-Item -Path $_ -ItemType Directory -Force
        }

        cmd /C icacls $_ /grant ($User + ":(OI)(CI)M")
    }
}