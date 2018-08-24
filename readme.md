# pscredentialtools

PSCredentialTools provides methods for securly generating, storing and retrieving credentials and other sensitive data for use in PowerShell scripts and Desired State Configurations. Credentials can be saved to disk, encrypted with either a pre-shared-key or with a PKI certificate. Credentials can also be stored in Azure KeyVault as an Azure KeyVault Secret.

PSCredentialTools includes the following cmdlets
*   Export-PSCredential: encrypts and saves a PowerShell Credential object to file or to Azure KeyVault
*   Import-PSCredential: decrypts a previously saved Credential back into a PowerShell Credential object
*   New-PSCredential: creates new PowerShell credential object, with a random strong password, and saves it to an encrypted file or to Azure KeyVault
*   ConvertFrom-FIPSSecureString: Converts a PowerShell SecureString object into encypted text, using a pre-shared-key. It uses the FIPS compliant AES Crypto Provider.
*   ConvertTo-FIPSSecureString: Converts a previously encrypted SecureString with a pre-shared-key back into a PowerShell SecureString object.
*   ConvertFrom-PKISecureString: Converts a PowerShell SecureString object into encrypted text using a provided certificate's Public Key
*   ConvertTo-PKISecureString: Converts a previously encrypted SecureString back into a PowerShell SecureString object using the provided certificate's Private Key

- Export-PSCredential: encrypts and saves a PowerShell Credential object to file or to Azure KeyVault
- Import-PSCredential: decrypts a previously saved Credential back into a PowerShell Credential object
- New-PSCredential: creates new PowerShell credential object, with a random strong password, and saves it to an encrypted file or to Azure KeyVault
- ConvertFrom-FIPSSecureString: Converts a PowerShell SecureString object into encypted text, using a pre-shared-key. It uses the FIPS compliant AES Crypto Provider.
- ConvertTo-FIPSSecureString: Converts a previously encrypted SecureString with a pre-shared-key back into a PowerShell SecureString object.
- ConvertFrom-PKISecureString: Converts a PowerShell SecureString object into encrypted text using a provided certificate's Public Key
- ConvertTo-PKISecureString: Converts a previously encrypted SecureString back into a PowerShell SecureString object using the provided certificate's Private Key
