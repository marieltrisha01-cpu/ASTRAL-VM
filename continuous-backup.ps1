# Continuous Incremental Backup Script
# This runs in the background and syncs only CHANGED files to Terabox
# Much faster than full re-compression each time

param(
    [int]$IntervalMinutes = 30
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  ASTRAL-VM Continuous Backup Active" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Syncing changed files every $IntervalMinutes minutes..." -ForegroundColor Yellow
Write-Host "This runs silently in the background." -ForegroundColor Yellow
Write-Host ""

$syncTargets = @{
    "Desktop"   = "$env:USERPROFILE\Desktop"
    "Documents" = "$env:USERPROFILE\Documents"
    "AppData"   = "$env:APPDATA"
}

$iteration = 0
while ($true) {
    $iteration++
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Backup cycle #$iteration starting..." -ForegroundColor Green
    
    foreach ($target in $syncTargets.Keys) {
        $sourcePath = $syncTargets[$target]
        $remotePath = "terabox:vm-sync/$target"
        
        try {
            # rclone sync only uploads NEW or CHANGED files (incremental)
            Write-Host "  Syncing $target..." -ForegroundColor Gray
            rclone sync $sourcePath $remotePath --exclude "*.tmp" --exclude "Temp/**" --fast-list --quiet
            Write-Host "  ✅ $target synced" -ForegroundColor Green
        } catch {
            Write-Warning "  ⚠️ $target sync failed: $_"
        }
    }
    
    # Registry snapshot (small, always updated)
    try {
        reg export "HKCU\Software" "C:\temp-reg-backup.reg" /y 2>$null
        rclone copy "C:\temp-reg-backup.reg" "terabox:vm-sync/" --quiet
        Remove-Item "C:\temp-reg-backup.reg" -Force -ErrorAction SilentlyContinue
    } catch { }
    
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ✅ Backup cycle complete. Next sync in $IntervalMinutes min." -ForegroundColor Cyan
    Write-Host ""
    
    Start-Sleep -Seconds ($IntervalMinutes * 60)
}
