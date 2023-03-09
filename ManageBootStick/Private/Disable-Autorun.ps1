function Disable-Autorun {
    $path ='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\Explorer'
    Set-ItemProperty $path -Name NoDriveTypeAutorun -Type DWord -Value 0xFF | Out-Null
}