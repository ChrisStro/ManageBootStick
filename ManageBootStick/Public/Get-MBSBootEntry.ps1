function Get-MBSBootEntry {
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
    "="*29 + " UEFI Entries " + "="*29
    bcdedit -store $BootVolume\EFI\Microsoft\Boot\BCD -enum osloader

    "="*29 + " BIOS Entries " + "="*29
    bcdedit -store $BootVolume\Boot\BCD -enum osloader
}