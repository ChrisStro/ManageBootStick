function New-MBSBootDiskEntry {
    param (
        [Parameter(Mandatory, HelpMessage = "Volume which holds the windows boot manager")]
        [ValidateScript( { if ((Test-Path "$($_ + 'EFI')") -or (Test-Path "$($_ + 'Boot')")) {
                    $true
                } else {
                    throw "BootVolume only allows following volume inputs:
                    Systemvolume: d:, e:
                    UniqueId: \\?\Volume{1ffccdca-ea65-47a9-a677-9d78ac7e9400} (without \ at the end)"
                } })
        ]
        $BootVolume,
        [Parameter(Mandatory, HelpMessage = "Windows directory, which will be added to windows boot manager")]
        [ValidateScript( { if ($_ -notmatch '^[a-z]:\Windows$') { throw "WindowsDrive only allows windows directories, like c:\Windows or e:\windows" } })]
        $WindowsDrive,
        [Parameter(Mandatory)]
        $Description
    )

    $wim = Resolve-Path $WimFile
    $deviceValue = "partition=$($wim.Drive)"

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
    bcdedit -store $BootVolume\EFI\Microsoft\Boot\BCD -set "{$guid}" hypervisorlaunchtype Auto
    bcdedit -store $BootVolume\EFI\Microsoft\Boot\BCD -displayorder "{$guid}" /addlast

    # add entry for bios
    $result = bcdedit -store $BootVolume\Boot\BCD -create -d $Description -application osloader
    $guid = ($result -split '{|}')[1]

    bcdedit -store $BootVolume\Boot\BCD -set "{$guid}" device $deviceValue
    bcdedit -store $BootVolume\Boot\BCD -set "{$guid}" path \windows\system32\boot\winload.exe
    bcdedit -store $BootVolume\Boot\BCD -set "{$guid}" locale en-US
    bcdedit -store $BootVolume\Boot\BCD -set "{$guid}" osdevice $deviceValue
    bcdedit -store $BootVolume\Boot\BCD -set "{$guid}" systemroot \windows
    bcdedit -store $BootVolume\Boot\BCD -set "{$guid}" allowedinmemorysettings 0x15000075
    bcdedit -store $BootVolume\Boot\BCD -set "{$guid}" isolatedcontext Yes
    bcdedit -store $BootVolume\Boot\BCD -set "{$guid}" inherit '{bootloadersettings}'
    bcdedit -store $BootVolume\Boot\BCD -set "{$guid}" nx OptIn
    bcdedit -store $BootVolume\EFI\Microsoft\Boot\BCD -set "{$guid}" hypervisorlaunchtype Auto
    bcdedit -store $BootVolume\Boot\BCD -displayorder "{$guid}" /addlast
}