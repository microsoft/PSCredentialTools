<#
    .SYNOPSIS
        Encrypts and saves a PowerShell Credential object to file or to Azure KeyVault

    .DESCRIPTION
        Export-PSCredential is used to save a PowerShell Credential object [System.Management.Automation.PSCredential] to disk
        or to Azure KeyVault so that it can be retrieved later. When saving to disk, the password is encrypted with either a pre-shared key
        or a PKI certificate.

    .PARAMETER Credential
        The Credential object that will be exported.

    .PARAMETER Path
        Path to the JSON file that will be created to save the encrypted credential.

    .PARAMETER SecureKey
        A SecureString that is used as a Pre-Shared-Key for encrypting the credential password.

    .PARAMETER Thumbprint
        The ThumbPrint of a certificate on the local computer that will be used to encrypt the credential password.

    .PARAMETER CertificateFile
        Path to a .CER certificate public key file that will be used to encrypt the credential password.

    .PARAMETER CertificateStore
        Specifies the certifcate store of the specified certificate thumbprint. Either LocalMachine or CurrentUser.

    .PARAMETER KeyVault
        The name of the Azure KeyVault that will be used to store the exported credential.

    .PARAMETER SecretName
        The name of the Azure KeyVault secret to create that will be used to store the exported credential.

    .EXAMPLE
        $Credential | Export-PSCredential -Path ./savedcredential.json -SecureKey ( Convertto-SecureString -String '$ecretK3y' -AsPlainText -Force)

        Export a credential to file using a pre-shared key.

    .EXAMPLE
        $Credential | Export-PSCredential -Path ./savedcredential.json -Thumbprint '87BB70A19A7671D389F49AF4C9608B2F381FDD80'

        Export a credential to file using a Certificate.

    .EXAMPLE
        $Credential | Export-PSCredential -KeyVault 'My-KeyVault' -SecretName 'SavedCred-Secret'

        Export a credential to an existing Azure KeyVault. The user executing the script must be authenticated to Azure with sufficient permissions to the KeyVault.
#>
function Export-PSCredential
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName="LocalKey",Position=1,ValueFromPipeline=$true)]
        [Parameter(Mandatory = $true, ParameterSetName="KeyVault",Position=1,ValueFromPipeline=$true)]
        [Parameter(Mandatory = $true, ParameterSetName="CertificateThumbprint",Position=1,ValueFromPipeline=$true)]
        [Parameter(Mandatory = $true, ParameterSetName="CertFile",Position=1,ValueFromPipeline=$true)]
        [ValidateNotNullorEmpty()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter(Mandatory = $true, ParameterSetName="LocalKey",Position=2)]
        [Parameter(Mandatory = $true, ParameterSetName="CertificateThumbprint",Position=2)]
        [Parameter(Mandatory = $true, ParameterSetName="CertFile",Position=2)]
        [ValidateNotNullorEmpty()]
        [System.String]
        $Path,

        [Parameter(Mandatory = $true, ParameterSetName="LocalKey")]
        [ValidateNotNullorEmpty()]
        [System.Security.SecureString]
        $SecureKey,

        [Parameter(Mandatory = $true, ParameterSetName="CertificateThumbprint")]
        [ValidateNotNullorEmpty()]
        [System.String]
        $Thumbprint,

        [Parameter(Mandatory = $true, ParameterSetName="CertFile",Position=1,ValueFromPipeline=$true)]
        [ValidateScript({test-path $_})]
        [System.String]
        $CertificateFile,

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

        Write-Verbose -Message "Saving Credential to KeyVault $KeyVault"
        Set-AzureKeyVaultSecret -VaultName $KeyVault -Name  $SecretName -SecretValue $Credential.Password -Tag @{username = $Credential.UserName}
    }
    elseif ($PSBoundParameters.ContainsKey('Path'))
    {
        $CredentialExport = New-Object -TypeName PSObject -Property @{Username = $Credential.UserName;Password = $null}

        if ($PSCmdlet.ParameterSetName -eq 'LocalKey')
        {
            $CredentialExport.Password = ConvertFrom-FIPSsecureString -SecureString $Credential.Password -SecureKey $SecureKey -Verbose:$Verbose
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'CertificateThumbprint')
        {
            if ($PSBoundParameters.ContainsKey('CertificateStore'))
            {
                $CredentialExport.Password = ConvertFrom-PKISecureString -SecureString $Credential.Password -Thumbprint $Thumbprint -CertificateStore $CertificateStore -Verbose:$Verbose
            }
            else
            {
                $CredentialExport.Password = ConvertFrom-PKISecureString -SecureString $Credential.Password -Thumbprint $Thumbprint -Verbose:$Verbose
            }
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'CertFile') {
            $CredentialExport.Password = ConvertFrom-PKISecureString -SecureString $Credential.Password -CertificateFile $CertificateFile -Verbose:$Verbose
        }

        Write-Verbose -Message "Saving Credential to $Path"
        $CredentialExport | ConvertTo-Json | Out-File $Path
    }
}
