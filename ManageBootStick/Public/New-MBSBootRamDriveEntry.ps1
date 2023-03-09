function New-MBSBootRamDriveEntry {
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
        [Parameter(Mandatory,HelpMessage="Wimfile, which will be added to windows boot manager as ramdrive")]
        [ValidateScript({Test-Path $_})]
        $WimFile,
        [Parameter(Mandatory)]
        $Description
    )

    $wim = Resolve-Path $WimFile
    $deviceValue = "ramdisk=[$($wim.Drive):]$($wim.Path.Split(':')[1])"

    # add entry for uefi
    $result = bcdedit -store $BootVolume\EFI\Microsoft\Boot\BCD -create -d $Description -application osloader
    $guid = ($result -split '{|}')[1]

    bcdedit -store $BootVolume\EFI\Microsoft\Boot\BCD -set "{$guid}" device $deviceValue,'{ramdiskoptions}'
    bcdedit -store $BootVolume\EFI\Microsoft\Boot\BCD -set "{$guid}" path \windows\system32\boot\winload.efi
    bcdedit -store $BootVolume\EFI\Microsoft\Boot\BCD -set "{$guid}" locale en-US
    bcdedit -store $BootVolume\EFI\Microsoft\Boot\BCD -set "{$guid}" osdevice $deviceValue,'{ramdiskoptions}'
    bcdedit -store $BootVolume\EFI\Microsoft\Boot\BCD -set "{$guid}" systemroot \windows
    #bcdedit -store $BootVolume\EFI\Microsoft\Boot\BCD -set "{$guid}" bootmenupolicy Standard
    bcdedit -store $BootVolume\EFI\Microsoft\Boot\BCD -set "{$guid}" detecthal Yes
    bcdedit -store $BootVolume\EFI\Microsoft\Boot\BCD -set "{$guid}" winpe Yes
    bcdedit -store $BootVolume\EFI\Microsoft\Boot\BCD -set "{$guid}" ems No
    bcdedit -store $BootVolume\EFI\Microsoft\Boot\BCD -displayorder "{$guid}" /addfirst

    # add entry for bios
    $result = bcdedit -store $BootVolume\Boot\BCD -create -d $Description -application osloader
    $guid = ($result -split '{|}')[1]

    bcdedit -store $BootVolume\Boot\BCD -set "{$guid}" device $deviceValue,'{ramdiskoptions}'
    bcdedit -store $BootVolume\Boot\BCD -set "{$guid}" path \windows\system32\boot\winload.exe
    bcdedit -store $BootVolume\Boot\BCD -set "{$guid}" locale en-US
    bcdedit -store $BootVolume\Boot\BCD -set "{$guid}" inherit '{bootloadersettings}'
    bcdedit -store $BootVolume\Boot\BCD -set "{$guid}" osdevice $deviceValue,'{ramdiskoptions}'
    bcdedit -store $BootVolume\Boot\BCD -set "{$guid}" systemroot \windows
    bcdedit -store $BootVolume\Boot\BCD -set "{$guid}" detecthal Yes
    bcdedit -store $BootVolume\Boot\BCD -set "{$guid}" winpe Yes
    bcdedit -store $BootVolume\Boot\BCD -set "{$guid}" ems No
}