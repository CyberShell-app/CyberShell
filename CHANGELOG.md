# Changelog for CyberShell

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Initialize module with Sampler: Use the [Sampler](https://github.com/gaelcolas/Sampler) framework to streamline PowerShell module development, including testing and CI/CD processes. (#2)
- 'Import-CsEnvironment': Import settings and environments from JSON/JSONC files to configure PowerShell environments easily. (#10)
- 'Write-OutputPadded': Enhance output readability by formatting it with customizable padding and styling options.
- 'Set-CsConfig': Create or update configuration files to adjust PowerShell environment settings as needed. (#11)
- 'Set-ScriptExecutionPreference': Control script execution policies within scripts scope for improved display of verbose and debug messages