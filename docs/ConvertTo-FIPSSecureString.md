---
external help file:
Module Name: PSCredentialTools
online version:
schema: 2.0.0
---

# ConvertTo-FIPSSecureString

## SYNOPSIS
Converts a string of encrypted text back into a SecureString object with a FIPS compliant algorithm using a pre-shared key.
The Pre-Shared key can be provided as either a 32 byte array or a SecureString value.

## SYNTAX

### SecureKey
```
ConvertTo-FIPSSecureString [-EncryptedString] <String> -SecureKey <SecureString> [<CommonParameters>]
```

### KeyByte
```
ConvertTo-FIPSSecureString [-EncryptedString] <String> -Key <Byte[]> [<CommonParameters>]
```

## DESCRIPTION
{{Fill in the Description}}

## EXAMPLES

### EXAMPLE 1
```
$EncryptedText = Get-Content ./encryptedText.txt
```

$MySecret = ConvertTo-FIPSSecureString -EncryptedString $EncryptedText -SecureKey ( ConvertTo-SecureString -String 'Pr3$haredK3y' -AsPlainText -Force )

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

### -Key
An array of 32 bytes that will be used as a the pre-shared key for decryption.

```yaml
Type: Byte[]
Parameter Sets: KeyByte
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SecureKey
A SecureString that will be converted into a 32 byte array used as the pre-shared key for decryption.

```yaml
Type: SecureString
Parameter Sets: SecureKey
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
