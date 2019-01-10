<#
    .SYNOPSIS
        Converts a string of encrypted text back into a SecureString object with the private key of a PKI certificate.

    .PARAMETER EncryptedString
        The string of encrypted text to convert back into a SecureString object

    .PARAMETER Thumbprint
        The ThumbPrint of a certificate on the local computer that will be used to decrypt the string.

    .PARAMETER CertificateStore
        Specifies the certifcate store of the specified certificate thumbprint. Either LocalMachine or CurrentUser.

    .EXAMPLE
        $EncryptedText = Get-Content ./encryptedText.txt
        $MySecretValue = ConvertTo-PKISecureString -EncryptedString $EncryptedValue -Thumbprint '87BB70A19A7671D389F49AF4C9608B2F381FDD80'
        
        Reads an encrypted string from disk and decrypts it back into a SecureString.
#>
function ConvertTo-PKISecureString
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True,Position=1,ValueFromPipeline=$True)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $EncryptedString,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Thumbprint,

        [Parameter(Mandatory=$False)]
        [ValidateSet('CurrentUser','LocalMachine')]
        [System.String]
        $CertificateStore
    )

    if ($PSBoundParameters.ContainsKey('CertificateStore'))
    {
        $Certificate = Get-Item "Cert:\$CertificateStore\My\$Thumbprint" -ErrorAction "SilentlyContinue"
        #error checking
        if ($null -eq $Certificate.Thumbprint)
        {
            throw "Could not find a valid certificate in the $CertificateStore store with thumbprint $Thumbprint"
        }
    }
    else
    {
        #first look in CurrentUser
        $Certificate = Get-Item "Cert:\CurrentUser\My\$Thumbprint" -ErrorAction "Silentlycontinue"
        if ($null -eq $Certificate.Thumbprint)
        {
            #nothing in CurrentUser, try LocalMachine
            $Certificate = Get-Item "Cert:\LocalMachine\My\$Thumbprint" -ErrorAction "Silentlycontinue"
        }

        #error checking
        if ($null -eq $Certificate.Thumbprint)
        {
            throw "Could not find a valid certificate in the CurrentUser or LocalMachine store with thumbprint $Thumbprint"
        }
    }

    Write-Verbose "Converting encrypted string to SecureString with certificate thumbprint $($Certificate.Thumbprint)"
    $EncryptedBytes = [System.Convert]::FromBase64String($EncryptedString)

    return ([System.Text.Encoding]::UTF8.GetString($Certificate.PrivateKey.Decrypt($EncryptedBytes,$True)) | ConvertTo-SecureString -AsPlainText -Force)
}
