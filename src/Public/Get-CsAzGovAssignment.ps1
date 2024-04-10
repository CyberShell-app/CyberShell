function Get-CsAzGovAssignment {
    <#
.SYNOPSIS
    Retrieves Azure Governance Assignments.

.DESCRIPTION
    This function retrieves the list of security assessments from Azure and stores the governance assignments.

.PARAMETER azAPICallConf
    A hashtable containing the configuration for the Azure API call.

.PARAMETER CsEnvironment
    The environment for which the function is being run.

.PARAMETER OverdueOnly
    A switch parameter that retrieves only the overdue governance assignments.

.EXAMPLE
    Get-CsAzGovAssignment -SubId "your-subscription-id" -azAPICallConf $yourConfig -CsEnvironment "your-environment"

.INPUTS
    String, Hashtable, String

.OUTPUTS
    ArrayList
    Returns an ArrayList of governance assignments.

.NOTES
    This function makes use of the AzAPICall function to make the API call to Azure.
#>

    param (

        [Parameter(Position = 0, Mandatory = $true)]
        [System.Collections.Hashtable]$azAPICallConf,

        [Parameter(Position = 1, Mandatory = $true)]
        [string]$CsEnvironment,

        [Parameter()]
        [switch]$OverdueOnly
    )

    Write-OutputPadded "Governance Assignments" -IndentLevel 1 -isTitle -Type "Information"

    if ($OverdueOnly) {
        Write-OutputPadded "OverdueOnly Parameter set" -IndentLevel 1 -Type "Verbose"
        $completionStatus = "'Overdue'"
    }
    else {
        $completionStatus = "'OnTime', 'Overdue', 'Unassigned', 'Completed'"
    }

    # Get the Governance Assignments list
    $query = @"
     securityresources
        | where type =~ 'microsoft.security/assessments'
        | extend assessmentType = tostring(properties.metadata.assessmentType),
                assessmentId = tolower(id),
                statusCode = tostring(properties.status.code),
                source = trim(' ', tolower(tostring(properties.resourceDetails.Source))),
                resourceId = trim(' ', tolower(tostring(properties.resourceDetails.Id))),
                resourceName = tostring(properties.resourceDetails.ResourceName),
                resourceType = tolower(properties.resourceDetails.ResourceType),
                displayName = tostring(properties.displayName),
                assessmentKey = tostring(split(id, '/')[-1])
        | where assessmentType == 'BuiltIn'
        | extend environment = case(
            source in~ ('azure', 'onpremise'), 'Azure',
            source =~ 'aws', 'AWS',
            source =~ 'gcp', 'GCP',
            source =~ 'github', 'GitHub',
            source =~ 'gitlab', 'GitLab',
            source =~ 'azuredevops', 'AzureDevOps',
            dynamic(null)
        )
        | where environment in~ ('AWS', 'Azure', 'AzureDevOps', 'GCP', 'GitHub', 'GitLab')
        | join kind=leftouter (
            securityresources
            | where type == 'microsoft.security/assessments/governanceassignments'
            | extend dueDate = todatetime(properties.remediationDueDate),
                    owner = tostring(properties.owner),
                    disableOwnerEmailNotification = tostring(properties.governanceEmailNotification.disableOwnerEmailNotification),
                    disableManagerEmailNotification = tostring(properties.governanceEmailNotification.disableManagerEmailNotification),
                    emailNotificationDayOfWeek = tostring(properties.governanceEmailNotification.emailNotificationDayOfWeek),
                    governanceStatus = case(
                        isnull(todatetime(properties.remediationDueDate)), 'NoDueDate',
                        todatetime(properties.remediationDueDate) >= bin(now(), 1d), 'OnTime',
                        'Overdue'
                    ),
                    assessmentId = tolower(tostring(properties.assignedResourceId))
            | project dueDate, owner, disableOwnerEmailNotification, disableManagerEmailNotification, emailNotificationDayOfWeek, governanceStatus, assessmentId
        ) on assessmentId
        | extend completionStatus = case(
            governanceStatus == 'Overdue', 'Overdue',
            governanceStatus == 'OnTime', 'OnTime',
            statusCode == 'Unhealthy', 'Unassigned',
            'Completed'
        )
        | where completionStatus in~ ($completionStatus)
        | project displayName, resourceId, assessmentKey, resourceType, resourceName, dueDate, owner, completionStatus
        | order by completionStatus, displayName
"@

    $payLoad = @"
    {
        "query": "$($query)"
    }
"@

    Write-OutputPadded "Query Payload:" -Type 'debug' -IndentLevel 1 -BlankLineBefore
    Write-OutputPadded "$payLoad" -Type 'data' -IndentLevel 1 -BlankLineBefore

    $uri = "$($azapicallconf.azAPIEndpointUrls.ARM)/providers/Microsoft.ResourceGraph/resources?api-version=2021-03-01"
    $queryResult = AzAPICall -AzAPICallConfiguration $azapiCallConf -uri $uri -body $payLoad -method 'POST' -listenOn Content

    $GovAssignments = [System.Collections.ArrayList]::new()

    foreach ($assignment in $queryResult) {

        $GovAssignmentObj = [GovAssignment]::new()
        $GovAssignmentObj.CsEnvironment = $CsEnvironment
        $GovAssignmentObj.SourceType = 'Az'
        $GovAssignmentObj.AssessmentName = $assignment.assessmentKey
        $GovAssignmentObj.AssessmentDisplayName = $assignment.displayName
        $GovAssignmentObj.AssignedResourceId = $assignment.resourceId
        $GovAssignmentObj.ContainerId = $assignment.resourceId.split("/")[2]
        $GovAssignmentObj.AssignmentKey = $assignment.assessmentKey
        $GovAssignmentObj.RemediationDueDate = $assignment.dueDate
        $GovAssignmentObj.IsGracePeriod = $assignment.isGracePeriod
        $GovAssignmentObj.Owner = $assignment.owner
        $GovAssignmentObj.OwnerEmailNotification = $assignment.disableOwnerEmailNotification
        $GovAssignmentObj.ManagerEmailNotification = $assignment.disableManageremailnotification
        $GovAssignmentObj.NotificationDayOfWeek = $assignment.notificationDayOfWeek

        # Add the assignment to the list
        $GovAssignments.add($GovAssignmentObj)
        $assignment | Add-Member -MemberType NoteProperty -Name "Environment" -Value $CsEnvironment
    }

    return $GovAssignments
}
