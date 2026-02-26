# AutoLogin Watchdog for BITS Wi-Fi (Windows)
# Continuously monitors the captive portal session and re-authenticates when needed.

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectDir = Split-Path -Parent $ScriptDir
$LogFile = Join-Path $ProjectDir "watchdog.log"
$CheckInterval = 300 # 5 minutes

function Write-Log($Message) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "$timestamp $Message"
}

# Trim log to last 500 lines on start
if (Test-Path $LogFile) {
    $lines = Get-Content $LogFile | Select-Object -Last 500
    $lines | Set-Content $LogFile
}

Write-Log "🔁 Watchdog started (checking every $($CheckInterval / 60)m)"

$loopCount = 0

while ($true) {
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

    # Trim log every ~50 checks
    $loopCount++
    if ($loopCount -ge 50) {
        $lines = Get-Content $LogFile | Select-Object -Last 200
        $lines | Set-Content $LogFile
        $loopCount = 0
    }

    Start-Sleep -Seconds $CheckInterval
}
