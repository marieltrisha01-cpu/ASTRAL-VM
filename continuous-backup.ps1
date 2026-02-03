param($IntervalMinutes = 30)

$syncTargets = @{
    "Desktop"   = "$env:USERPROFILE\Desktop"
    "Documents" = "$env:USERPROFILE\Documents"
    "Downloads" = "$env:USERPROFILE\Downloads"
    "AppData"   = "$env:APPDATA"
    "Pictures"  = "$env:USERPROFILE\Pictures"
    "Videos"    = "$env:USERPROFILE\Videos"
    "ChromeData" = "$env:LOCALAPPDATA\Google\Chrome\User Data"
    "DockerConfig" = "$env:USERPROFILE\.docker"
}

while ($true) {
    foreach ($name in $syncTargets.Keys) {
        $sourcePath = $syncTargets[$name]
        $remotePath = "gdrive:astral-vm-backup/vm-sync/$name"
        
        # Chrome special handling (skip locks/cache)
        if ($name -eq "ChromeData") {
            & rclone sync $sourcePath $remotePath --exclude "Default/Cache/**" --exclude "Default/Code Cache/**" --fast-list --quiet --ignore-errors
        } else {
            & rclone sync $sourcePath $remotePath --exclude "*.tmp" --exclude "Temp/**" --fast-list --quiet --ignore-errors
        }
    }
    
    # Registry Export
    $regPath = "C:\temp-reg-backup.reg"
    & reg export "HKCU\Software" $regPath /y 2>$null
    if (Test-Path $regPath) {
        & rclone copy $regPath "gdrive:astral-vm-backup/vm-sync/" --quiet
    }
    
    Start-Sleep -Seconds ($IntervalMinutes * 60)
}
