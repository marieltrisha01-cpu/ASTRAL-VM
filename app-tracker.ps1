# app-tracker.ps1: Dynamically track Chocolatey installs
param($IntervalMinutes = 15)

$ManifestPath = "C:\installed-apps.json"
$CloudPath = "gdrive:astral-vm-backup/vm-sync/installed-apps.json"

# Initial list of base apps we want to ignore (to keep the manifest clean)
$BaseApps = @("chocolatey", "rclone", "tailscale", "googlechrome", "docker-desktop")

while ($true) {
    # Get current choco packages
    $CurrentPackages = & choco list --local-only --limit-output | ForEach-Object { $_.Split('|')[0] }
    
    # Filter out base and known internal components
    $UserApps = $CurrentPackages | Where-Object { $BaseApps -notcontains $_ }
    
    if ($UserApps) {
        $UserApps | ConvertTo-Json | Set-Content -Path $ManifestPath
        & rclone copy $ManifestPath "gdrive:astral-vm-backup/vm-sync/" --quiet
    }
    
    Start-Sleep -Seconds ($IntervalMinutes * 60)
}
