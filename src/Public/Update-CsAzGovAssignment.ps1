function Update-CsAzGovAssignment {
    [CmdletBinding()]
    param (

        [Parameter(Position = 0, Mandatory = $true)]
        [System.Collections.Hashtable]$azAPICallConf,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$CsEnvironment,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$resourceId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$AssessmentName,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$assignmentKey,

        [Parameter(Mandatory = $false)]
        [datetime]$RemediationDueDate,

        [Parameter(Mandatory = $false)]
        [object]$IsGracePeriod,

        [Parameter(Mandatory = $false)]
        [string]$OwnerEmailAddress,

        [Parameter(Mandatory = $false)]
        [bool]$OwnerEmailNotification,

        [Parameter(Mandatory = $false)]
        [bool]$ManagerEmailNotification,

        [Parameter(Mandatory = $false)]
        [Validateset('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')]
        [string]$NotificationDayOfWeek

    )



    begin {
        # if the input is not from pipeline, then create a custom object with a single entry
        Write-OutputPadded "Update Azure Governance Assignment" -Type 'information' -isTitle -BlankLineBefore
    }

    process {

        Write-OutputPadded "Processing Azure Governance Assignment" -Type 'information' -IdentLevel 1 -BlankLineBefore
        Write-OutputPadded "Resource Id: $resourceId" -Type 'information' -IdentLevel 1
        Write-OutputPadded "Assessment Name: $AssessmentName" -Type 'Verbose' -IdentLevel 1
        Write-OutputPadded "Assignment Key: $assignmentKey" -Type 'Verbose' -IdentLevel 1

        $uri = "$($azAPICallConf.azAPIEndpointUrls.ARM)$resourceId/providers/microsoft.security/assessments/$AssessmentName/governanceAssignments/$assignmentKey/?api-version=2021-06-01"

        # get the existing assignment
        $govassessment = AzAPICall -AzAPICallConfiguration $azAPICallConf -uri $uri -method 'GET' -listenOn Content


        if ($RemediationDueDate) {
            # Update the remediationDueDate
            $RemediationDueDate = $RemediationDueDate.ToString('yyyy-MM-dd')
            Write-OutputPadded "New remediation Due Date: $RemediationDueDate" -Type 'Verbose' -IdentLevel 1
            $govassessment.properties.remediationDueDate = $RemediationDueDate
        }

        if ($IsGracePeriod) {
            # Update the isGracePeriod
            Write-OutputPadded "New isGracePeriod: $IsGracePeriod" -Type 'Verbose' -IdentLevel 1
            $govassessment.properties.isGracePeriod = $IsGracePeriod
        }

        if ($OwnerEmailAddress) {
            # Update the owner
            Write-OutputPadded "New Owner Email Address: $OwnerEmailAddress" -Type 'Verbose' -IdentLevel 1
            $govassessment.properties.owner = $OwnerEmailAddress
        }

        if ($OwnerEmailNotification) {
            # Update the disableOwnerEmailNotification
            Write-OutputPadded "New Owner Email Notification: $OwnerEmailNotification" -Type 'Verbose' -IdentLevel 1
            $govassessment.properties.governanceEmailNotification.disableOwnerEmailNotification = $OwnerEmailNotification
        }

        if ($ManagerEmailNotification) {
            # Update the disableManagerEmailNotification
            Write-OutputPadded "New Manager Email Notification: $ManagerEmailNotification" -Type 'Verbose' -IdentLevel 1
            $govassessment.properties.governanceEmailNotification.disableManagerEmailNotification = $ManagerEmailNotification
        }

        if ($NotificationDayOfWeek) {
            # Update the emailNotificationDayOfWeek
            Write-OutputPadded "New Email Notification Day Of Week: $NotificationDayOfWeek" -Type 'Verbose' -IdentLevel 1
            $govassessment.properties.governanceEmailNotification.emailNotificationDayOfWeek = $NotificationDayOfWeek
        }

        # Convert the updated object to JSON
        $jsonBody = $govassessment | ConvertTo-Json -Depth 10
        Write-OutputPadded "Updated JSON Body:" -Type 'data' -IdentLevel 1
        Write-OutputPadded "$jsonBody" -Type 'data' -IdentLevel 1

        # Update the assignment
        Write-OutputPadded "Updating Azure Governance Assignment" -Type 'debug' -IdentLevel 1


        # if no error, then displqy success message
        try {
            AzAPICall -AzAPICallConfiguration $azAPICallConf -uri $uri -method 'PUT' -body $jsonBody -listenOn Content
        }
        catch {
            Write-OutputPadded "Failed to update Azure Governance Assignment: $_" -Type 'error' -IdentLevel 1
        }
        finally {
             Write-OutputPadded "Azure Governance Assignment Updated Successfully" -Type 'success' -IdentLevel 1
        }
    }
}