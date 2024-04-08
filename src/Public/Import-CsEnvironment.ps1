function Import-CsEnvironment {
    <#
.SYNOPSIS
   Imports CyberShell environments and configuration from a JSONC file.

.DESCRIPTION
   The Import-CsEnvironment function imports CyberShell environments and configuration from a specified JSONC file.
   If no file is specified, it defaults to the CyberShell-Config.jsonc file in the .cybershell directory of the user's home directory.

.PARAMETER JsonPath
   The path to the JSONC file to import. If not specified, defaults to $HOME/.cybershell/CyberShell-Config.jsonc.

.EXAMPLE
   Import-CsEnvironment -JsonPath "C:\path\to\your\file.jsonc"

.INPUTS
   String. Path to the JSONC file.

.OUTPUTS
   Hashtable. The imported CyberShell data.

.NOTES
   The imported data is stored in a global variable $global:CsData.
#>
    [CmdletBinding()]
    param (
        [string]$JsonPath = $null
    )

    Write-OutputPadded "Importing CyberShell Environment" -isTitle -Type "Information"

    # If no JSON path is specified, default to the CyberShell-Config.jsonc file
    # in the .cybershell directory of the user's home directory
    if ([string]::IsNullOrEmpty($JsonPath)) {
        $JsonFolder = Join-Path $HOME ".cybershell"
        $JsonPath = Join-Path $JsonFolder "CyberShell-Config.jsonc"
        Write-Debug "JsonPath: $JsonPath"
    }

    Write-OutputPadded "Importing configuration from: $JsonPath"  -IndentLevel 1 -Type "Debug"

    # Verifying the file exists
    if (-Not (Test-Path $JsonPath)) {
        Write-Error "The specified JSONC file does not exist at the path: $JsonPath"
        return
    }

    # Loading and parsing the JSON content
    $jsonContent = Get-Content -Path $JsonPath -Raw -ErrorAction Stop
    try {
        # Convert JSON content to a hashtable for structured access
        [hashtable]$rawData = $jsonContent | ConvertFrom-Json -AsHashtable
        Write-OutputPadded "CyberShell environments and configuration successfully imported." -IndentLevel 1 -Type "Success"
        Write-OutputPadded " "
    }
    catch {
        Write-OutputPadded "Failed to import CyberShell environments and configuration from JSON: $_" -IndentLevel 1 -Type "Error"
        Write-OutputPadded " "
    }

    # Structured global data storage
    $global:CsData = @{
        "Environments"  = $rawData["CyberShellEnvironments"];
        "Settings" = $rawData["Settings"];
    }

    # CSData.settings.ExecutionPreference exist then set the script execution preference
    if ($global:CsData.Settings.ExecutionPreference) {
        Set-ScriptExecutionPreference -ExecutionPreference $global:CsData.Settings.ExecutionPreference
        Write-OutputPadded "Script execution preference set to $($global:CsData.Settings.ExecutionPreference)" -IndentLevel 1 -Type "Debug"
        write-OutputPadded " " -Type "Debug"
    }


    If ($global:CsData.Settings.ExecutionPreference -eq "Debug") {
        Write-OutputPadded "Debug Informations:" -IndentLevel 1 -Type "Debug"
    }
    else {
        Write-OutputPadded "Debug and verbose Informations:" -IndentLevel 1 -Type "Debug"
    }

    Write-OutputPadded "JsonFolder: $JsonFolder" -IndentLevel 2 -Type "Debug"
    Write-OutputPadded "JsonPath: $JsonPath" -IndentLevel 2 -Type "Debug"
    Write-OutputPadded "Imported CyberShell Data: $(ConvertTo-Json $global:CsData -Depth 20)" -IndentLevel 2 -Type "Data"

}


