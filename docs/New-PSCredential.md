---
external help file:
Module Name: PSCredentialTools
online version:
schema: 2.0.0
---

# New-PSCredential

## SYNOPSIS
Create a new PowerShell Credential object with a random password.
Encrypts and saves the Credential object to file or to Azure KeyVault.

## SYNTAX

### CertFile
```
New-PSCredential [-Username] <String> [-Path] <String> [-CertificateFile] <String> [<CommonParameters>]
```

### CertificateThumbprint
```
New-PSCredential [-Username] <String> [-Path] <String> -Thumbprint <String> [-CertificateStore <String>]
 [<CommonParameters>]
```

### KeyVault
```
New-PSCredential [-Username] <String> -KeyVault <String> -SecretName <String> [<CommonParameters>]
```

### LocalKey
```
New-PSCredential [-Username] <String> [-Path] <String> -SecureKey <SecureString> [<CommonParameters>]
```

## DESCRIPTION
New-PSCredential is used to create a new  PowerShell Credential object \[System.Management.Automation.PSCredential\] with the provided username and
a strong random password.
The resulting credential object is returned as well as saved to disk or to Azure KeyVault so that it can be retrieved later.
When saving to disk, the password is encrypted with either a pre-shared key or PKI certificate.

## EXAMPLES

### EXAMPLE 1
```
$Credential = New-PSCredential -Username 'svc.SharePoint.farm' -Path ./savedcredential.json -Thumbprint '87BB70A19A7671D389F49AF4C9608B2F381FDD80'
```

New-ADUser -Name $Credential.Username -AccountPassword $Credential.Password -Enabled:$true

Creating a credential to be used as a service account, and creating the account.

## PARAMETERS

### -Username
Username to use for the Credential to be created.

```yaml
Type: String
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
