//
//  QuickWindowController.h
//  VSCOKeys
//
//  Created by Sean Gubelman on 8/9/12.
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

#import <Cocoa/Cocoa.h>

@class KeyControl;
@class RSVerticallyCenteredTextFieldCell;

@interface QuickWindowController : NSWindowController

@property (retain) KeyControl *keyControl;

@property (retain) NSArray *commandList1;
@property (retain) NSArray *commandList2;
@property (retain) NSArray *commandList3;

@property (assign) IBOutlet NSTableView *tv_commands1;
@property (assign) IBOutlet NSTableView *tv_commands2;
@property (assign) IBOutlet NSTableView *tv_commands3;

@property (retain) RSVerticallyCenteredTextFieldCell *commandCell;
@property (retain) RSVerticallyCenteredTextFieldCell *adjustmentCell;
@property (retain) RSVerticallyCenteredTextFieldCell *amountCell;

- (IBAction)tableClicked:(id)sender;

@end
