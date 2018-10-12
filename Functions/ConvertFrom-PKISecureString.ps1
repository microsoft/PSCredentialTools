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
        ConvertFrom-PKISecureString -SecureString $MySecretValue -Thumbprint '87BB70A19A7671D389F49AF4C9608B2F381FDD80' | Out-File ./encryptedText.txt

        Encrypts a SecureString object and saves it to disk.
#>
function ConvertFrom-PKISecureString
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True,Position=1,ValueFromPipeline=$True,ParameterSetName='Thumbprint')]
        [Parameter(Mandatory=$True,Position=1,ValueFromPipeline=$True,ParameterSetName='CertFile')]
        [ValidateNotNullOrEmpty()]
        [System.Security.SecureString]
        $SecureString,

        [Parameter(Mandatory=$true,ParameterSetName='Thumbprint')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Thumbprint,

        [Parameter(Mandatory=$True,ParameterSetName='CertFile')]
        [ValidateScript({test-path $_})]
        [System.String]
        $CertificateFile,

        [Parameter(Mandatory=$False,ParameterSetName='Thumbprint')]
        [ValidateSet('CurrentUser','LocalMachine')]
        [System.String]
        $CertificateStore
    )

    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
    $dataBytes = [System.Text.Encoding]::UTF8.GetBytes([Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr))
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)

    if ($PSCmdlet.ParameterSetName -eq 'CertFile')
    {
        $Certificate = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2($CertificateFile)
        if ($null -eq $Certificate.Thumbprint)
        {
            throw "$CertificateFile does not appear to be a valid x509 certificate file"
        }
    }
    else
    {
        if ($PSBoundParameters.ContainsKey('CertificateStore'))
        {
            $Certificate = Get-Item "Cert:\$CertificateStore\My\$Thumbprint" -ErrorAction SilentlyContinue
            #error checking
            if ($null -eq $Certificate.Thumbprint)
            {
                throw "Could not find a valid certificate in the $CertificateStore store with thumbprint $Thumbprint"
            }
        }
        else
        {
            #first look in CurrentUser
            $Certificate = Get-Item "Cert:\CurrentUser\My\$Thumbprint" -ErrorAction Silentlycontinue
            if ($null -eq $Certificate.Thumbprint)
            {
                #nothing in CurrentUser, try LocalMachine
                $Certificate = Get-Item "Cert:\LocalMachine\My\$Thumbprint" -ErrorAction Silentlycontinue
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

    return [System.Convert]::ToBase64String($EncryptedBytes)

}
