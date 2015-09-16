//
//  MainWindowController.h
//  VSCOKeys
//
//  Created by Sean Gubelman on 7/23/12.
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
@class KeyfileListController;
@class RSVerticallyCenteredTextFieldCell;
@class FlatButton;

@interface MainWindowController : NSWindowController<NSTableViewDelegate, NSTextFieldDelegate>

@property (retain) KeyControl *keyControl;

@property (assign) NSPoint initialLocation;
@property (assign) IBOutlet NSTabView *tabv_tabs;
@property (assign) IBOutlet NSTableView *tv_commands;
@property (assign) IBOutlet NSTableView *tv_files;

@property (retain) NSArray *keyfileList;

@property (retain) NSMutableDictionary *selectedKeyfile;
@property (retain) NSArray *selectedKeys;

@property (retain) RSVerticallyCenteredTextFieldCell *commandCell;
@property (retain) RSVerticallyCenteredTextFieldCell *adjustmentCell;
@property (retain) RSVerticallyCenteredTextFieldCell *amountCell;
@property (retain) RSVerticallyCenteredTextFieldCell *filenameCell;
@property (assign) IBOutlet NSSearchField *searchfield;
@property (assign) IBOutlet FlatButton *listButton;
@property (assign) IBOutlet FlatButton *addButton;

@property (retain) NSDictionary *viewButtonLeftAlign;
@property (assign) IBOutlet NSButton *viewBackButton;
@property (assign) IBOutlet NSButton *viewActivateButton;
@property (assign) IBOutlet NSButton *viewPdfButton;
@property (assign) IBOutlet NSButton *viewCustomizeButton;
@property (assign) IBOutlet NSTextField *listDeleteName;
@property (assign) IBOutlet NSBox *listDeleteBox;
@property (assign) IBOutlet NSButton *listDeleteOk;
@property (assign) IBOutlet NSButton *listDeleteCancel;
@property (strong) IBOutlet NSTextField *listDeleteQuestion;

@property (retain) NSTimer *downloadTimer;
@property (assign) CGFloat downloadTimerCurrent;

- (IBAction)createNewButtonClicked:(id)sender;

- (IBAction)listItemClicked:(id)sender;
- (IBAction)listDeleteOkClicked:(id)sender;
- (IBAction)listDeleteCancelClicked:(id)sender;

- (IBAction)listButtonPressed:(id)sender;
- (IBAction)addButtonPressed:(id)sender;

- (void)openDetailView;

- (IBAction)viewActivateButtonClicked:(id)sender;
- (IBAction)viewPdfButtonClicked:(id)sender;
- (IBAction)viewCustomizeButtonClicked:(id)sender;


@end
