//
//  BackgroundedImageCell.m
//  VSCOKeys
//
//  Created by Sean Gubelman on 8/1/12.
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

#import "BackgroundedImageCell.h"

@implementation BackgroundedImageCell

@synthesize backgroundColor;

- (NSRect)titleRectForBounds:(NSRect)theRect
{
	NSRect newRect = [super drawingRectForBounds:theRect];

    // Get our ideal size
    NSSize size = [[self image] size];

    // Center that in the proposed rect
    float heightDelta = newRect.size.height - size.height;
    if (heightDelta > 0)
    {
        newRect.size.height -= heightDelta;
        newRect.origin.y += (heightDelta / 2);
    }

    float widthDelta = newRect.size.width - size.width;
    if (widthDelta > 0)
    {
        newRect.size.width -= widthDelta;
        newRect.origin.x += (widthDelta / 2);
    }

    return newRect;
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    NSRect titleRect = [self titleRectForBounds:cellFrame];

    [self.backgroundColor set];
    NSRectFill(cellFrame);

    [[self image] drawInRect:titleRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
}

@end
