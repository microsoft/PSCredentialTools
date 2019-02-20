---
external help file:
Module Name: PSCredentialTools
online version:
schema: 2.0.0
---

# ConvertTo-PKISecureString

## SYNOPSIS
Converts a string of encrypted text back into a SecureString object with the private key of a PKI certificate.

## SYNTAX

```
ConvertTo-PKISecureString [-EncryptedString] <String> -Thumbprint <String> [-CertificateStore <String>]
 [<CommonParameters>]
```

## DESCRIPTION
{{Fill in the Description}}

## EXAMPLES

### EXAMPLE 1
```
$EncryptedText = Get-Content ./encryptedText.txt
```

$MySecretValue = ConvertTo-PKISecureString -EncryptedString $EncryptedValue -Thumbprint '87BB70A19A7671D389F49AF4C9608B2F381FDD80'

Reads an encrypted string from disk and decrypts it back into a SecureString.

## PARAMETERS

### -EncryptedString
The string of encrypted text to convert back into a SecureString object

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

### -Thumbprint
The ThumbPrint of a certificate on the local computer that will be used to decrypt the string.

```yaml
Type: String
Parameter Sets: (All)
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
Parameter Sets: (All)
Aliases:

Required: False
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
