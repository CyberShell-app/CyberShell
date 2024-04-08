function Set-ScriptExecutionPreference {
    [CmdletBinding()]
    param (
        [ValidateSet("Information", "Verbose", "Debug")]
        [string]$ExecutionPreference = "Information"
    )

    if ($ExecutionPreference -eq "Verbose" -or $PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true) {
        $script:VerbosePreference = "Continue"
        $script:DebugPreference = "SilentlyContinue"
    }
    elseif ($ExecutionPreference -eq "Debug" -or $PSCmdlet.MyInvocation.BoundParameters["Debug"].IsPresent -eq $true) {
        $script:VerbosePreference = "Continue"
        $script:DebugPreference = "Continue"
    }
    else {
        $script:VerbosePreference = "SilentlyContinue"
        $script:DebugPreference = "SilentlyContinue"
    }

    # Information
    # Standard
    # Information
    # success
    # warning
    # error
    # Critical
    # verbose
    # Verbose
    # debug
    # Debug
    # Data
}
