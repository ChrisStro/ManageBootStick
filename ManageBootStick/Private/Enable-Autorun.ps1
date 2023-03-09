function Enable-Autorun {
    $path ='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\Explorer'
    Remove-ItemProperty $path -Name NoDriveTypeAutorun | Out-Null
}