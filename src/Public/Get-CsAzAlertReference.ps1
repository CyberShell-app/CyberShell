function Get-CsAzAlertReference {
    param (
        [string] $Url = 'https://raw.githubusercontent.com/MicrosoftDocs/azure-docs/main/articles/defender-for-cloud/alerts-reference.md'
    )

    # Download the content from the URL
    $content = Invoke-WebRequest -Uri $Url -UseBasicParsing

    # Split the content into sections
    $sections = $content.Content -split '## '

    # Create an array to hold the alerts
    $alerts = @()

    # Define a hashtable to map section names to alert keys
    $sectionMap = @{
        'Description' = 'Description'
        '[MITRE tactics](#mitre-attck-tactics)' = 'MITRE Tactics'
        'Severity' = 'Severity'
    }

    # Variable to hold the current resource name
    $currentResourceName = ''

    # Loop through each section
    foreach ($section in $sections) {
        # Skip empty sections
        if ($section.Trim() -eq '') {
            continue
        }

        # Split the section into lines
        $lines = $section -split '\r?\n'

        # Create a hashtable to hold the alert
        $alert = @{}

        # Loop through each line
        foreach ($line in $lines) {
            # Skip empty lines
            if ($line.Trim() -eq '') {
                continue
            }

            # Check if the line is a resource name
            if ($line -match '^Alerts for (.*?)$') {
                $currentResourceName = $matches[1]
            }
            # Check if the line is a title
            elseif ($line -match '^\*\*(.*?)\*\*$') {
                $alert['Title'] = $matches[1]
                $alert['ResourceName'] = $currentResourceName
            }
            # Check if the line is a section
            elseif ($line -match '^\*\*(.*?)\*\*:\s(.*)$') {
                # Get the section name and value
                $sectionName = $matches[1]
                $value = $matches[2]

                # Check if the section name is in the section map
                if ($sectionMap.ContainsKey($sectionName)) {
                    # Get the alert key for this section
                    $alertKey = $sectionMap[$sectionName]

                    # Add the value to the alert
                    $alert[$alertKey] = $value
                }
            }
        }

        # Convert the alert hashtable to a custom object
        $alertObject = New-Object -TypeName PSObject -Property $alert

        # Add the alert object to the alerts array
        $alerts += $alertObject
    }

    # Return the alerts
    return $alerts
}

# Call the function without a URL to use the default URL
$alerts = Get-CsAzAlertReference

# Output the alerts where the description is not empty
$alerts | Where-Object { $_.Description -ne $null } | Export-Csv az-alerts.csv -Delimiter "@" -NoTypeInformation -Encoding UTF8