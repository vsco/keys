//
//  KeyfileDescriptionTextTransformer.m
//  VSCOKeys
//
//  Created by Sean Gubelman on 7/24/12.
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

#import "KeyfileDescriptionTextTransformer.h"

@implementation KeyfileDescriptionTextTransformer

+ (Class)transformedValueClass
{
    return [NSAttributedString class];
}

- (id)transformedValue:(id)value
{

    if (value == nil) return nil;

    NSDictionary *dict = value;

    // contstruct styled string
    NSMutableAttributedString *outString = [[NSMutableAttributedString alloc] init];

    NSDictionary *nameAttr = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont boldSystemFontOfSize:24], NSFontAttributeName, nil];
    NSDictionary *authorAttr = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont boldSystemFontOfSize:12],NSFontAttributeName, nil];
    NSDictionary *descriptionAttr = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:10],NSFontAttributeName, nil];

    [outString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",[dict valueForKey:KEYFILE_NAME_NODENAME]] attributes:nameAttr]];

    [outString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\nBy %@\n",[dict valueForKey:KEYFILE_AUTHOR_NODENAME]] attributes:authorAttr]];

    [outString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@",[dict valueForKey:KEYFILE_DESCRIPTION_NODENAME]] attributes:descriptionAttr]];

    return outString;
}

@end
