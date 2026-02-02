# Full System Restore Script
# This script downloads and restores your entire C:\Users folder from Terabox
# Double-click this to restore all installed programs and settings

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  ASTRAL-VM Full System Restore" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This will restore your entire system from Terabox backup."
Write-Host "This may take 10-30 minutes depending on backup size."
Write-Host ""
$confirm = Read-Host "Continue? (Y/N)"
if ($confirm -ne 'Y') { 
    Write-Host "Cancelled." -ForegroundColor Yellow
    exit 
}

Write-Host "`nChecking for full system backup on Terabox..." -ForegroundColor Yellow

# Check if full backup exists
$backupExists = rclone ls "terabox:full-system-backup.zip" 2>$null
if (-not $backupExists) {
    Write-Host "ERROR: No full system backup found on Terabox!" -ForegroundColor Red
    Write-Host "Please run the VM for at least one cycle to create the backup." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Full backup found! Starting download..." -ForegroundColor Green

# Download the backup
$tempPath = "C:\temp-full-restore"
New-Item -Path $tempPath -ItemType Directory -Force | Out-Null

rclone copy "terabox:full-system-backup.zip" $tempPath --progress

Write-Host "`nExtracting backup (this may take several minutes)..." -ForegroundColor Yellow
Expand-Archive -Path "$tempPath\full-system-backup.zip" -DestinationPath "$tempPath\extracted" -Force

Write-Host "`nRestoring files to C:\Users..." -ForegroundColor Yellow
# Use robocopy for better handling of large file sets
robocopy "$tempPath\extracted" "C:\Users" /E /R:2 /W:5 /MT:8 /NP

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "  Full System Restore Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Your installed programs and all settings have been restored."
Write-Host "Please restart Windows Explorer or log off/on for changes to take effect."
Write-Host ""

# Cleanup
Remove-Item $tempPath -Recurse -Force -ErrorAction SilentlyContinue

Read-Host "Press Enter to close"
