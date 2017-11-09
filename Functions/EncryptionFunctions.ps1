function ConvertFrom-FIPSSecureString
{
<#
.SYNOPSIS
Converts a SecureString object into encrypted text with a FIPS compliant algorithm using a pre-shared key.
The Pre-Shared key can be provided as either a 32 byte array or a SecureString value.

.PARAMETER SecureString
The SecureString object that will returned as an encrypted string.

.PARAMETER Key
An array of 32 bytes that will be used as a the pre-shared key for encryption.

.PARAMETER SecureKey
A SecureString that will be converted into a 32 byte array used as the pre-shared key for encryption.

.EXAMPLE
Encrypt a SecureString object and save it to disk
$EncryptedText = ConvertFrom-FIPSSecureString -SecureString $MySecretValue -SecureKey ('Pr3$haredK3y' | Convertto-SecureString -AsPlainText -Force)
$EncryptedText | Out-File ./encryptedText.txt

#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,Position=1,ValueFromPipeline=$true,ParameterSetName="KeyByte")]
        [Parameter(Mandatory=$True,Position=1,ValueFromPipeline=$true,ParameterSetName="SecureKey")]
        [ValidateNotNullOrEmpty()]
         [System.Security.SecureString]$SecureString,

        [Parameter(Mandatory=$True,ParameterSetName="KeyByte")]
        [ValidateNotNullOrEmpty()]
         [byte[]]$Key,

        [Parameter(Mandatory=$True,ParameterSetName="SecureKey")]
        [ValidateNotNullOrEmpty()]
         [System.Security.SecureString]$SecureKey
    )

    if ($PSBoundParameters.ContainsKey('SecureKey')) {
        $Key = Convert-SecureStringto32ByteKey -SecureString $SecureKey
    }

    if ($null -eq $Key -or $Key.GetLength(0) -ne 32) {
        throw "Key must be provided as a 32byte (256bit) byte array"
    }


    $BSTR = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
    $dataBytes = [System.Text.Encoding]::UTF8.GetBytes([Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR))
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)

    $aes = New-Object -TypeName System.Security.Cryptography.AesCryptoServiceProvider
        $aes.Mode = [System.Security.Cryptography.CipherMode]::CBC
        $aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
        $aes.BlockSize = 128
        $aes.KeySize = 256
        $aes.Key = $Key

    $encryptionObject = $aes.CreateEncryptor()

    Write-Verbose -Message "Converting SecureString to encrypted string with AESCryptoServiceProvider"
    [byte[]]$encryptedDataBytes = $aes.IV + ($encryptionObject.TransformFinalBlock($dataBytes,0,$dataBytes.Length))

    $aes.Dispose()

    return [System.Convert]::ToBase64String($encryptedDataBytes)

}


function ConvertTo-FIPSSecureString
{
<#
.SYNOPSIS
Converts a string of encrypted text back into a SecureString object with a FIPS compliant algorithm using a pre-shared key.
The Pre-Shared key can be provided as either a 32 byte array or a SecureString value.

.PARAMETER EncryptedString
The string of encrypted text to convert back into a SecureString object

.PARAMETER Key
An array of 32 bytes that will be used as a the pre-shared key for decryption.

.PARAMETER SecureKey
A SecureString that will be converted into a 32 byte array used as the pre-shared key for decryption.

.EXAMPLE
$EncryptedText = Get-Content ./encryptedText.txt
$MySecret = ConvertTo-FIPSSecureString -EncryptedString $EncryptedText -SecureKey ('Pr3$haredK3y' | Convertto-SecureString -AsPlainText -Force)

#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,Position=1,ValueFromPipeline=$true,ParameterSetName="KeyByte")]
        [Parameter(Mandatory=$True,Position=1,ValueFromPipeline=$true,ParameterSetName="SecureKey")]
        [ValidateNotNullOrEmpty()]
         [System.String]$EncryptedString,

        [Parameter(Mandatory=$True,ParameterSetName="KeyByte")]
        [ValidateNotNullOrEmpty()]
         [byte[]]$Key,

        [Parameter(Mandatory=$True,ParameterSetName="SecureKey")]
        [ValidateNotNullOrEmpty()]
         [System.Security.SecureString]$SecureKey
    )

    if ($PSBoundParameters.ContainsKey('SecureKey')) {
        $Key = Convert-SecureStringto32ByteKey -SecureString $SecureKey
    }

    if ($null -eq $Key -or $Key.GetLength(0) -ne 32) {
        throw "Key must be provided as a 32byte (256bit) byte array"
    }

    $dataBytes =  [System.Convert]::FromBase64String($EncryptedString)
    $IV = $dataBytes[0..15]

    $aes = New-Object -TypeName System.Security.Cryptography.AesCryptoServiceProvider
        $aes.Mode = [System.Security.Cryptography.CipherMode]::CBC
        $aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
        $aes.BlockSize = 128
        $aes.KeySize = 256
        $aes.Key = $Key
        $aes.IV = $IV

    $decryptionObject = $aes.CreateDecryptor()

    Write-Verbose -Message "Converting AES encrypted string to SecureString"
    [byte[]]$decryptedDataBytes =$decryptionObject.TransformFinalBlock($dataBytes,16,$dataBytes.Length -16)

    $aes.Dispose()

    return ([System.Text.Encoding]::UTF8.GetString($decryptedDataBytes) | ConvertTo-SecureString -AsPlainText -Force)

}

