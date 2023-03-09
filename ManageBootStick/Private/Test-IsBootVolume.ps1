Filter Test-IsBootVolume ([Parameter(ValueFromPipeline)][pscustomobject]$Volume) {
    $efi_folder = $Volume.Path + "EFI"
    $boot_folder = $Volume.Path + "Boot"

    if ((Test-Path $efi_folder) -or (Test-Path $boot_folder)) {
        $Volume
    }
}