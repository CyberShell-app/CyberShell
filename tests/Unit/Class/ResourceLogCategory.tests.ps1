# Suppressing this rule because Script Analyzer does not understand Pester's syntax.
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
param ()

$ProjectPath = "$PSScriptRoot\..\..\.." | Convert-Path
$ProjectName = (Get-ChildItem $ProjectPath\*\*.psd1 | Where-Object {
        ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
        $(try { Test-ModuleManifest $_.FullName -ErrorAction Stop }catch { $false }) }
).BaseName

Import-Module $ProjectName

InModuleScope $ProjectName {

    Describe 'Test' {
        BeforeAll {

            $ValidObj1Properties = @{
                SourceType       = "Az"
                ContainerId      = "00000000-0000-0000-0000-000000000000"
                ResourceTypeName = "Provider.Resource1/Type"
            }
        }
        It 'should validate correct data input' {
            { [ResourceLogCategory]::Validate(
                    $ValidObj1Properties.ContainerId,
                    $ValidObj1Properties.ResourceTypeName,
                    $ValidObj1Properties.SourceType) } | Should -Not -Throw
        }
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
#                 { [ResourceLogCategory]::Validate(
#                         $ValidObj1Properties.ContainerId,
#                         $ValidObj1Properties.ResourceTypeName,
#                         $ValidObj1Properties.SourceType) } | Should -Not -Throw
#             }
#             It 'should not validate incorrect data input' {
#                 { [ResourceLogCategory]::Validate($InvalidObjProperties.ContainerId,
#                         $InvalidObjProperties.ResourceTypeName,
#                         $InvalidObjProperties.SourceType) } | Should -Throw
#             }
#         }
#         Describe "ResourceType  Class Constructors Tests" {
#             #default constructor
#             It 'should create an object with default constructor' {
#                 { [ResourceLogCategory]::new() } | Should -Not -Throw
#             }
#             #constructor from hashtable
#             It 'should create an object with constructor from hashtable' {
#                 { [ResourceLogCategory]::new($ValidObj1Properties) } | Should -Not -Throw
#                 $obj = [ResourceLogCategory]::new($ValidObj1Properties)
#                 $obj | Should -BeOfType [ResourceLogCategory]
#             }
#         }
#         Describe "ResourceType Class Methods Tests" {
#         }
#     }
