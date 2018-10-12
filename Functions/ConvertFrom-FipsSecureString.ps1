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
function ConvertFrom-FIPSSecureString
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True,Position=1,ValueFromPipeline=$true,ParameterSetName="KeyByte")]
        [Parameter(Mandatory=$True,Position=1,ValueFromPipeline=$true,ParameterSetName="SecureKey")]
        [ValidateNotNullOrEmpty()]
        [System.Security.SecureString]
        $SecureString,

        [Parameter(Mandatory=$True,ParameterSetName='KeyByte')]
        [ValidateNotNullOrEmpty()]
        [System.Byte[]]
        $Key,

        [Parameter(Mandatory=$True,ParameterSetName='SecureKey')]
        [ValidateNotNullOrEmpty()]
        [System.Security.SecureString]
        $SecureKey
    )

    if ($PSBoundParameters.ContainsKey('SecureKey'))
    {
        $Key = Convert-SecureStringTo32ByteKey -SecureString $SecureKey
    }

    if ($null -eq $Key -or $Key.GetLength(0) -ne 32)
    {
        throw 'Key must be provided as a 32byte (256bit) byte array'
    }

    $btsr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
    $dataBytes = [System.Text.Encoding]::UTF8.GetBytes([Runtime.InteropServices.Marshal]::PtrToStringAuto($btsr))
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($btsr)

    $aes = New-Object -TypeName System.Security.Cryptography.AesCryptoServiceProvider
    $aes.Mode = [System.Security.Cryptography.CipherMode]::CBC
    $aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
    $aes.BlockSize = 128
    $aes.KeySize = 256
    $aes.Key = $Key

    $encryptionObject = $aes.CreateEncryptor()

    Write-Verbose -Message 'Converting SecureString to encrypted string with AESCryptoServiceProvider'
    [System.Byte[]]$encryptedDataBytes = $aes.IV + ($encryptionObject.TransformFinalBlock($dataBytes,0,$dataBytes.Length))

    $aes.Dispose()

    return [System.Convert]::ToBase64String($encryptedDataBytes)
}
