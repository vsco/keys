//
//  FlatButton.m
//  VSCOKeys
//
//  Created by Sean Gubelman on 7/30/12.
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

#import "FlatButton.h"

@implementation FlatButton

@synthesize hoverColor;
@synthesize hoverImage;

@synthesize backgroundColor;

@synthesize isHovered;
@synthesize isSelected;
@synthesize trackingArea;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.isHovered = NO;
    }

    return self;
}

- (void)awakeFromNib
{
    [[self window] setAcceptsMouseMovedEvents: YES];

    [self myAddTrackingArea];
    self.hoverColor = [NSColor colorWithCalibratedWhite:0.5 alpha:0.5];
}

- (void)dealloc
{
    [self myRemoveTrackingArea];
}

- (void)drawRect:(NSRect)dirtyRect
{
    if (self.isTransparent)
    {
        return;
    }

    if (self.backgroundColor)
    {
        [self.backgroundColor set];
        NSRectFill(dirtyRect);
    }

    if (self.image)
    {
        [self.image drawInRect:[self bounds] fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1 respectFlipped:YES hints:nil];
    }
    else
    {
        [super drawRect:dirtyRect];
    }

    if (self.isHovered && !self.isSelected)
    {
        if (self.hoverImage != nil)
        {
            // draw hoverImage instead / over other image
            [self.hoverImage drawInRect:[self bounds] fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1 respectFlipped:YES hints:nil];
        }
        else if (self.hoverColor != nil)
        {
            [self.hoverColor set];
            NSRectFillUsingOperation(dirtyRect, NSCompositeSourceOver);
        }
    }
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    self.isHovered = YES;

    [self setNeedsDisplay];
}

- (void)mouseExited:(NSEvent *)theEvent
{
    self.isHovered = NO;

    [self setNeedsDisplay];
}

- (void)myRemoveTrackingArea
{
    if (self.trackingArea)
    {
        [self removeTrackingArea:self.trackingArea];
        self.trackingArea = nil;
    }
}

- (void)myAddTrackingArea
{
    [self myRemoveTrackingArea];

    self.trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds] options:NSTrackingMouseEnteredAndExited|NSTrackingMouseMoved|NSTrackingActiveInKeyWindow|NSTrackingInVisibleRect owner:self userInfo:nil];

    [self addTrackingArea:self.trackingArea];
}

- (void)resetCursorRects
{
    [super resetCursorRects];
    [self myAddTrackingArea];

    [self addCursorRect:[self bounds] cursor:[NSCursor pointingHandCursor]];
}

@end
