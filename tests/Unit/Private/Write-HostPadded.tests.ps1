$ProjectPath = "$PSScriptRoot\..\..\.." | Convert-Path
$ProjectName = ((Get-ChildItem -Path $ProjectPath\*\*.psd1).Where{
        ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
        $(try { Test-ModuleManifest $_.FullName -ErrorAction Stop } catch { $false } )
    }).BaseName


Import-Module $ProjectName

InModuleScope $ProjectName {
    Describe "Write-HostPadded" {
        It "Writes the correct text when no indent is provided" {
            Mock Write-Host {}
            Write-HostPadded -Text "Hello, world!"
            Assert-MockCalled Write-Host -Exactly -Times 1 -ParameterFilter { $Object -eq "Hello, world!" }
        }

        It "Writes the correct text when an indent is provided" {
            Mock Write-Host {}
            Write-HostPadded -Text "Hello, world!" -IndentLevel 2
            Assert-MockCalled Write-Host -Exactly -Times 1 -ParameterFilter { $Object -eq "  Hello, world!" }
        }

        It "Throws an error when no text is provided" {
            { Write-HostPadded } | Should -Throw
        }
    }
}