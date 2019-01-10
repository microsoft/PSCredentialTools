# PSCredentialTools

PSCredentialTools provides methods for securely generating, storing and retrieving credentials and other sensitive data for use in PowerShell scripts and Desired State Configurations. Credentials can be saved to disk, encrypted with either a pre-shared-key or with a PKI certificate. Credentials can also be stored in Azure KeyVault as an Azure KeyVault Secret.

## List of cmdlets

PSCredentialTools includes the following cmdlets:

### PSCredentials cmdlets

* [Export-PSCredential](docs/Export-PSCredential.md): encrypts and saves a PowerShell Credential object to file or to Azure KeyVault
* [Import-PSCredential](docs/Import-PSCredential.md): decrypts a previously saved Credential back into a PowerShell Credential object
* [New-PSCredential](docs/New-PSCredential.md): creates new PowerShell credential object, with a random strong password, and saves it to an encrypted file or to Azure KeyVault

### Conversion cmdlets

* [ConvertFrom-FIPSSecureString](docs/ConvertFrom-FIPSSecureString.md): Converts a PowerShell SecureString object into encypted text, using a pre-shared-key. It uses the FIPS compliant AES Crypto Provider.
* [ConvertTo-FIPSSecureString](docs/ConvertTo-FIPSSecureString.md): Converts a previously encrypted SecureString with a pre-shared-key back into a PowerShell SecureString object.
* [ConvertFrom-PKISecureString](docs/ConvertFrom-PKISecureString.md): Converts a PowerShell SecureString object into encrypted text using a provided certificate's Public Key
* [ConvertTo-PKISecureString](docs/ConvertTo-PKISecureString.md): Converts a previously encrypted SecureString back into a PowerShell SecureString object using the provided certificate's Private Key

## Contributing

If you are interested in fixing issues and contributing directly to the code base, please see the document [contributing](contributing.md) guide.

## License

Licensed under the [MIT](LICENSE) License.