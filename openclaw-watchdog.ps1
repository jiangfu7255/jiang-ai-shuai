# OpenClaw Gateway Keepalive Watchdog
# Run this script at login to auto-restart the gateway if it dies
$ErrorActionPreference = "SilentlyContinue"

$GatewayScript = "$env:USERPROFILE\.openclaw\gateway.cmd"
$CheckIntervalSeconds = 30
$LogFile = "$env:TEMP\openclaw-watchdog.log"

function Write-Log($message) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp $message" | Out-File -FilePath $LogFile -Append -Encoding UTF8
}

Write-Log "Watchdog started. Monitoring gateway every $CheckIntervalSeconds seconds."

while ($true) {
    Start-Sleep -Seconds $CheckIntervalSeconds

    # Check if gateway is listening
    $probe = Test-NetConnection -ComputerName 127.0.0.1 -Port 18789 -WarningAction SilentlyContinue -InformationLevel Quiet

    if (-not $probe) {
        Write-Log "Gateway not responding on port 18789. Attempting restart..."

        # Kill any stale processes on the port
        $stale = Get-NetTCPConnection -LocalAddress 127.0.0.1 -LocalPort 18789 -ErrorAction SilentlyContinue
        if ($stale) {
            $staleOwningProcess = $stale.OwningProcess | Select-Object -Unique
            foreach ($pid in $staleOwningProcess) {
                Write-Log "Killing stale process PID $pid"
                Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue
            }
            Start-Sleep -Seconds 2
        }

        # Start gateway via scheduled task (more reliable than direct spawn)
        Write-Log "Starting gateway via scheduled task..."
        $result = schtasks /Run /TN "OpenClaw Gateway" 2>&1
        Write-Log "schtasks result: $result"

        Start-Sleep -Seconds 5

        # Verify it came up
        $probe2 = Test-NetConnection -ComputerName 127.0.0.1 -Port 18789 -WarningAction SilentlyContinue -InformationLevel Quiet
        if ($probe2) {
            Write-Log "Gateway restarted successfully."
        } else {
            Write-Log "Gateway restart failed, will retry next cycle."
        }
    }
}
