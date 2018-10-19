function New-Password
{
	[CmdletBinding()]
	param
    (
        [Parameter()]
        [System.Int32]
        $length = 16
	)

	$lowers = 'abcdefghiklmnprstuvwxyz'
	$uppers = 'ABCDEFGHKLMNPRSTUVWXYZ'
	$specials = '!@#%^&*()?.'
	$numbers = '1234567890'
	$all = $lowers + $uppers + $specials + $numbers 
	
	$password = ''
	
	#2 uppers
	$password += $uppers[(Get-Random -Maximum $uppers.length)]
	$password += $uppers[(Get-Random -Maximum $uppers.length)]
	#2 numbers
	$password += $numbers[(Get-Random -Maximum $numbers.length)]
	$password += $numbers[(Get-Random -Maximum $numbers.length)]
	#2 lowers
	$password += $lowers[(Get-Random -Maximum $lowers.length)]
	$password += $lowers[(Get-Random -Maximum $lowers.length)]
	#2 specials
	$password += $specials[(Get-Random -Maximum $specials.length)]
	$password += $specials[(Get-Random -Maximum $specials.length)]
	#fill the rest with random from all categories
	for ($n=1;$n -le ($length - 8); $n++ ){
		$password += $all[(Get-Random -Maximum $all.length)]
	}

	#mix it up
	$indices = Get-Random -inputobject (0.. ($length -1)) -Count ($length -1)
	$private:ofs=''
	return [System.String]$password[$indices]
}
