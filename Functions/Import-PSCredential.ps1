<#
    .SYNOPSIS
        Retrieves and decrypts an exported PowerShell Credential from file or Azure KeyVault back into a PSCredential object.

    .DESCRIPTION
        Import-PSCredential is used to retrieve a previously saved PowerShell Credential object from disk
        or from Azure KeyVault and returns a PowerShell Credential object [System.Management.Automation.PSCredential] that can be used within scripts and
        Desired State Configurations. When retrieving from disk, the method used to encrypt the credential must be used to decrypt the credential.

    .PARAMETER Path
        Path to the JSON file that contains the encrypted credential.

    .PARAMETER SecureKey
        The SecureString that was used as a Pre-Shared-Key for encrypting the credential password.

    .PARAMETER Thumbprint
        The Thumbprint of the certificate on the local computer that contains the private key of the certificate used to encrypt the credential password.

    .PARAMETER CertificateStore
        Specifies the certifcate store of the specified certificate thumbprint. Either LocalMachine or CurrentUser.

    .PARAMETER KeyVault
        The name of the Azure KeyVault that will that contains the exported credential secret.

    .PARAMETER SecretName
        The name of the Azure KeyVault secret that contains the exported credential.

    .EXAMPLE
        $Credential = Import-PSCredential -Path ./savedcredential.json -SecureKey ( Convertto-SecureString -String '$ecretK3y' -AsPlainText -Force )

        Import a credential from file using a pre-shared key.

    .EXAMPLE
        $Credential = Import-PSCredential -Path ./savedcredential.json -Thumbprint '87BB70A19A7671D389F49AF4C9608B2F381FDD80'

        Import a credential from file using a Certificate.

    .EXAMPLE
        $Credential = Import-PSCredential -KeyVault 'My-KeyVault' -SecretName 'SavedCred-Secret'

        Import a credential from an Azure KeyVault. The user executing the script must be authenticated to Azure with sufficient permissions to the KeyVault.
#>
function Import-PSCredential
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName="LocalKey",Position=1)]
        [Parameter(Mandatory = $true, ParameterSetName="CertificateThumbprint",Position=1)]
        [System.String]
        $Path,

        [Parameter(Mandatory = $true, ParameterSetName="LocalKey")]
        [System.Security.SecureString]
        $SecureKey,

        [Parameter(Mandatory = $true, ParameterSetName="CertificateThumbprint")]
        [ValidateNotNullorEmpty()]
        [System.String]$Thumbprint,

        [Parameter(Mandatory = $false, ParameterSetName="CertificateThumbprint")]
        [ValidateSet("LocalMachine","CurrentUser")]
        [System.String]
        $CertificateStore,

        [Parameter(Mandatory = $true, ParameterSetName="KeyVault")]
        [System.String]
        $KeyVault,

        [Parameter(Mandatory = $true, ParameterSetName="KeyVault")]
        [System.String]
        $SecretName
    )


    if ($PSCmdlet.ParameterSetName -eq 'KeyVault')
    {
        try
        {
            $keyVaultObject = Get-AzureRmKeyVault -VaultName $keyVault -ErrorAction Stop
        }
        catch
        {
            throw "Unable to access KeyVault $KeyVault, ensure that the current session has access to it. Use Add-AzureRmAccount or Login-AzureRmAccount to establish access for the current session. $($_)"
        }

        if ($null -eq $keyVaultObject)
        {
            throw "Unable to find KeyVault $KeyVault within the current subscription"
        }

        Write-Verbose -Message "Reading credential object data from $KeyVault"
        $SecretData = Get-AzureKeyVaultSecret -VaultName $KeyVault -Name $SecretName

        if ($null -eq $SecretData)
        {
            throw "Could not read data from $SecretName in $KeyVault"
        }

        $username = ($SecretData.Attributes.Tags).username
        if ($null -eq $username)
        {
            throw "$SecretName does not have a Username tag"
        }

        New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList @($username,$SecretData.SecretValue)

    }
    elseif ($PSBoundParameters.ContainsKey('Path'))
    {
        Write-Verbose "Reading credential object data from $Path"
        $CredentialImport = Get-Content $Path -Raw | ConvertFrom-Json

        if ($PSCmdlet.ParameterSetName -eq 'LocalKey')
        {
            $SecureStringPassword = ConvertTo-FIPSsecureString -EncryptedString $CredentialImport.Password -SecureKey $SecureKey -Verbose:$Verbose
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'CertificateThumbprint')
        {
            if ($PSBoundParameters.ContainsKey('CertificateStore'))
            {
                $SecureStringPassword = ConvertTo-PKISecureString -EncryptedString $CredentialImport.Password -Thumbprint $Thumbprint -CertificateStore $CertificateStore
            }

            $SecureStringPassword = ConvertTo-PKISecureString -EncryptedString $CredentialImport.Password -Thumbprint $Thumbprint
        }

        New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList @(($CredentialImport.UserName),$SecureStringPassword)
    }
}
