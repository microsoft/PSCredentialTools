@{
    # Version number of this module.
    ModuleVersion     = '1.0.2'

    # ID used to uniquely identify this module
    GUID              = '89b06e4f-42a4-4d7b-bb59-495e35d0b270'

    # Author of this module
    Author            = 'Mike Lacher'

    # Company or vendor of this module
    CompanyName       = 'Microsoft Corporation'

    # Copyright statement for this module
    Copyright         = '(c) 2018 Microsoft Corporation. All rights reserved'

    # Description of the functionality provided by this module
    Description       = 'PSCredentialTools provides various methods for securely storing and retrieving credentials used in PowerShell scripts'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '4.0'

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    NestedModules     = @(
        'Functions\Convert-SecureStringTo32ByteKey.ps1'
        'Functions\ConvertFrom-FipsSecureString.ps1'
        'Functions\ConvertFrom-PKISecureString.ps1'
        'Functions\ConvertTo-FIPSSecureString.ps1'
        'Functions\ConvertTo-PKISecureString.ps1'
        'Functions\Export-PSCredential.ps1'
        'Functions\Import-PSCredential.ps1'
        'Functions\New-Password.ps1'
        'Functions\New-PSCredential.ps1'        
    )

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @(
        'Export-PSCredential'
        'Import-PSCredential'
        'New-PSCredential'
        'ConvertFrom-FIPSSecureString'
        'ConvertTo-FIPSSecureString'
        'ConvertTo-PKISecureString'
        'ConvertFrom-PKISecureString'
    )

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport   = @()

    # Variables to export from this module
    VariablesToExport = '*'

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport   = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData       = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags         = @('Credential', 'PowerShell')

            # A URL to the license for this module.
            LicenseUri   = 'https://github.com/Microsoft/PSCredentiaTools/blob/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri   = 'https://github.com/Microsoft/PSCredentialTools'

            # ReleaseNotes of this module
            ReleaseNotes = 'https://github.com/Microsoft/PSCredentialTools/blob/master/changelog.md'

        } # End of PSData hashtable

    } # End of PrivateData hashtable
}
