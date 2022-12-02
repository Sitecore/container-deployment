param(
    [int]$RequestTimeout = 300,
    [string]$Server = "http://localhost",
    [string]$ReadyCheck = "/health",
    [string]$LiveCheck = "/health",
    [int]$Port = 5000
)

function InvokeWebRequest {
    param (
        [string]$Endpoint,
        [int]$RequestTimeout
    )

    try {
        $response = Invoke-WebRequest -Uri $Endpoint -UseBasicParsing -TimeoutSec $RequestTimeout
    }
    catch {
        $response = $_.Exception.Response
    }
    finally {
        Write-Information -MessageData "$Endpoint - $($response.StatusCode)" -InformationAction:Continue

        if ($response.StatusCode -eq 200) {
            $returnCode = 0
        } else {
            $returnCode = 1
        }
    }

    return $returnCode
}

$check = "$($Server):$port$LiveCheck"

$result = InvokeWebRequest -Endpoint $check -RequestTimeout $RequestTimeout

if ($result -eq 1) {
    exit 1
}

exit 0