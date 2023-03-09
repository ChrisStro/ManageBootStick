function New-MBSBootVhdBootEntry {
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
        $BootVolume,
        [Parameter(Mandatory,HelpMessage="Vhdx file, which will be added to windows boot manager as vhd boot")]
        $VHDFile,
        [Parameter(Mandatory)]
        $Description
    )

    $vhd = Resolve-Path $VHDFile
    $deviceValue = "vhd=[$($vhd.Drive):]$($vhd.Path.Split(':')[1])"

    # add entry for uefi
    $result = bcdedit -store $BootVolume\EFI\Microsoft\Boot\BCD -create -d $Description -application osloader
    $guid = ($result -split '{|}')[1]

    bcdedit -store $BootVolume\EFI\Microsoft\Boot\BCD -set "{$guid}" device $deviceValue
    bcdedit -store $BootVolume\EFI\Microsoft\Boot\BCD -set "{$guid}" path \windows\system32\boot\winload.efi
    bcdedit -store $BootVolume\EFI\Microsoft\Boot\BCD -set "{$guid}" locale en-US
    bcdedit -store $BootVolume\EFI\Microsoft\Boot\BCD -set "{$guid}" osdevice $deviceValue
    bcdedit -store $BootVolume\EFI\Microsoft\Boot\BCD -set "{$guid}" systemroot \windows
    bcdedit -store $BootVolume\EFI\Microsoft\Boot\BCD -set "{$guid}" allowedinmemorysettings 0x15000075
    bcdedit -store $BootVolume\EFI\Microsoft\Boot\BCD -set "{$guid}" isolatedcontext Yes
    bcdedit -store $BootVolume\EFI\Microsoft\Boot\BCD -set "{$guid}" inherit '{bootloadersettings}'
    bcdedit -store $BootVolume\EFI\Microsoft\Boot\BCD -set "{$guid}" nx OptIn
    bcdedit -store $BootVolume\EFI\Microsoft\Boot\BCD -displayorder "{$guid}" /addlast

    # add entry for bios
    $result = bcdedit -store $BootVolume\Boot\BCD -create -d $Description -application osloader
    $guid = ($result -split '{|}')[1]

    bcdedit -store $BootVolume\Boot\BCD -set "{$guid}" device $deviceValue
    bcdedit -store $BootVolume\Boot\BCD -set "{$guid}" path \windows\system32\boot\winload.exe
    bcdedit -store $BootVolume\Boot\BCD -set "{$guid}" locale en-US
    bcdedit -store $BootVolume\Boot\BCD -set "{$guid}" inherit '{bootloadersettings}'
    bcdedit -store $BootVolume\Boot\BCD -set "{$guid}" osdevice $deviceValue
    bcdedit -store $BootVolume\Boot\BCD -set "{$guid}" systemroot \windows
    bcdedit -store $BootVolume\Boot\BCD -set "{$guid}" allowedinmemorysettings 0x15000075
    bcdedit -store $BootVolume\Boot\BCD -set "{$guid}" isolatedcontext Yes
    bcdedit -store $BootVolume\Boot\BCD -set "{$guid}" inherit '{bootloadersettings}'
    bcdedit -store $BootVolume\Boot\BCD -set "{$guid}" nx OptIn
    bcdedit -store $BootVolume\Boot\BCD -displayorder "{$guid}" /addlast
}