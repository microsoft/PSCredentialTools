<#
    .SYNOPSIS
        Create a new PowerShell Credential object with a random password. Encrypts and saves the Credential object to file or to Azure KeyVault.

    .DESCRIPTION
        New-PSCredential is used to create a new  PowerShell Credential object [System.Management.Automation.PSCredential] with the provided username and
        a strong random password. The resulting credential object is returned as well as saved to disk or to Azure KeyVault so that it can be retrieved later.
        When saving to disk, the password is encrypted with either a pre-shared key or PKI certificate.

    .PARAMETER Username
        Username to use for the Credential to be created.

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
        $Credential = New-PSCredential -Username 'svc.SharePoint.farm' -Path ./savedcredential.json -Thumbprint '87BB70A19A7671D389F49AF4C9608B2F381FDD80'
        New-ADUser -Name $Credential.Username -AccountPassword $Credential.Password -Enabled:$true

        Creating a credential to be used as a service account, and creating the account.
#>
function New-PSCredential
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName="LocalKey",Position=1,ValueFromPipeline=$true)]
        [Parameter(Mandatory = $true, ParameterSetName="KeyVault",Position=1,ValueFromPipeline=$true)]
        [Parameter(Mandatory = $true, ParameterSetName="CertificateThumbprint",Position=1,ValueFromPipeline=$true)]
        [Parameter(Mandatory = $true, ParameterSetName="CertFile",Position=1,ValueFromPipeline=$true)]
        [System.String]
        $Username,

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

    $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList @($Username, (ConvertTo-SecureString -String (New-Password) -AsPlainText -Force) )

    $PSBoundParameters.Remove('Username') | Out-Null
    $ExportParameters = $PSBoundParameters
    $ExportParameters.Add('Credential',$Credential)

    Export-PSCredential @ExportParameters | Out-Null

    return $Credential
}
