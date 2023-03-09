function Remove-MBSBootEntry {
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
        [Parameter(Mandatory)]
        [string]$UefiGuid,
        [string]$BiosGuid
    )
    try {
        if ($UefiGuid) {
            Write-Host -ForegroundColor Cyan "Remove boot manager entry with guid : [ $UefiGuid ]"
            # remove entry for uefi
            Write-Host -ForegroundColor DarkGray "delete entry on uefi boot manager " -nonewline
            $output = bcdedit -store $BootVolume\EFI\Microsoft\Boot\BCD -delete $UefiGuid
            if ($?) { write-host -ForegroundColor Green "[OK]" } else { write-host -ForegroundColor Red "[FAIL]";  write-host -ForegroundColor Red  "Error: $output" }
        }

        # remove entry for bios
        if ($BiosGuid) {
            Write-Host -ForegroundColor Cyan "Remove boot manager entry with guid : [ $UefiGuid ]"
            Write-Host -ForegroundColor DarkGray "delete entry on bios boot manager " -nonewline
            $output = bcdedit -store $BootVolume\Boot\BCD -delete $BiosGuid
            if ($?) { write-host -ForegroundColor Green "[OK]" } else { write-host -ForegroundColor Red "[FAIL]"; write-host -ForegroundColor Red "Error: $output" }
        }
    }
    catch {
        $_
    }
}