# AutoLogin Watchdog for BITS Wi-Fi (Windows)
# Continuously monitors the captive portal session and re-authenticates when needed.
# Configuration is read from the .env file.

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectDir = Split-Path -Parent $ScriptDir
$LogFile = Join-Path $ProjectDir "watchdog.log"
$EnvFile = Join-Path $ProjectDir ".env"

# Load CHECK_INTERVAL from .env (default: 300 seconds)
$CheckInterval = 300
if (Test-Path $EnvFile) {
    $envContent = Get-Content $EnvFile
    foreach ($line in $envContent) {
        if ($line -match '^CHECK_INTERVAL=["'']?(\d+)["'']?') {
            $CheckInterval = [int]$Matches[1]
        }
    }
}

function Write-Log($Message) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "$timestamp $Message"
}

# Trim log to last 500 lines on start
if (Test-Path $LogFile) {
    $lines = Get-Content $LogFile | Select-Object -Last 500
    $lines | Set-Content $LogFile
}

Write-Log "🔁 Watchdog started (interval: ${CheckInterval}s)"

$loopCount = 0

while ($true) {
    # Check if network is available
    $networkUp = Test-Connection -ComputerName 8.8.8.8 -Count 1 -Quiet -TimeoutSeconds 3 2>$null
    if (-not $networkUp) {
        # Also try the captive portal URL in case DNS/ping is blocked but HTTP works
        try {
            $null = Invoke-WebRequest -Uri "http://captive.apple.com" -UseBasicParsing -TimeoutSec 3 -MaximumRedirection 0 -ErrorAction Stop
            $networkUp = $true
        } catch [System.Net.WebException] {
            # Got a web response (even a redirect) = network is up
            if ($_.Exception.Response) { $networkUp = $true }
        } catch {
            # No response at all = no network
        }
    }

    if (-not $networkUp) {
        Write-Log "📡 No network connection (Wi-Fi off?). Skipping."
    } else {
        try {
            $response = Invoke-WebRequest -Uri "http://captive.apple.com" -UseBasicParsing -TimeoutSec 5 -MaximumRedirection 5
            $body = $response.Content

            if ($body -match "Success") {
                Write-Log "✅ Session active."
            } else {
                Write-Log "🔐 Captive portal detected! Re-authenticating..."
                Set-Location $ProjectDir
                & node index.js 2>&1 | Out-File -Append -FilePath $LogFile
                Write-Log "✅ Login script finished."
            }
        } catch {
            Write-Log "🔐 Captive portal detected! Re-authenticating..."
            Set-Location $ProjectDir
            & node index.js 2>&1 | Out-File -Append -FilePath $LogFile
            Write-Log "✅ Login script finished."
        }
    }

    # Trim log every ~50 checks
    $loopCount++
    if ($loopCount -ge 50) {
        $lines = Get-Content $LogFile | Select-Object -Last 200
        $lines | Set-Content $LogFile
        $loopCount = 0
    }

    Start-Sleep -Seconds $CheckInterval
}
