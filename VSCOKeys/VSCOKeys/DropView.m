//
//  DropView.m
//  VSCOKeys
//
//  Created by Sean Gubelman on 7/9/12.
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

#import "DropView.h"
#import "AppDelegate.h"

@implementation DropView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
    }

    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];

    if ( highlight ) {
        //highlight by overlaying a gray border
        [[NSColor grayColor] set];
        [NSBezierPath setDefaultLineWidth: 5];
        [NSBezierPath strokeRect: dirtyRect];
    }
}

#pragma mark - Destination Operations

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    NSURL *fileURL = [NSURL URLFromPasteboard: [sender draggingPasteboard]];
    NSString *filePath = [fileURL path];
    NSString *fileExt = [filePath pathExtension];

    // Check if the pasteboard contains image data and source/user wants it copied
    if (( [fileExt caseInsensitiveCompare:KEYFILE_VKEYS_EXTENSION] == NSOrderedSame &&
        [sender draggingSourceOperationMask] &
         NSDragOperationCopy ) ||
        ( [fileExt caseInsensitiveCompare:KEYFILE_JSON_EXTENSION] == NSOrderedSame &&
         [sender draggingSourceOperationMask] &
         NSDragOperationCopy )){

        //highlight our drop zone
        highlight=YES;

        [self setNeedsDisplay: YES];

        //accept data as a copy operation
        return NSDragOperationCopy;
    }

    return NSDragOperationNone;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
    //remove highlight of the drop zone
    highlight=NO;

    [self setNeedsDisplay: YES];
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    //finished with the drag so remove any highlighting
    highlight=NO;

    [self setNeedsDisplay: YES];

    //check to see if we can accept the data
    return true;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    if ( [sender draggingSource] != self ) {
        NSURL* fileURL;

//        DualLog(@"Drop %@", sender);

        //if the drag comes from a file
        fileURL=[NSURL URLFromPasteboard: [sender draggingPasteboard]];

        [(AppDelegate *)[[NSApplication sharedApplication] delegate] processFile:[fileURL path]];
    }

    return YES;
}


@end
