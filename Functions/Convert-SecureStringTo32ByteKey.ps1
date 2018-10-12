function Convert-SecureStringto32ByteKey
{
	[CmdletBinding()]
	param
	(
        [Parameter(Mandatory=$true,ValueFromPipeline=$True,Position=1)]
        [ValidateNotNullOrEmpty()]
		[System.Security.SecureString]
		$SecureString
    )

    $hasher = New-Object -TypeName System.Security.Cryptography.SHA256CryptoServiceProvider

	try
	{
        $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
        $hasher.ComputeHash( [System.Text.Encoding]::UTF8.GetBytes([Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr))) 
    }
	catch
	{
        throw $_
	}
	finally
	{
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
        $hasher.Dispose()
    }
}
