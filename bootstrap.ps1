Install-Module -Name 'Sampler' -Scope 'CurrentUser'

$samplerModule = Import-Module -Name Sampler -PassThru

$invokePlasterParameters = @{
    TemplatePath      = Join-Path -Path $samplerModule.ModuleBase -ChildPath 'Templates/Sampler'
    DestinationPath   = '~/gitrepos/cs/'
    ModuleType        = 'CustomModule'
    ModuleName        = 'CyberShell'
    ModuleAuthor      = 'François Lefebvre'
    ModuleDescription = 'The CyberShell PowerShell module streamlines cloud security management, offering tools for analyzing security data and implementing cybersecurity features efficiently. It helps discovering security configuration in complex environments, consolidates security insights, aids in detecting vulnerabilities, and ensures compliance across multiple cloud platforms. With CyberShell, SOC team can quickly enhance their cloud security posture through an intuitive command-line interface.'
    LicenseType       = 'MIT'
}

Invoke-Plaster @invokePlasterParameters