Function ConvertToCompressedBase64String {
    Param (
        [Parameter(Mandatory)]
        [ValidateScript( {
                if (-Not ($_ | Test-Path) ) { throw "The file or folder $_ does not exist" }
                if (-Not ($_ | Test-Path -PathType Leaf) ) { throw "The Path argument must be a file. Folder paths are not allowed." }
                return $true
            })]
        [string] $Path
    )

    $fileBytes = [System.IO.File]::ReadAllBytes($Path)

    [System.IO.MemoryStream] $memoryStream = New-Object System.IO.MemoryStream

    $gzipStream = New-Object System.IO.Compression.GzipStream $memoryStream, ([IO.Compression.CompressionMode]::Compress)
    $gzipStream.Write($fileBytes, 0, $fileBytes.Length)

    $gzipStream.Close()
    $memoryStream.Close()
    $gzipStream.Dispose()
    $memoryStream.Dispose()

    return [Convert]::ToBase64String($memoryStream.ToArray())
}

Function GenerateRandomString {
    param(
        [int] $length,
        [switch] $disallowSpecialCharacters
    )

    $chars = @()
    $chars += ('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z')
    $chars += ('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z')
    $chars += ('1', '2', '3', '4', '5', '6', '7', '8', '9', '0')
    
    if (-not $disallowSpecialCharacters) {
        $chars += ('~', '!', '@', '#', '$', '%', '^', '&', '*', '_', '-', '+', '=', [char]0x60, '|', '\', '(', ')', '{', '}', '[', ']', ':', ';', '<', '>', '.', '?', '/')
    }

    $generatedString = ""

    for ($i = 1; $i -le $length; $i++) {
        $generatedString += Get-Random $chars
    }

    return $generatedString
}

Function Confirm-VolumeFoldersExist {
    param (
        [string] $Path
    )
    Write-Host "Verifying Folders for Commerce Engine volumes exist in [$Path]"

    "cm\domains-shared",
    "cd\domains-shared",
    "engine\catalogs",
    "mssql-data",
    "solr-data" |
    ForEach-Object { 
        if (-Not (Test-Path (Join-Path $Path $_))) {
            Write-Verbose "Creating folder [$_]"
            New-Item -Path $Path -Name $_ -ItemType Directory
        }
    }
}
