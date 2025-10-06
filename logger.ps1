param(
    [switch]$Upload,
    [string]$Url,
    [string]$File
)

function Upload-LogFile {
    param(
        [string]$LogFile,
        [string]$Endpoint,
        [int]$Retries = 3,
        [int]$DelaySec = 1
    )
    if (-not (Test-Path $LogFile)) {
        Write-Host "[ERROR] Log file '$LogFile' does not exist."
        return
    }

    for ($i = 1; $i -le $Retries; $i++) {
        try {
            Invoke-RestMethod -Uri $Endpoint -Method Post -InFile $LogFile -ContentType "text/plain" -ErrorAction Stop
            Write-Host "[UPLOAD] Success posting log to $Endpoint (attempt $i)"
            return
        } catch {
            Write-Host "[UPLOAD] Attempt $i failed: $($_.Exception.Message)"
            Start-Sleep -Seconds $DelaySec
        }
    }
    Write-Host "[UPLOAD] All attempts failed."
}

if ($Upload) {
    if (-not $Url) { Write-Error "Upload mode requires -Url argument"; exit 1 }
    if (-not $File) { Write-Error "Upload mode requires -File argument"; exit 1 }
    Upload-LogFile -LogFile $File -Endpoint $Url
    exit
}

if ($File) {
    $log = $File
    $dir = Split-Path $log
    if (-not (Test-Path $dir)) { New-Item -Path $dir -ItemType Directory -Force | Out-Null }
} else {
    $ts = Get-Date -Format "yyyyMMdd-HHmmss"
    $logDir = "C:\Logs"
    if (-not (Test-Path $logDir)) { New-Item -Path $logDir -ItemType Directory -Force | Out-Null }
    $log = Join-Path $logDir ("Logger-$ts.txt")
}

$sessionMeta = @{
    session_id = (Get-Date -Format "yyyyMMdd-HHmmss")
    started_at = (Get-Date).ToString("o")
    user       = $env:USERNAME
    hostname   = $env:COMPUTERNAME
    platform   = (Get-Culture).Name
}
Add-Content -Path $log -Value ("`n===== Logger session started =====")
Add-Content -Path $log -Value ("Session: " + ($sessionMeta | ConvertTo-Json -Compress))
Add-Content -Path $log -Value ("====================================`n")

while ($true) {
    try {
        $cmd = Read-Host "PS>"
    } catch {
        Write-Host "`nInput closed. Exiting."
        Add-Content -Path $log -Value ("[`(Get-Date)`] Input closed. Exiting session.")
        break
    }

    if ($null -eq $cmd) { continue }
    if ($cmd.Trim().ToLower() -in @("exit","quit")) {
        Add-Content -Path $log -Value ("`n[" + (Get-Date) + "] Session exit requested (`"$cmd`").")
        break
    }

    Add-Content -Path $log -Value ("`n[{0}] Command: {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $cmd)

    try {
        $output = Invoke-Expression $cmd 2>&1 | Out-String
        if ($output) { Write-Host $output; Add-Content -Path $log -Value ("Output:`n" + $output) }
        else { Add-Content -Path $log -Value "Output: <no output>" }
    } catch {
        $errMsg = $_ | Out-String
        Write-Host "Error: $errMsg" -ForegroundColor Red
        Add-Content -Path $log -Value ("Error (exception):`n" + $errMsg)
    }
}

Add-Content -Path $log -Value ("`n===== Logger session ended at " + (Get-Date).ToString("o") + " =====`n")
Write-Host "Session ended. Log file: $log"
