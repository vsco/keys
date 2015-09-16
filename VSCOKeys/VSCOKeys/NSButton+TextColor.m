//
//  NSButton+TextColor.m
//  VSCOKeys
//
//  Created by Sean Gubelman on 8/2/12.
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

#import "NSButton+TextColor.h"

@implementation NSButton (TextColor)

- (void)setTitle:(NSString*)title withColor:(NSColor*)color;
{
    [self setTitle:title withColor:color withUnderline:NO];
}

- (void)setTitle:(NSString*)title withColor:(NSColor*)color withUnderline:(BOOL)underline;
{
    NSInteger underlineStyle = NSNoUnderlineStyle;
    if (underline)
    {
        underlineStyle = NSSingleUnderlineStyle;
    }

    NSMutableParagraphStyle *para = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [para setAlignment:[self alignment]];

    NSAttributedString *attributedString = [[NSAttributedString alloc]
                                            initWithString:title attributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                              color, NSForegroundColorAttributeName,
                                                                              [self font], NSFontAttributeName,
                                                                              para, NSParagraphStyleAttributeName,
                                                                              [NSNumber numberWithInt:(int)underlineStyle], NSUnderlineStyleAttributeName,
                                                                              nil]];

    [self setAttributedTitle: attributedString];
}

@end
