# Release Notes

## Unreleased

- Use .NET GeneratePassword method for random password generation instead of get-random
- Set and use aliases for Azure KeyVault commands based on the module available on the system
- Fixed typos in the module manifest.
- Split the functions into individual files for maintainability.
- Added comment based help to functions which did not have any.

## 1.0.1

- fix New-PSCredential returning more than the Credential object when using KeyVault storage

## 1.0

- Initial release of pscredentialtools
