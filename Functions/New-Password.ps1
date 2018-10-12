<#
	.SYNOPSIS
		Generates a new password.
	
	.DESCRIPTION
		Creates a new randomly generated password which adhears to strong password standards.
	
	.PARAMETER Length
		The number of characters the password will contain.
	
	.EXAMPLE
		New-Password
		R(9s?.rmX*Z45lP

	.Example
		New-Password -Length 24
		i7K#9*cKAPvi8a.yS&8U7W)
#>
function New-Password
{
	[CmdletBinding()]
	param
    (
        [Parameter()]
        [System.Int16]
        $Length = 16
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
	for ($n=1;$n -le ($Length - 8); $n++ ){
		$password += $all[(Get-Random -Maximum $all.length)]
	}

	#mix it up
	$indices = Get-Random -inputobject (0.. ($Length -1)) -Count ($Length -1)
	$private:ofs=''
	return [System.String]$password[$indices]
}
