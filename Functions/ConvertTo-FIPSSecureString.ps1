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
function ConvertTo-FIPSSecureString
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True,Position=1,ValueFromPipeline=$true,ParameterSetName='KeyByte')]
        [Parameter(Mandatory=$True,Position=1,ValueFromPipeline=$true,ParameterSetName='SecureKey')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $EncryptedString,

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
        $key = Convert-SecureStringTo32ByteKey -SecureString $SecureKey
    }

    if ($null -eq $key -or $key.GetLength(0) -ne 32)
    {
        throw 'Key must be provided as a 32byte (256bit) byte array'
    }

    $dataBytes =  [System.Convert]::FromBase64String($EncryptedString)
    $iv = $dataBytes[0..15]

    $aes = New-Object -TypeName System.Security.Cryptography.AesCryptoServiceProvider
    $aes.Mode = [System.Security.Cryptography.CipherMode]::CBC
    $aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
    $aes.BlockSize = 128
    $aes.KeySize = 256
    $aes.Key = $Key
    $aes.IV = $iv

    $decryptionObject = $aes.CreateDecryptor()

    Write-Verbose -Message 'Converting AES encrypted string to SecureString'
    [System.Byte[]] $decryptedDataBytes =$decryptionObject.TransformFinalBlock($dataBytes,16,$dataBytes.Length -16)

    $aes.Dispose()

    return ( [System.Text.Encoding]::UTF8.GetString($decryptedDataBytes) | ConvertTo-SecureString -AsPlainText -Force )
}
