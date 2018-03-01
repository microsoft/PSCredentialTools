function Export-PSCredential
{
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
Export a credential to file using a pre-shared key.
$Credential | Export-PSCredential -Path ./savedcredential.json -SecureKey ('$ecretK3y' | Convertto-SecureString -AsPlainText -Force)

.EXAMPLE
Export a credential to file using a Certificate
$Credential | Export-PSCredential -Path ./savedcredential.json -Thumbprint '87BB70A19A7671D389F49AF4C9608B2F381FDD80'

.EXAMPLE
Export a credential to an existing Azure KeyVault. The user executing the script must be authenticated to Azure with sufficient permissions to the KeyVault.
$Credential | Export-PSCredential -KeyVault 'My-KeyVault' -SecretName 'SavedCred-Secret'

#>
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, ParameterSetName="LocalKey",Position=1,ValueFromPipeline=$true)]
        [parameter(Mandatory = $true, ParameterSetName="KeyVault",Position=1,ValueFromPipeline=$true)]
        [parameter(Mandatory = $true, ParameterSetName="CertificateThumbprint",Position=1,ValueFromPipeline=$true)]
        [parameter(Mandatory = $true, ParameterSetName="CertFile",Position=1,ValueFromPipeline=$true)]
        [ValidateNotNullorEmpty()]
         [pscredential]$Credential,

        [parameter(Mandatory = $true, ParameterSetName="LocalKey",Position=2)]
        [parameter(Mandatory = $true, ParameterSetName="CertificateThumbprint",Position=2)]
        [parameter(Mandatory = $true, ParameterSetName="CertFile",Position=2)]
        [ValidateNotNullorEmpty()]
         [string]$Path,

        [parameter(Mandatory = $true, ParameterSetName="LocalKey")]
        [ValidateNotNullorEmpty()]
         [securestring]$SecureKey,

        [parameter(Mandatory = $true, ParameterSetName="CertificateThumbprint")]
        [ValidateNotNullorEmpty()]
         [string]$Thumbprint,

        [parameter(Mandatory = $true, ParameterSetName="CertFile",Position=1,ValueFromPipeline=$true)]
        [ValidateScript({test-path $_})]
         [string]$CertificateFile,

        [parameter(Mandatory = $false, ParameterSetName="CertificateThumbprint")]
        [ValidateSet("LocalMachine","CurrentUser")]
         [string]$CertificateStore,


        [parameter(Mandatory = $true, ParameterSetName="KeyVault")]
         [string]$KeyVault,

         [parameter(Mandatory = $true, ParameterSetName="KeyVault")]
         [string]$SecretName
    )


    if ($PSCmdlet.ParameterSetName -eq 'KeyVault') {
        try
        {
            $keyVaultObject = Get-AzureRmKeyVault -VaultName $keyVault -ErrorAction "Stop"
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



function Import-PSCredential
{
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
Import a credential from file using a pre-shared key.
$Credential = Import-PSCredential -Path ./savedcredential.json -SecureKey ('$ecretK3y' | Convertto-SecureString -AsPlainText -Force)

.EXAMPLE
Import a credential from file using a Certificate
$Credential = Import-PSCredential -Path ./savedcredential.json -Thumbprint '87BB70A19A7671D389F49AF4C9608B2F381FDD80'

.EXAMPLE
Import a credential from an Azure KeyVault. The user executing the script must be authenticated to Azure with sufficient permissions to the KeyVault.
$Credential = Import-PSCredential -KeyVault 'My-KeyVault' -SecretName 'SavedCred-Secret'
#>
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, ParameterSetName="LocalKey",Position=1)]
        [parameter(Mandatory = $true, ParameterSetName="CertificateThumbprint",Position=1)]
         [string]$Path,

        [parameter(Mandatory = $true, ParameterSetName="LocalKey")]
        [securestring]$SecureKey,

        [parameter(Mandatory = $true, ParameterSetName="CertificateThumbprint")]
        [ValidateNotNullorEmpty()]
         [string]$Thumbprint,

        [parameter(Mandatory = $false, ParameterSetName="CertificateThumbprint")]
        [ValidateSet("LocalMachine","CurrentUser")]
          [string]$CertificateStore,

        [parameter(Mandatory = $true, ParameterSetName="KeyVault")]
         [string]$KeyVault,

         [parameter(Mandatory = $true, ParameterSetName="KeyVault")]
         [string]$SecretName
    )


    if ($PSCmdlet.ParameterSetName -eq 'KeyVault') {
        try
        {
            $keyVaultObject = Get-AzureRmKeyVault -VaultName $keyVault -ErrorAction "Stop"
        }
        catch
        {
            throw "Unable to access KeyVault $KeyVault, ensure that the current session has access to it. Use Add-AzureRmAccount or Login-AzureRmAccount to establish access for the current session. $($_)"
        }

        if ($null -eq $keyVaultObject)
        {
            throw "Unable to find KeyVault $KeyVault within the current subscription"
        }

        Write-Verbose "Reading credential object data from $KeyVault"
        $SecretData = Get-AzureKeyVaultSecret -VaultName $KeyVault -Name $SecretName

        if ($null -eq $SecretData)
        {
            throw "Could not read data from $SecretName in $KeyVault"
        }

        $Username = ($SecretData.Attributes.Tags).username
        if ($null -eq $Username)
        {
            throw "$SecretName does not have a Username tag"
        }

        New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList @($UserName,$SecretData.SecretValue)

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

function New-PSCredential
{
<#
.SYNOPSIS
Create a new PowerShell Credential object with a random password. Encrypts and saves the Credential object to file or to Azure KeyVault

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
Creating a credential to be used as a service account, and creating the account.
$Credential = New-PSCredential -Username 'svc.SharePoint.farm' -Path ./savedcredential.json -Thumbprint '87BB70A19A7671D389F49AF4C9608B2F381FDD80'
New-ADUser -Name $Credential.Username -AccountPassword $Credential.Password -Enabled:$true

#>
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, ParameterSetName="LocalKey",Position=1,ValueFromPipeline=$true)]
        [parameter(Mandatory = $true, ParameterSetName="KeyVault",Position=1,ValueFromPipeline=$true)]
        [parameter(Mandatory = $true, ParameterSetName="CertificateThumbprint",Position=1,ValueFromPipeline=$true)]
        [parameter(Mandatory = $true, ParameterSetName="CertFile",Position=1,ValueFromPipeline=$true)]
         [string]$Username,

         [parameter(Mandatory = $true, ParameterSetName="LocalKey",Position=2)]
         [parameter(Mandatory = $true, ParameterSetName="CertificateThumbprint",Position=2)]
         [parameter(Mandatory = $true, ParameterSetName="CertFile",Position=2)]
         [ValidateNotNullorEmpty()]
          [string]$Path,

         [parameter(Mandatory = $true, ParameterSetName="LocalKey")]
         [ValidateNotNullorEmpty()]
          [securestring]$SecureKey,

         [parameter(Mandatory = $true, ParameterSetName="CertificateThumbprint")]
         [ValidateNotNullorEmpty()]
          [string]$Thumbprint,

         [parameter(Mandatory = $true, ParameterSetName="CertFile",Position=1,ValueFromPipeline=$true)]
         [ValidateScript({test-path $_})]
          [string]$CertificateFile,

         [parameter(Mandatory = $false, ParameterSetName="CertificateThumbprint")]
         [ValidateSet("LocalMachine","CurrentUser")]
          [string]$CertificateStore,


         [parameter(Mandatory = $true, ParameterSetName="KeyVault")]
          [string]$KeyVault,

          [parameter(Mandatory = $true, ParameterSetName="KeyVault")]
          [string]$SecretName
    )


    $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList @($Username, (ConvertTo-SecureString -String (New-Password) -AsPlainText -Force) )

    $PSBoundParameters.Remove('Username') | Out-Null
    $ExportParameters = $PSBoundParameters
    $ExportParameters.Add('Credential',$Credential)

    Export-PSCredential @ExportParameters | Out-Null

    return $Credential

}
