<#
    .SYNOPSIS
        Determines which Azure KeyVault module is available on the system, and sets aliases for use
        within the module accordingly
#>

$script:AzureKeyVaultModule = Get-Module -Name Az.KeyVault -ListAvailable | Select-Object -First 1
if ($null -ne $script:AzureKeyVaultModule)
{
    New-Alias -Name 'Get-PSCTAzKeyVault' -Value 'Get-AzKeyVault' -Scope script
    New-Alias -Name 'Set-PSCTAzKeyVaultSecret' -Value 'Set-AzKeyVaultSecret' -Scope script
    New-Alias -Name 'Get-PSCTAzKeyVaultSecret' -Value 'Get-AzKeyVaultSecret' -Scope script
}
else
{
    $AzureKeyVaultModule = Get-Module -Name AzureRM.KeyVault -ListAvailable | Select-Object -First 1
    if ($null -ne $script:AzureKeyVaultModule)
    {
        New-Alias -Name 'Get-PSCTAzKeyVault' -Value 'Get-AzureRmKeyVault' -Scope script
        New-Alias -Name 'Set-PSCTAzKeyVaultSecret' -Value 'Set-AzureKeyVaultSecret' -Scope script
        New-Alias -Name 'Get-PSCTAzKeyVaultSecret' -Value 'Get-AzureKeyVaultSecret' -Scope script
    }
}