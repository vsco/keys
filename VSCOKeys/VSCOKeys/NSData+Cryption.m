//
//  NSData+Cryption.m
//  VSCOKeys
//
//  Created by Sean Gubelman on 7/16/12.
//
//  VSCO Keys for Adobe Lightroom
//  Copyright (C) 2015 Visual Supply Company
//  Licensed under GNU GPLv2 (or any later version).
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//

#import "NSData+Cryption.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonKeyDerivation.h>

@implementation NSData (Cryption)

- (NSData *)decrypt
{
    NSUInteger dataLength = [self length];
    uint8_t *unencryptedData = malloc(dataLength + kCCKeySizeAES128);
    size_t unencryptedLength;

    unencryptedData[0] = '\0';

    CCCryptorStatus status = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding, KEYFILE_AES_KEY, kCCKeySizeAES128, NULL, [self bytes], dataLength, unencryptedData, dataLength, &unencryptedLength);

    if (status != kCCSuccess)
    {
        DualLog(@"Error decrypting: %d", status);
        return NULL;
    }

    NSData *data = [NSData dataWithBytes:unencryptedData length:unencryptedLength];

    free(unencryptedData);

    return data;
}

@end
