---
external help file:
Module Name: PSCredentialTools
online version:
schema: 2.0.0
---

# Export-PSCredential

## SYNOPSIS
Encrypts and saves a PowerShell Credential object to file or to Azure KeyVault

## SYNTAX

### CertFile
```
Export-PSCredential [-Credential] <PSCredential> [-Path] <String> [-CertificateFile] <String>
 [<CommonParameters>]
```

### CertificateThumbprint
```
Export-PSCredential [-Credential] <PSCredential> [-Path] <String> -Thumbprint <String>
 [-CertificateStore <String>] [<CommonParameters>]
```

### KeyVault
```
Export-PSCredential [-Credential] <PSCredential> -KeyVault <String> -SecretName <String> [<CommonParameters>]
```

### LocalKey
```
Export-PSCredential [-Credential] <PSCredential> [-Path] <String> -SecureKey <SecureString>
 [<CommonParameters>]
```

## DESCRIPTION
Export-PSCredential is used to save a PowerShell Credential object \[System.Management.Automation.PSCredential\] to disk
or to Azure KeyVault so that it can be retrieved later.
When saving to disk, the password is encrypted with either a pre-shared key
or a PKI certificate.

## EXAMPLES

### EXAMPLE 1
```
$Credential | Export-PSCredential -Path ./savedcredential.json -SecureKey ( Convertto-SecureString -String '$ecretK3y' -AsPlainText -Force)
```

Export a credential to file using a pre-shared key.

### EXAMPLE 2
```
$Credential | Export-PSCredential -Path ./savedcredential.json -Thumbprint '87BB70A19A7671D389F49AF4C9608B2F381FDD80'
```

Export a credential to file using a Certificate.

### EXAMPLE 3
```
$Credential | Export-PSCredential -KeyVault 'My-KeyVault' -SecretName 'SavedCred-Secret'
```

Export a credential to an existing Azure KeyVault.
The user executing the script must be authenticated to Azure with sufficient permissions to the KeyVault.

## PARAMETERS

### -Credential
The Credential object that will be exported.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Path
Path to the JSON file that will be created to save the encrypted credential.

```yaml
Type: String
Parameter Sets: CertFile, CertificateThumbprint, LocalKey
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SecureKey
A SecureString that is used as a Pre-Shared-Key for encrypting the credential password.

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
The ThumbPrint of a certificate on the local computer that will be used to encrypt the credential password.

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

### -CertificateFile
Path to a .CER certificate public key file that will be used to encrypt the credential password.

```yaml
Type: String
Parameter Sets: CertFile
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByValue)
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
The name of the Azure KeyVault that will be used to store the exported credential.

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
The name of the Azure KeyVault secret to create that will be used to store the exported credential.

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