function ConvertFrom-PKISecureString
{
<#
.SYNOPSIS
Converts a SecureString object into encrypted text with the public key of a PKI certificate.

.PARAMETER SecureString
The SecureString object that will returned as an encrypted string.

.PARAMETER Thumbprint
The ThumbPrint of a certificate on the local computer that will be used to encrypt the string.

.PARAMETER CertificateFile
Path to a .CER certificate public key file that will be used to encrypt the string.

.PARAMETER CertificateStore
Specifies the certifcate store of the specified certificate thumbprint. Either LocalMachine or CurrentUser.

.EXAMPLE
Encrypt a SecureString object and save it to disk
$EncryptedText = ConvertFrom-PKISecureString -SecureString $MySecretValue -Thumbprint '87BB70A19A7671D389F49AF4C9608B2F381FDD80'
$EncryptedText | Out-File ./encryptedText.txt

#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,Position=1,ValueFromPipeline=$True,ParameterSetName="Thumbprint")]
        [Parameter(Mandatory=$True,Position=1,ValueFromPipeline=$True,ParameterSetName="CertFile")]
        [ValidateNotNullOrEmpty()]
         [System.Security.SecureString]$SecureString,

        [Parameter(Mandatory=$true,ParameterSetName="Thumbprint")]
        [ValidateNotNullOrEmpty()]
         [System.String]$Thumbprint,

        [Parameter(Mandatory=$True,ParameterSetName="CertFile")]
        [ValidateScript({test-path $_})]
         [System.String]$CertificateFile,

        [Parameter(Mandatory=$False,ParameterSetName="Thumbprint")]
        [ValidateSet("CurrentUser","LocalMachine")]
         [System.String]$CertificateStore
    )

    $BSTR = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
    $dataBytes = [System.Text.Encoding]::UTF8.GetBytes([Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR))
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)

    if ($PSCmdlet.ParameterSetName -eq "CertFile") {
        $Certificate = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2($CertificateFile)
        if ($null -eq $Certificate.Thumbprint)
        {
            throw "$CertificateFile does not appear to be a valid x509 certificate file"
        }
    } else {
        if ($PSBoundParameters.ContainsKey('CertificateStore'))
        {
            $Certificate = Get-Item "Cert:\$CertificateStore\My\$Thumbprint" -ErrorAction "SilentlyContinue"
            #error checking
            if ($null -eq $Certificate.Thumbprint)
            {
                throw "Could not find a valid certificate in the $CertificateStore store with thumbprint $Thumbprint"
            }
        } else {
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
    }

    Write-Verbose "Converting SecureString to encrypted string with certificate thumbprint $($Certificate.Thumbprint)"
    $EncryptedBytes = $Certificate.PublicKey.Key.Encrypt($dataBytes,$True)

    return [Convert]::ToBase64String($EncryptedBytes)

}

function ConvertTo-PKISecureString
{
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
Read an encrypted string from disk and decrypt it back into a SecureString
$EncryptedText = Get-Content ./encryptedText.txt
$MySecretValue = ConvertTo-PKISecureString -EncryptedString $EncryptedValue -Thumbprint '87BB70A19A7671D389F49AF4C9608B2F381FDD80'

#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,Position=1,ValueFromPipeline=$True)]
        [ValidateNotNullOrEmpty()]
        [System.String]$EncryptedString,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]$Thumbprint,

        [Parameter(Mandatory=$False)]
        [ValidateSet("CurrentUser","LocalMachine")]
        [System.String]$CertificateStore
    )


    if ($PSBoundParameters.ContainsKey('CertificateStore'))
    {
        $Certificate = Get-Item "Cert:\$CertificateStore\My\$Thumbprint" -ErrorAction "SilentlyContinue"
        #error checking
        if ($null -eq $Certificate.Thumbprint)
        {
            throw "Could not find a valid certificate in the $CertificateStore store with thumbprint $Thumbprint"
        }
    } else {
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
    $EncryptedBytes = [Convert]::FromBase64String($EncryptedString)

    return ([System.Text.Encoding]::UTF8.GetString($Certificate.PrivateKey.Decrypt($EncryptedBytes,$True)) | ConvertTo-SecureString -AsPlainText -Force)


}
