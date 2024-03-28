# Suppressing this rule because Script Analyzer does not understand Pester's syntax.
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
param ()

$ProjectPath = "$PSScriptRoot\..\..\.." | Convert-Path
$ProjectName = (Get-ChildItem $ProjectPath\*\*.psd1 | Where-Object {
        ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
        $(try { Test-ModuleManifest $_.FullName -ErrorAction Stop }catch { $false }) }
).BaseName

# Import the project module
Import-Module $ProjectName

# Define tests within the scope of the project module
InModuleScope $ProjectName {

    # Describe the group of tests for the ResourceLogCategory class
    Describe 'ResourceLogCategory Class Unit Tests' {
        # Define setup actions to be performed before all tests
        BeforeAll {

            # Define properties for valid and invalid test objects
            $ValidObj1Properties = @{
                SourceType       = "Az"
                ContainerId      = "11111111-1111-1111-1111-111111111111"
                ResourceTypeName = "Provider.Resource1/Type"
            }
            $ValidObj2Properties = @{
                SourceType       = "Az"
                ContainerId      = "22222222-2222-2222-2222-222222222222"
                ResourceTypeName = "Provider.Resource2/Type"
            }
            $InvalidObjProperties = @{
                SourceType       = "Az"
                ContainerId      = "ObjectId"
                ResourceTypeName = "Provider.Resource3/Type"
            }
            $IncompleteObjProperties = @{
                SourceType  = "Az"
                ContainerId = "00000000-0000-0000-0000-000000000000"
            }

            # Mock the Get-AzDiagnosticSettingCategory function to return predefined results for testing
            Mock -CommandName 'Get-AzDiagnosticSettingCategory' -MockWith {
                param($ResourceId)

                if ($ResourceId -eq "11111111-1111-1111-1111-111111111111") {
                    return @(
                        @{ Name = "LogCategory1"; CategoryType = "Logs" },
                        @{ Name = "MetricCategory1"; CategoryType = "Metrics" }
                    )
                }
                else {
                    return @()
                }
            }

            # Mock the Get-AzResource function to return predefined results for testing
            Mock -CommandName 'Get-AzResource' -MockWith {
                param($ResourceId)

                if ($ResourceId -eq "11111111-1111-1111-1111-111111111111") {
                    return @{ ResourceType = "Provider.Resource1/Type" }
                }
                elseif ($ResourceId -eq "22222222-2222-2222-2222-222222222222") {
                    return @{ ResourceType = "Provider.Resource2/Type" }
                }
                else {
                    return @{ ResourceType = "Provider.Resource3/Type" }
                }
            }
        }

        # Describe the group of tests for property initialization
        Describe 'ResourceLogCategory Class Property Initialization' {
            # Test that valid data input is validated correctly
            It 'should validate correct data input' {
                { [ResourceLogCategory]::Validate(
                        $ValidObj1Properties.ContainerId,
                        $ValidObj1Properties.ResourceTypeName,
                        $ValidObj1Properties.SourceType) } | Should -Not -Throw
            }
            # Test that invalid data input is not validated
            It 'should not validate incorrect data input' {
                { [ResourceLogCategory]::Validate(
                        $InvalidObjProperties.ContainerId,
                        $InvalidObjProperties.ResourceTypeName,
                        $InvalidObjProperties.SourceType) } | Should -Throw
            }
            # Test that empty data input is not validated
            It 'should not validate empty data input' {
                { [ResourceLogCategory]::Validate('', '', '') } | Should -Throw
            }
        }

        # Describe the group of tests for constructors
        Describe 'ResourceLogCategory Class Constructors Tests' {
            # Test that the object is created correctly with separate properties
            It 'Should create the object with separate properties' {
                { [ResourceLogCategory]::new(
                        $ValidObj1Properties.ContainerId,
                        $ValidObj1Properties.ResourceTypeName,
                        $ValidObj1Properties.SourceType) } | Should -Not -Throw
            }
            # Test that the object is created correctly from a hashtable
            It 'should create an object with constructor from hashtable' {
                { $obj = [ResourceLogCategory]::new($ValidObj1Properties) } | Should -Not -Throw
            }
        }

        # Describe the group of tests for methods
        Describe 'ResourceLogCategory Class Methods Tests' {

            # Test that the method handles resource types with diagnostic settings available
            It 'should handle resource type with diagnostic settings available' {
                $obj = [ResourceLogCategory]::new($ValidObj1Properties)
                { $obj.GetDiagnosticSettings() } | Should -Not -Throw
            }

            # Test that the method handles resource types with no diagnostic settings
            It 'should handle resource type with no diagnostic settings' {
                $obj = [ResourceLogCategory]::new($ValidObj2Properties)
                { $obj.GetDiagnosticSettings() } | Should -Not -Throw
            }

            # Test that the method returns a string representation of the object
            It 'should return a string representation of the object' {
                $obj = [ResourceLogCategory]::new($ValidObj1Properties)
                { $obj.ToString() } | Should -Not -Throw
            }
        }

    }
}