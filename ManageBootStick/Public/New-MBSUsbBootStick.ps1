function New-MBSUsbBootStick {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,HelpMessage="Create bootable usb stick for BIOS or UEFI")]
        [ValidateSet("UEFI","BIOS")]
        [string]$Type,
        [Parameter(HelpMessage="Disknumber, which will be wiped and recreated as bootable media, identified via Get-Disk")]
        [int]$DiskNr
    )
    try {
        $ErrorActionPreference = 'stop'
        Write-Host -ForegroundColor DarkGray "Disable autorun while creating bootable usbstick" -NoNewline
        Disable-Autorun
        Write-Host -ForegroundColor Green "[OK]"

        Write-Host -ForegroundColor Cyan "Create Usb boot drive for $Type "
        if ($DiskNr) {
            Write-Host -ForegroundColor Magenta "You selected $DiskNr via parameter " -NoNewline
            $disk = get-disk -Number $DiskNr
        }
        else {
            Write-Host -ForegroundColor Magenta "Select USB Drive to wipe " -NoNewline
            $disk = get-disk | Out-GridView -PassThru
        }
        Write-Host -ForegroundColor Green "[OK]"
        Clear-Disk -InputObject $disk -RemoveData

        if ($Type -eq "BIOS") {
            Set-Disk -PartitionStyle MBR -InputObject $disk
            $systemVol = $disk | New-Partition -Size 200MB -IsActive -AssignDriveLetter | Format-Volume -FileSystem FAT32 -NewFileSystemLabel "System"
            Write-Host -ForegroundColor DarkGray "[$($disk.FriendlyName)] Create System partition on USB disk drive " -NoNewline
            Write-Host -ForegroundColor Green "[OK]"
        }
        if ($Type -eq "UEFI") {
            Set-Disk -PartitionStyle GPT -InputObject $disk
            $systemVol = $disk | New-Partition -Size 200MB -AssignDriveLetter | Format-Volume -FileSystem FAT32 -NewFileSystemLabel "System"
            Write-Host -ForegroundColor DarkGray "[$($disk.FriendlyName)] Create System partition on USB disk drive " -NoNewline
            Write-Host -ForegroundColor Green "[OK]"
        }

        New-BootLoader -BootVolume "$($systemVol.DriveLetter):" 6>&1 | Out-Null
        Write-Host -ForegroundColor DarkGray "[$($disk.FriendlyName)] Create bootloader for $Type on USB disk drive " -NoNewline
        Write-Host -ForegroundColor Green "[OK]"

        $disk | New-Partition -UseMaximumSize -AssignDriveLetter | Format-Volume -FileSystem NTFS -NewFileSystemLabel "Stuff" | Out-Null
        Write-Host -ForegroundColor DarkGray "[$($disk.FriendlyName)] Create Data partition on USB disk drive " -NoNewline
        Write-Host -ForegroundColor Green "[OK]"
    }
    catch {
        $_
    }
    finally {
        Write-Host -ForegroundColor DarkGray "Enable autorun again" -NoNewline
        Enable-Autorun
        Write-Host -ForegroundColor Green "[OK]"
    }
}