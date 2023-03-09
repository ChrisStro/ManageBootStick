function New-MBSBootLoader {
    param (
        [Parameter(Mandatory,HelpMessage="Volume which holds the windows boot manager")]
        [ValidateScript( { if ((Test-Path "$($_ + 'EFI')") -or (Test-Path "$($_ + 'Boot')")) {
                    $true
                } else {
                    throw "BootVolume only allows following volume inputs:
                    Systemvolume: d:, e:
                    UniqueId: \\?\Volume{1ffccdca-ea65-47a9-a677-9d78ac7e9400} (without \ at the end)"
                } })
        ]
        $BootVolume
    )
    bcdboot $env:windir /s $BootVolume /f ALL | Out-Null
    if ($?) {Write-Host -ForegroundColor Cyan "Create UEFI and BIOS boot files on $BootVolume"}
    # copy boot.sdi
    Write-Host -ForegroundColor DarkGray "Copied boot.sdi to $BootVolume\boot"
    Copy-Item $env:windir\system32\boot.sdi $BootVolume\boot -Force
    # clear default uefi store
    bcdedit -store $BootVolume\EFI\Microsoft\Boot\BCD -delete '{default}'
    bcdedit -store $BootVolume\EFI\Microsoft\Boot\BCD -create '{ramdiskoptions}' -d "ramdiskoptions"
    bcdedit -store $BootVolume\EFI\Microsoft\Boot\BCD -set '{ramdiskoptions}' ramdisksdidevice partition=$BootVolume
    bcdedit -store $BootVolume\EFI\Microsoft\Boot\BCD -set '{ramdiskoptions}' ramdisksdipath "\boot\boot.sdi"
    bcdedit -store $BootVolume\EFI\Microsoft\Boot\BCD -deletevalue '{ramdiskoptions}' description # fix descript showint in star menu
    Write-Host -ForegroundColor DarkGray "{ramdiskoptions} for uefi bootloader created"

    #clear default bios store
    bcdedit -store $BootVolume\Boot\BCD -delete '{default}'
    bcdedit -store $BootVolume\Boot\BCD -create '{ramdiskoptions}' -d "ramdiskoptions"
    bcdedit -store $BootVolume\Boot\BCD -set '{ramdiskoptions}' ramdisksdidevice partition=$BootVolume
    bcdedit -store $BootVolume\Boot\BCD -set '{ramdiskoptions}' ramdisksdipath "\boot\boot.sdi"
    bcdedit -store $BootVolume\Boot\BCD -deletevalue '{ramdiskoptions}' description # fix descript showint in star menu
    Write-Host -ForegroundColor DarkGray "{ramdiskoptions} for bios bootloader created"
}