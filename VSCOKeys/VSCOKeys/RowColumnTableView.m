//
//  RowColumnTableView.m
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

#import "RowColumnTableView.h"

@implementation RowColumnTableView

@synthesize selectedCellRowIndex;
@synthesize selectedCellColIndex;

@synthesize trackingArea;
@synthesize mouseOverView;
@synthesize mouseOverRow;
@synthesize lastOverRow;

-(void)mouseDown:(NSEvent *)theEvent {
    NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    self.selectedCellColIndex = [self columnAtPoint:point];
    self.selectedCellRowIndex = [self rowAtPoint:point];

    [super mouseDown:theEvent];
}

- (void)awakeFromNib
{
    [[self window] setAcceptsMouseMovedEvents:YES];

    [self myAddTrackingArea];

    self.mouseOverView = NO;
    self.mouseOverRow = -1;
    self.lastOverRow = -1;
}

- (void)dealloc
{
    [self myRemoveTrackingArea];
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

- (void)mouseEntered:(NSEvent *)theEvent
{
    self.mouseOverView = YES;
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    id myDelegate = [self delegate];

    if (!myDelegate)
        return; // No delegate, no need to track the mouse.

    if (![myDelegate respondsToSelector:@selector(tableView:willDisplayCell:forTableColumn:row:)])
        return; // If the delegate doesn't modify the drawing, don't track.

    if (self.mouseOverView)
    {
        self.mouseOverRow = [self rowAtPoint:[self convertPoint:[theEvent locationInWindow] fromView:nil]];

        if (self.lastOverRow == self.mouseOverRow)
            return;
        else
        {
            [self setNeedsDisplayInRect:[self rectOfRow:self.lastOverRow]];
            self.lastOverRow = self.mouseOverRow;
        }

        [self setNeedsDisplayInRect:[self rectOfRow:self.mouseOverRow]];
    }
}

- (void)mouseExited:(NSEvent *)theEvent
{
    self.mouseOverView = NO;
    [self setNeedsDisplayInRect:[self rectOfRow:self.mouseOverRow]];
    self.mouseOverRow = -1;
    self.lastOverRow = -1;
}

- (void)resetCursorRects
{
    [super resetCursorRects];
    [self myAddTrackingArea];
}

@end
