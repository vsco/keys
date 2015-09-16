//
//  QuickWindowController.m
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

#import "QuickWindowController.h"
#import "KeyControl.h"

#import "NSString+StringHeight.h"

#import "RSVerticallyCenteredTextFieldCell.h"

@interface QuickWindowController ()

@end

@implementation QuickWindowController

@synthesize keyControl;

@synthesize commandList1;
@synthesize commandList2;
@synthesize commandList3;

@synthesize tv_commands1;
@synthesize tv_commands2;
@synthesize tv_commands3;

@synthesize commandCell;
@synthesize adjustmentCell;
@synthesize amountCell;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
    }

    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    [self prepareCommands];
    [self sizeWindow];
}

- (void)windowWillClose:(NSNotification *)notification
{
    [self.window setIsVisible:NO];
    [self.keyControl makeLRActive];

    self.keyControl.quickWindow = nil;
}

- (void)awakeFromNib
{
    // commands table view
    self.commandCell = [[RSVerticallyCenteredTextFieldCell alloc] init];
    [self.commandCell setFont:[NSFont fontWithName:PROXIMA_FONT_NAME size:10]];
    [self.commandCell setEditable:NO];
    self.commandCell.padding = 2;

    [[self.tv_commands1 tableColumnWithIdentifier:VIEW_COMMAND_NAME] setDataCell:self.commandCell];
    [[self.tv_commands2 tableColumnWithIdentifier:VIEW_COMMAND_NAME] setDataCell:self.commandCell];
    [[self.tv_commands3 tableColumnWithIdentifier:VIEW_COMMAND_NAME] setDataCell:self.commandCell];


    self.adjustmentCell = [[RSVerticallyCenteredTextFieldCell alloc] init];
    [self.adjustmentCell setFont:[NSFont fontWithName:PROXIMA_FONT_NAME size:10]];
    [self.adjustmentCell setEditable:NO];
    self.adjustmentCell.padding = 2;

    [[self.tv_commands1 tableColumnWithIdentifier:VIEW_ADJUSTMENT_NAME] setDataCell:self.adjustmentCell];
    [[self.tv_commands2 tableColumnWithIdentifier:VIEW_ADJUSTMENT_NAME] setDataCell:self.adjustmentCell];
    [[self.tv_commands3 tableColumnWithIdentifier:VIEW_ADJUSTMENT_NAME] setDataCell:self.adjustmentCell];


    self.amountCell = [[RSVerticallyCenteredTextFieldCell alloc] init];
    [self.amountCell setFont:[NSFont fontWithName:PROXIMA_FONT_NAME size:10]];
    [self.amountCell setAlignment:NSCenterTextAlignment];
    [self.amountCell setEditable:NO];
    self.amountCell.padding = 2;

    [[self.tv_commands1 tableColumnWithIdentifier:VIEW_AMOUNT_NAME] setDataCell:self.amountCell];
    [[self.tv_commands2 tableColumnWithIdentifier:VIEW_AMOUNT_NAME] setDataCell:self.amountCell];
    [[self.tv_commands3 tableColumnWithIdentifier:VIEW_AMOUNT_NAME] setDataCell:self.amountCell];

    [self.tv_commands1 setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
    [self.tv_commands2 setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
    [self.tv_commands3 setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
}

- (void)addCommand:(NSDictionary *)keyCommand toList:(NSMutableArray *)array
{
    NSString *cmdString = [self.keyControl getCommandStringForCommand:keyCommand];

    NSDictionary *adjustments = [keyCommand objectForKey:KEYFILE_ADJUSTMENTS_NODENAME];

    NSMutableArray *normalizedAdjustmentNames = [NSMutableArray array];
    for (NSString *adj in [adjustments allKeys])
    {
        NSString *normalAdjustmentName = [self.keyControl getNormalNameForAdjustment:adj];

        if ([normalizedAdjustmentNames containsObject:normalAdjustmentName])
        {
            continue;
        }

        [normalizedAdjustmentNames addObject:normalAdjustmentName];

        NSAttributedString *attribString = [self.keyControl getAmountString:[adjustments valueForKey:adj] isRemap:([adj caseInsensitiveCompare:KEYFILE_ADJUSTMENT_REMAP_NODENAME] == NSOrderedSame)];

        [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                             cmdString, VIEW_COMMAND_NAME,
                             normalAdjustmentName, VIEW_ADJUSTMENT_NAME,
                             attribString, VIEW_AMOUNT_NAME,
                             nil]];
    }
}

- (void)prepareCommands
{
    NSMutableArray *newArray = [NSMutableArray array];

    NSDictionary *currentKeyfile = [self.keyControl.keyfileList valueForKey:self.keyControl.activeKeyFile];

    NSArray *keyArray = [currentKeyfile objectForKey:KEYFILE_KEYS_NODENAME];

    for (NSDictionary *keyCommand in keyArray)
    {
        [self addCommand:keyCommand toList:newArray];
    }

    int total = (int)[newArray count];
    int third = total / 3;
    int rest = (total - third - third);

    self.commandList1 = [newArray subarrayWithRange:(NSRange){0, third}];
    self.commandList2 = [newArray subarrayWithRange:(NSRange){third, third}];
    self.commandList3 = [newArray subarrayWithRange:(NSRange){third + third, rest}];
}

- (CGFloat)getDelta:(NSTableView *)table
{
    CGFloat clipHeight = ((NSClipView *)[table superview]).documentVisibleRect.size.height;

    CGFloat height = table.frame.size.height;

    return height - clipHeight;
}

- (void)sizeWindow
{
    CGFloat delta = [self getDelta:self.tv_commands1];

    delta = fmax(delta, [self getDelta:self.tv_commands2]);

    delta = fmax(delta, [self getDelta:self.tv_commands3]);

    if (delta > 0)
    {
        NSRect newWin = NSMakeRect(self.window.frame.origin.x, self.window.frame.origin.y, self.window.frame.size.width, self.window.frame.size.height + delta);
        newWin.origin.y -= delta / 2;

        [self.window setFrame:newWin display:YES];
    }
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    NSDictionary *rowKey = nil;

    if (tableView == self.tv_commands1)
    {
        rowKey = [self.commandList1 objectAtIndex:row];
    }

    if (tableView == self.tv_commands2)
    {
        rowKey = [self.commandList2 objectAtIndex:row];
    }

    if (tableView == self.tv_commands3)
    {
        rowKey = [self.commandList3 objectAtIndex:row];
    }

    if (!rowKey)
    {
        return 0;
    }

    CGFloat lastHeight = [(NSString *)[rowKey valueForKey:VIEW_COMMAND_NAME] heightForFont:self.commandCell.font andWidth:[[tableView tableColumnWithIdentifier:VIEW_COMMAND_NAME] width] - 2 * self.commandCell.padding];

    lastHeight = fmax(lastHeight, [(NSString *)[rowKey valueForKey:VIEW_ADJUSTMENT_NAME] heightForFont:self.adjustmentCell.font andWidth:[[tableView tableColumnWithIdentifier:VIEW_ADJUSTMENT_NAME] width] - 2 * self.adjustmentCell.padding]);

    lastHeight = fmax(lastHeight, [[(NSAttributedString *)[rowKey valueForKey:VIEW_AMOUNT_NAME] string] heightForFont:self.amountCell.font andWidth:[[tableView tableColumnWithIdentifier:VIEW_AMOUNT_NAME] width] - 2 * self.amountCell.padding]);

    return lastHeight + 2 * self.commandCell.padding;
}

- (IBAction)tableClicked:(id)sender
{
    [self.window close];
}
@end
