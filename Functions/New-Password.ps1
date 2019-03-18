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

    [Reflection.Assembly]::LoadWithPartialName("System.Web") |out-null

    do
    {
        $password = [System.Web.Security.Membership]::GeneratePassword($length, 2)
        #GeneratePassword method, while likely to meet complexity requirements, is not guaranteed. Check for complexity and try again if needed

        $UpperTest = ([regex]::matches($password, "[A-Z]") | Measure-Object).Count -ge 2
        $LowerTest = ([regex]::matches($password, "[a-z]") | Measure-Object).Count -ge 2
        $NumberTest = ([regex]::matches($password, "[0-9]") | Measure-Object).Count -ge 2
        $SpecialsTest = ([regex]::matches($password, "[^a-zA-Z0-9]") | Measure-Object).Count -ge 2
    } until ($UpperTest -and $LowerTest -and $NumberTest -and $SpecialsTest)

    return $password
}
