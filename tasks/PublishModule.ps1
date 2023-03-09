[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]$RepositoryName,

    [Parameter(Mandatory)]
    [string]$ApiKey,

    [Parameter(Mandatory)]
    [System.IO.FileInfo]$Module,

    [Parameter(Mandatory)]
    [string]$Author,

    [Parameter(Mandatory)]
    [string]$Description,

    [Parameter(Mandatory)]
    [string[]]$Tags,

    [switch]$Force
)
@'
 ______   __  __     ______     __         __     ______     __  __        __    __     ______     _____     __  __     __         ______
/\  == \ /\ \/\ \   /\  == \   /\ \       /\ \   /\  ___\   /\ \_\ \      /\ "-./  \   /\  __ \   /\  __-.  /\ \/\ \   /\ \       /\  ___\
\ \  _-/ \ \ \_\ \  \ \  __<   \ \ \____  \ \ \  \ \___  \  \ \  __ \     \ \ \-./\ \  \ \ \/\ \  \ \ \/\ \ \ \ \_\ \  \ \ \____  \ \  __\
 \ \_\    \ \_____\  \ \_____\  \ \_____\  \ \_\  \/\_____\  \ \_\ \_\     \ \_\ \ \_\  \ \_____\  \ \____-  \ \_____\  \ \_____\  \ \_____\
  \/_/     \/_____/   \/_____/   \/_____/   \/_/   \/_____/   \/_/\/_/      \/_/  \/_/   \/_____/   \/____/   \/_____/   \/_____/   \/_____/

'@
Function Write-Log {
    param(
        [string]$TextBlock,
        [parameter(mandatory = $false, HelpMessage = "Enter text for output")]
        [ValidateSet("Start", "Notifiy", "Finish")]
        $State
    )
    switch ($State) {
        "Start" { $Color = "cyan" }
        "Notifiy" { $Color = "yellow" }
        "Finish" { $Color = "green" }
        Default { $Color = "" }
    }
    $Logdate = Get-Date -Format g
    if (!$Section) { $Section = $PSCommandPath | Split-Path -Leaf -ErrorAction SilentlyContinue }
    #set parameter Hashtable
    $Parameter = @{
        object = "[$Logdate] [$Section - $TextBlock]"
    }
    if ($State) { $Parameter.ForegroundColor = $Color }

    Write-Host  @Parameter
}

# Main
Write-Log -State Start "Publishing $Module"
Write-Log "Running task in Environemt:"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$PSVersionTable

try {
    $ErrorActionPreference = "stop"
    if (!(Test-Path -Path $Module.FullName)) { Write-Log -State Notifiy "Sry, no Module Present"; break }
    [version]$curVersion = try {
        (Find-Module -Repository $RepositoryName -Name $Module.BaseName -ErrorAction stop).version
    }
    catch {
        "0.0.0"
    }
    [version]$newVersion = "{0}.{1}.{2}" -f $curVersion.Major, $curVersion.Minor, ($curVersion.Build + 1)
    # Function to export
    [array]$Function = (Get-ChildItem $(Join-Path $Module.Directory "$($Module.BaseName)\Public")).BaseName
    Write-Log "Exported Functions $Function"
    # Add one to the build of the version number
    $ModuleInfo = @{
        Path              = Join-Path $($Module.Directory) $($Module.BaseName + "\$($Module.BaseName).psd1")
        Author            = $Author
        Description       = $Description
        ModuleVersion     = $newVersion
        Tags              = $Tags
        FunctionsToExport = $Function
    }
    Update-ModuleManifest @ModuleInfo
    if ($Force.IsPresent) {
        Write-Log "Publishing Script"
        Publish-Module -Repository $RepositoryName -NuGetApiKey $ApiKey -Path $Module -Verbose
    }
    else {
        $result = Read-Host -Prompt "Last Chance : Want to Upload Script : $($Module.BaseName) Version : $($newVersion -as [string]) ? Y/N"
        if ($result -eq "y") {
            Write-Log "Publishing Script"
            Publish-Module -Repository $RepositoryName -NuGetApiKey $ApiKey -Path $Module -Verbose
        }
    }
}
catch {
    write-host -ForegroundColor Red "Error : $($_.Exception.Message)"
}