function Get-MBSBootVolume {
    $boot_volumes = Get-Volume | Test-IsBootVolume

    $boot_volumes | ForEach-Object {
        [PSCustomObject]@{
            DriveLetter     = $_.DriveLetter
            FriendlyName    = $_.FileSystemLabel
            SizeMB          = [math]::round($_.Size/1MB, 2)
            SizeRemainingMB = [math]::round($_.SizeRemaining / 1MB, 2)
            FileSystem      = $_.FileSystem
            Path            = $_.Path
        }
    }
}