# Suppressing this rule because Script Analyzer does not understand Pester's syntax.
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
Param()

BeforeDiscovery {
    try {
        if (-not (Get-Module -Name 'CyberShell')) {
            # Assumes dependencies has been resolved, so if this module is not available, run 'noop' task.
            if (-not (Get-Module -Name 'CyberShell' -ListAvailable)) {
                # Redirect all streams to $null, except the error stream (stream 2)
                & "$PSScriptRoot/../../../build.ps1" -Tasks 'noop' > $null
            }

            # If the dependencies has not been resolved, this will throw an error.
            Import-Module -Name 'CyberShell' -Force -ErrorAction 'Stop'
        }
    }
    catch [System.IO.FileNotFoundException] {
        throw 'CyberShell module dependency not found. Please run ".\build.ps1 -ResolveDependency -Tasks build" first.'


Describe 'Test' {
    BeforeAll {

        $ValidObj1Properties = @{
            SourceType       = "Az"
            ContainerId      = "00000000-0000-0000-0000-000000000000"
            ResourceTypeName = "Provider.Resource1/Type"
        }
    }
    It 'should validate correct data input' {
        { [ResourceType]::Validate(
                $ValidObj1Properties.ContainerId,
                $ValidObj1Properties.ResourceTypeName,
                $ValidObj1Properties.SourceType) } | Should -Not -Throw
    }
}
# Write-Host "Attempting to import module from path: $ProjectPath"
# Import-Module $ProjectName

# InModuleScope $ProjectName {


#     Describe "ResourceType Class Comprehensive Tests" {
#         BeforeAll {
#             $ValidObj1Properties = @{
#                 SourceType       = "Az"
#                 ContainerId      = "00000000-0000-0000-0000-000000000000"
#                 ResourceTypeName = "Provider.Resource1/Type"
#             }
#             $ValidObj2Properties = @{
#                 SourceType       = "Az"
#                 ContainerId      = "00000000-0000-0000-0000-000000000000"
#                 ResourceTypeName = "Provider.Resource2/Type"
#             }
#             $InvalidObjProperties = @{
#                 SourceType       = "Az"
#                 ContainerId      = "ObjectId"
#                 ResourceTypeName = "Provider.Resource3/Type"
#             }
#         }
#         Describe "ResourceType Class Property Initialization" {
#             It 'should validate correct data input' {
#                 { [ResourceType]::Validate(
#                         $ValidObj1Properties.ContainerId,
#                         $ValidObj1Properties.ResourceTypeName,
#                         $ValidObj1Properties.SourceType) } | Should -Not -Throw
#             }
#             It 'should not validate incorrect data input' {
#                 { [ResourceType]::Validate($InvalidObjProperties.ContainerId,
#                         $InvalidObjProperties.ResourceTypeName,
#                         $InvalidObjProperties.SourceType) } | Should -Throw
#             }
#         }
#         Describe "ResourceType  Class Constructors Tests" {
#             #default constructor
#             It 'should create an object with default constructor' {
#                 { [ResourceType]::new() } | Should -Not -Throw
#             }
#             #constructor from hashtable
#             It 'should create an object with constructor from hashtable' {
#                 { [ResourceType]::new($ValidObj1Properties) } | Should -Not -Throw
#                 $obj = [ResourceType]::new($ValidObj1Properties)
#                 $obj | Should -BeOfType [ResourceType]
#             }
#         }
#         Describe "ResourceType Class Methods Tests" {
#         }
#     }
# }