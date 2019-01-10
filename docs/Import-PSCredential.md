---
external help file:
Module Name: PSCredentialTools
online version:
schema: 2.0.0
---

# Import-PSCredential

## SYNOPSIS
Retrieves and decrypts an exported PowerShell Credential from file or Azure KeyVault back into a PSCredential object.

## SYNTAX

### CertificateThumbprint
```
Import-PSCredential [-Path] <String> -Thumbprint <String> [-CertificateStore <String>] [<CommonParameters>]
```

### LocalKey
```
Import-PSCredential [-Path] <String> -SecureKey <SecureString> [<CommonParameters>]
```

### KeyVault
```
Import-PSCredential -KeyVault <String> -SecretName <String> [<CommonParameters>]
```

## DESCRIPTION
Import-PSCredential is used to retrieve a previously saved PowerShell Credential object from disk
or from Azure KeyVault and returns a PowerShell Credential object \[System.Management.Automation.PSCredential\] that can be used within scripts and
Desired State Configurations.
When retrieving from disk, the method used to encrypt the credential must be used to decrypt the credential.

## EXAMPLES

### EXAMPLE 1
```
$Credential = Import-PSCredential -Path ./savedcredential.json -SecureKey ( Convertto-SecureString -String '$ecretK3y' -AsPlainText -Force )
```

Import a credential from file using a pre-shared key.

### EXAMPLE 2
```
$Credential = Import-PSCredential -Path ./savedcredential.json -Thumbprint '87BB70A19A7671D389F49AF4C9608B2F381FDD80'
```

Import a credential from file using a Certificate.

### EXAMPLE 3
```
$Credential = Import-PSCredential -KeyVault 'My-KeyVault' -SecretName 'SavedCred-Secret'
```

Import a credential from an Azure KeyVault.
The user executing the script must be authenticated to Azure with sufficient permissions to the KeyVault.

## PARAMETERS

### -Path
Path to the JSON file that contains the encrypted credential.

```yaml
Type: String
Parameter Sets: CertificateThumbprint, LocalKey
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SecureKey
The SecureString that was used as a Pre-Shared-Key for encrypting the credential password.

```yaml
Type: SecureString
Parameter Sets: LocalKey
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Thumbprint
The Thumbprint of the certificate on the local computer that contains the private key of the certificate used to encrypt the credential password.

```yaml
Type: String
Parameter Sets: CertificateThumbprint
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CertificateStore
Specifies the certifcate store of the specified certificate thumbprint.
Either LocalMachine or CurrentUser.

```yaml
Type: String
Parameter Sets: CertificateThumbprint
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -KeyVault
The name of the Azure KeyVault that will that contains the exported credential secret.

```yaml
Type: String
Parameter Sets: KeyVault
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SecretName
The name of the Azure KeyVault secret that contains the exported credential.

```yaml
Type: String
Parameter Sets: KeyVault
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
