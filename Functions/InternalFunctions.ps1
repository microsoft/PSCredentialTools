function Convert-SecureStringto32ByteKey {
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,Position=1)]
        [ValidateNotNullOrEmpty()]
         [System.Security.SecureString]$SecureString
    )

    $hasher = New-Object System.Security.Cryptography.SHA256CryptoServiceProvider

    try {
        $BSTR = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
        $hasher.ComputeHash( [System.Text.Encoding]::UTF8.GetBytes([Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR))) 
    }
    catch {
        throw $_
    } finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
        $hasher.Dispose()
    }
}

Function New-Password {
	param (
		[int]$length = 16
	)

	$lowers = 'abcdefghiklmnprstuvwxyz'
	$uppers = 'ABCDEFGHKLMNPRSTUVWXYZ'
	$specials = '!@#%^&*()?.'
	$numbers = '1234567890'
	$all = $lowers + $uppers + $specials + $numbers 
	
	$password = ""
	
	#2 uppers
	$password += $uppers[(get-random -Maximum $uppers.length)]
	$password += $uppers[(get-random -Maximum $uppers.length)]
	#2 numbers
	$password += $numbers[(get-random -Maximum $numbers.length)]
	$password += $numbers[(get-random -Maximum $numbers.length)]
	#2 lowers
	$password += $lowers[(get-random -Maximum $lowers.length)]
	$password += $lowers[(get-random -Maximum $lowers.length)]
	#2 specials
	$password += $specials[(get-random -Maximum $specials.length)]
	$password += $specials[(get-random -Maximum $specials.length)]
	#fill the rest with random from all categories
	for ($n=1;$n -le ($length - 8); $n++ ){
		$password += $all[(get-random -Maximum $all.length)]
	}

	#mix it up
	$indices = get-random -inputobject (0.. ($length -1)) -Count ($length -1)
	$private:ofs=''
	return [String]$password[$indices]
}