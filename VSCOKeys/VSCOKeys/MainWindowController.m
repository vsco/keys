//
//  MainWindowController.m
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

#import "MainWindowController.h"
#import <math.h>

#import "KeyControl.h"

#import "RSVerticallyCenteredTextFieldCell.h"
#import "BackgroundedImageCell.h"
#import "RowColumnTableView.h"
#import "FlatButton.h"

#import "NSColor+FromHex.h"
#import "NSButton+TextColor.h"
#import "NSString+StringHeight.h"

@interface MainWindowController ()

@end

@implementation MainWindowController

@synthesize keyControl;

@synthesize initialLocation;
@synthesize tabv_tabs;
@synthesize tv_commands;
@synthesize tv_files;

@synthesize keyfileList;

@synthesize selectedKeyfile;
@synthesize selectedKeys;

@synthesize commandCell;
@synthesize adjustmentCell;
@synthesize amountCell;
@synthesize filenameCell;

@synthesize searchfield;
@synthesize listButton;
@synthesize addButton;

@synthesize viewButtonLeftAlign;
@synthesize viewBackButton;
@synthesize viewActivateButton;
@synthesize viewPdfButton;
@synthesize viewCustomizeButton;
@synthesize listDeleteName;
@synthesize listDeleteBox;
@synthesize listDeleteOk;
@synthesize listDeleteCancel;
@synthesize listDeleteQuestion;

@synthesize downloadTimer;
@synthesize downloadTimerCurrent;

#pragma mark Window delegate Callbacks

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self)
    {
        // not implemented
    }

    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    self.initialLocation = NSMakePoint(-1, -1);
}

- (void)windowWillClose:(NSNotification *)notification
{
    [self.window setIsVisible:NO];
    [self.keyControl makeLRActive];
}


#pragma mark Keyfile View Table Prep

- (void)prepareSelectedKeys
{
    NSMutableArray *newArray = [NSMutableArray array];

    for (NSDictionary *keyCommand in [self.selectedKeyfile objectForKey:KEYFILE_KEYS_NODENAME])
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

            [newArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                 cmdString, VIEW_COMMAND_NAME,
                                 normalAdjustmentName, VIEW_ADJUSTMENT_NAME,
                                 attribString, VIEW_AMOUNT_NAME,
                                 nil]];
        }
    }

    self.selectedKeys = newArray;
}

- (void)prepareCommandTableForContent
{
//
//    [self.tv_commands setRowHeight:50.0];
//
//    [self.tv_commands sizeToFit];
}


#pragma mark Table View Callbacks

- (void)awakeFromNib
{
    // topbar items
    self.listButton.hoverImage = [NSImage imageNamed:@"List_Hover.png"];
    self.addButton.hoverImage = [NSImage imageNamed:@"Add_Hover.png"];

    self.addButton.isSelected = true;

    // view file buttons
    NSMutableParagraphStyle *para = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [para setHeadIndent:50];
    [para setFirstLineHeadIndent:50];
    [para setAlignment:NSLeftTextAlignment];

    NSDictionary *leftAlignAttribs = [NSDictionary dictionaryWithObjectsAndKeys:
                                      para, NSParagraphStyleAttributeName,
                                      [NSColor whiteColor], NSForegroundColorAttributeName,
                                      [NSFont fontWithName:PROXIMA_FONT_NAME size:11], NSFontAttributeName,
                                      nil];

    [[self.viewBackButton cell] setBackgroundColor:[NSColor colorWithCalibratedHue:0 saturation:0 brightness:0.13 alpha:1]];
    [self.viewBackButton setAttributedTitle:[[NSAttributedString alloc] initWithString:self.viewBackButton.title attributes:leftAlignAttribs]];

    NSMutableParagraphStyle *para1 = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [para1 setHeadIndent:16];
    [para1 setFirstLineHeadIndent:16];
    [para1 setAlignment:NSLeftTextAlignment];

    self.viewButtonLeftAlign = [NSDictionary dictionaryWithObjectsAndKeys:
                                      para1, NSParagraphStyleAttributeName,
                                      [NSColor blackColor], NSForegroundColorAttributeName,
                                      [NSFont fontWithName:PROXIMA_FONT_NAME size:13], NSFontAttributeName,
                                      nil];

    [[self.viewActivateButton cell] setBackgroundColor:[NSColor colorWithCalibratedHue:0 saturation:0 brightness:1 alpha:1]];
    [self.viewActivateButton setAttributedTitle:[[NSAttributedString alloc] initWithString:self.viewActivateButton.title attributes:self.viewButtonLeftAlign]];
    [[self.viewPdfButton cell] setBackgroundColor:[NSColor colorWithCalibratedHue:0 saturation:0 brightness:1 alpha:1]];
    [self.viewPdfButton setAttributedTitle:[[NSAttributedString alloc] initWithString:self.viewPdfButton.title attributes:self.viewButtonLeftAlign]];
    [[self.viewCustomizeButton cell] setBackgroundColor:[NSColor colorWithCalibratedHue:0 saturation:0 brightness:1 alpha:1]];
    [self.viewCustomizeButton setAttributedTitle:[[NSAttributedString alloc] initWithString:self.viewCustomizeButton.title attributes:self.viewButtonLeftAlign]];

    // commands table view
    self.commandCell = [[RSVerticallyCenteredTextFieldCell alloc] init];
    [self.commandCell setFont:[NSFont fontWithName:@"Courier New" size:11]];
    [self.commandCell setBackgroundColor:[NSColor colorWithCalibratedWhite:0.98 alpha:1]];
    [self.commandCell setDrawsBackground:YES];
    [self.commandCell setEditable:NO];

    [[self.tv_commands tableColumnWithIdentifier:VIEW_COMMAND_NAME] setDataCell:self.commandCell];


    self.adjustmentCell = [[RSVerticallyCenteredTextFieldCell alloc] init];
    [self.adjustmentCell setFont:[NSFont fontWithName:PROXIMA_FONT_NAME size:10]];
    [self.adjustmentCell setBackgroundColor:[NSColor colorWithCalibratedWhite:0.95 alpha:1]];
    [self.adjustmentCell setDrawsBackground:YES];
    [self.adjustmentCell setEditable:NO];

    [[self.tv_commands tableColumnWithIdentifier:VIEW_ADJUSTMENT_NAME] setDataCell:self.adjustmentCell];


    self.amountCell = [[RSVerticallyCenteredTextFieldCell alloc] init];
    [self.amountCell setFont:[NSFont fontWithName:PROXIMA_FONT_NAME size:11]];
    [self.amountCell setAlignment:NSCenterTextAlignment];
    [self.amountCell setBackgroundColor:[NSColor colorWithCalibratedWhite:0.90 alpha:1]];
    [self.amountCell setDrawsBackground:YES];
    [self.amountCell setEditable:NO];

    [[self.tv_commands tableColumnWithIdentifier:VIEW_AMOUNT_NAME] setDataCell:self.amountCell];

    [self.tv_commands setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];

    // keyfiles table view

    BackgroundedImageCell *cell = [[BackgroundedImageCell alloc] init];
    [cell setBackgroundColor:[NSColor colorWithCalibratedWhite:1 alpha:1]];

    [[self.tv_files tableColumnWithIdentifier:DEFAULTS_KEYFILE_ISACTIVE] setDataCell:cell];

    self.filenameCell = [[RSVerticallyCenteredTextFieldCell alloc] init];
    [self.filenameCell setFont:[NSFont systemFontOfSize:14]];
    [self.filenameCell setBackgroundColor:[NSColor colorWithCalibratedWhite:1 alpha:1]];
    [self.filenameCell setDrawsBackground:YES];
    [self.filenameCell setEditable:NO];

    [[self.tv_files tableColumnWithIdentifier:KEYFILE_NAME_NODENAME] setDataCell:self.filenameCell];

    RSVerticallyCenteredTextFieldCell *tcell = [[RSVerticallyCenteredTextFieldCell alloc] init];
    [tcell setFont:[NSFont fontWithName:PROXIMA_FONT_NAME size:13]];
    [tcell setBackgroundColor:[NSColor colorWithCalibratedWhite:1 alpha:1]];
    [tcell setTextColor:[tcell backgroundColor]];
    [tcell setDrawsBackground:YES];
    [tcell setEditable:NO];
    [tcell setOffsetUp:3];

    [[self.tv_files tableColumnWithIdentifier:LIST_PDF_NAME] setDataCell:tcell];

    [[self.tv_files tableColumnWithIdentifier:LIST_DELETE_NAME] setDataCell:tcell];

    [self.tv_files setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];

    [[self.tv_files superview] setPostsFrameChangedNotifications:YES];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyfileListBoundsDidChange:) name:NSViewBoundsDidChangeNotification object:[self.tv_files superview]];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commandListBoundsDidChange:) name:NSViewBoundsDidChangeNotification object:[self.tv_commands superview]];

    // delete bar

    [self.listDeleteQuestion setFont:[NSFont fontWithName:PROXIMA_FONT_NAME size:13]];

    [self.listDeleteOk setFont:[NSFont fontWithName:PROXIMA_FONT_NAME size:13]];
    [self.listDeleteOk setTitle:self.listDeleteOk.title withColor:[NSColor whiteColor]];

    [self.listDeleteCancel setFont:[NSFont fontWithName:PROXIMA_FONT_NAME size:13]];
    [self.listDeleteCancel setTitle:self.listDeleteCancel.title withColor:[NSColor whiteColor]];
}

- (void)keyfileListBoundsDidChange:(NSNotification *)notification
{
    [self.listDeleteBox setHidden:TRUE];

    [self updateRowHeights:self.tv_files];
}

- (void)updateRowHeights:(NSTableView *)tableView
{
    NSRange visibleRows = [tableView rowsInRect:tableView.superview.bounds];
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0];
    [tableView noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndexesInRange:visibleRows]];
    [NSAnimationContext endGrouping];
}

- (void)commandListBoundsDidChange:(NSNotification *)notification
{
    [self updateRowHeights:self.tv_commands];
}

- (void)windowDidResize:(NSNotification *)notification
{
    [self updateRowHeights:self.tv_files];

    [self updateRowHeights:self.tv_commands];
}


- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    if (tableView == self.tv_commands)
    {
        NSDictionary *rowKey = [self.selectedKeys objectAtIndex:row];

        CGFloat lastHeight = [(NSString *)[rowKey valueForKey:VIEW_COMMAND_NAME] heightForFont:self.commandCell.font andWidth:[[self.tv_commands tableColumnWithIdentifier:VIEW_COMMAND_NAME] width] - 2 * VIEW_PADDING];

        lastHeight = fmax(lastHeight, [(NSString *)[rowKey valueForKey:VIEW_ADJUSTMENT_NAME] heightForFont:self.adjustmentCell.font andWidth:[[self.tv_commands tableColumnWithIdentifier:VIEW_ADJUSTMENT_NAME] width] - 2 * VIEW_PADDING]);

        lastHeight = fmax(lastHeight, [[(NSAttributedString *)[rowKey valueForKey:VIEW_AMOUNT_NAME] string] heightForFont:self.amountCell.font andWidth:[[self.tv_commands tableColumnWithIdentifier:VIEW_AMOUNT_NAME] width] - 2 * VIEW_PADDING]);

        return lastHeight + 2 * VIEW_PADDING;
    }
    else if (tableView == self.tv_files)
    {
        NSDictionary *rowKey = [self.keyfileList objectAtIndex:row];

        CGFloat lastHeight = [(NSString *)[rowKey valueForKey:KEYFILE_NAME_NODENAME] heightForFont:self.filenameCell.font andWidth:[[self.tv_files tableColumnWithIdentifier:KEYFILE_NAME_NODENAME] width] - 2 * VIEW_PADDING];

        return lastHeight + 2 * VIEW_PADDING;
    }

    return 10.0;
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    if (aTableView == tv_files)
    {
        RowColumnTableView *table = (RowColumnTableView *)aTableView;

        NSString *colId = [aTableColumn identifier];
        NSColor *black = [NSColor blackColor];
        NSColor *dark = [NSColor colorWithHex:0x343434];
        NSColor *white = [NSColor whiteColor];
        NSColor *text = dark;
        NSColor *background = white;

        if (table.mouseOverRow == rowIndex)
        {
            if ([colId caseInsensitiveCompare:LIST_PDF_NAME] == NSOrderedSame)
            {
                self.selectedKeyfile = [self.keyfileList objectAtIndex:rowIndex];
                if ([self getSelectedPdf] != nil)
                {
                    text = white;
                }
            }
            else
            {
                text = white;
            }

            background = dark;
        }
        else
        {
            text = black;

            if ([colId caseInsensitiveCompare:LIST_PDF_NAME] == NSOrderedSame ||
                [colId caseInsensitiveCompare:LIST_DELETE_NAME] == NSOrderedSame)
            {
                text = white;
            }
        }

        if ([aCell class] == [RSVerticallyCenteredTextFieldCell class])
        {
            [aCell setTextColor:text];
        }

        [aCell setBackgroundColor:background];
    }
}

#pragma mark View Keyfile Functionality

- (void)resetDownload
{
    self.downloadTimer = nil;
    self.downloadTimerCurrent = VIEW_DOWNLOAD_DURATION;
}

- (void)startDownloadProcess
{
    // download is in progress
    if (self.downloadTimer != nil)
    {
        return;
    }

    NSString *uuid = [self.selectedKeyfile valueForKey:KEYFILE_UUID_NODENAME];

    // TODO: show loading in button
    self.downloadTimer = [NSTimer scheduledTimerWithTimeInterval:VIEW_DOWNLOAD_UPDATE_RATE target:self selector:@selector(updatePDFButton) userInfo:nil repeats:YES];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSURL *webFile = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/%@",WEB_KEYS_ENDPOINT,uuid,WEB_KEYS_SHEET]];// test pdf @"http://www.awesomefilm.com/script/Big.pdf"];

        NSData *data = [NSData dataWithContentsOfURL:webFile];

        if (data == nil)
        {
            DualLog(@"No pdf exists at %@.", webFile);

            [self.downloadTimer invalidate];

            self.downloadTimer = nil;

            [self updatePDFButton];
            [self.viewPdfButton setAttributedTitle:[[NSAttributedString alloc] initWithString:VIEW_TITLE_DOWNLOAD_FAILED_PDF attributes:self.viewButtonLeftAlign]];
        }
        else
        {
            NSString *path = [[self.keyControl.keyfileDirectory stringByAppendingPathComponent:uuid] stringByAppendingPathExtension:KEYFILE_SHEET_EXTENSION];

            [data writeToFile:path atomically:YES];
        }
    });
}

- (NSString *)getSelectedPdf
{
    return [self.keyControl getPdfPath:[self.selectedKeyfile objectForKey:KEYFILE_UUID_NODENAME]];
}

- (void)updatePDFButton
{
    if ([self getSelectedPdf])
    {
        if (self.downloadTimer != nil)
        {
            [self.downloadTimer invalidate];

            self.downloadTimer = nil;
        }

        [self.viewPdfButton setAttributedTitle:[[NSAttributedString alloc] initWithString:VIEW_TITLE_VIEW_PDF attributes:self.viewButtonLeftAlign]];
    }
    else if (self.downloadTimer != nil)
    {
        // show progress
        float randomness = 0.7 + 0.6f * ((rand() % 100) / 100.0);
        self.downloadTimerCurrent -= VIEW_DOWNLOAD_UPDATE_RATE * randomness;

        float currPercent = 1 - (self.downloadTimerCurrent / VIEW_DOWNLOAD_DURATION);

        currPercent = round(currPercent * 100);
        currPercent = fminf(99, currPercent);

        [self.viewPdfButton setAttributedTitle:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"DOWNLOADING %d%%", (int)currPercent] attributes:self.viewButtonLeftAlign]];
    }
    else
    {
        // show download
        [self.viewPdfButton setAttributedTitle:[[NSAttributedString alloc] initWithString:VIEW_TITLE_DOWNLOAD_PDF attributes:self.viewButtonLeftAlign]];
    }
}

- (void)updateActivateButton
{
    NSMutableDictionary *attrib = [self.viewButtonLeftAlign mutableCopy];

    if ([[self.selectedKeyfile valueForKey:DEFAULTS_KEYFILE_ISACTIVE] boolValue])
    {
        [attrib setValue:[NSColor redColor] forKey:NSForegroundColorAttributeName];
        [self.viewActivateButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"DE-ACTIVATE" attributes:attrib]];
    }
    else
    {
        [attrib setValue:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
        [self.viewActivateButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"ACTIVATE" attributes:attrib]];
    }
}

- (void)toggleActivateSelected
{
    NSNumber *inverted = [NSNumber numberWithBool:![[selectedKeyfile valueForKey:DEFAULTS_KEYFILE_ISACTIVE] boolValue]];
    [selectedKeyfile setValue:inverted forKey:DEFAULTS_KEYFILE_ISACTIVE];

    [self.keyControl updateDefaults];
}

- (void)openDetailView
{
    [self.listDeleteBox setHidden:TRUE];

    [self resetDownload];

    [self updatePDFButton];
    [self updateActivateButton];

    [self prepareSelectedKeys];

    [self prepareCommandTableForContent];

    [tabv_tabs selectTabViewItemWithIdentifier:@"view"];

    [searchfield becomeFirstResponder];
}

- (void)showDeleteConfirm
{
    CGRect rect = [tv_files rectOfRow:tv_files.selectedRow];
    CGRect tvFrame = tv_files.visibleRect;
    CGRect tvSFrame = [tv_files superview].frame;
    rect.origin.x = tvSFrame.origin.x + rect.origin.x + tvFrame.origin.x;
    rect.origin.y = tvSFrame.origin.y + tvFrame.size.height - rect.size.height - rect.origin.y + tvFrame.origin.y;

//    [[self window] visualizeConstraints:[self.listDeleteBox constraints]];

    [self.listDeleteBox setHidden:FALSE];
    [self.listDeleteBox setFrame:rect];

    [self.listDeleteName setStringValue:[self.selectedKeyfile valueForKey:KEYFILE_NAME_NODENAME]];
}

- (void)deleteSelected
{
    [self.keyControl deleteKeyfile:self.selectedKeyfile];
    self.keyfileList = [self.keyControl getKeyfileList];
    [self.tv_files reloadData];

    [self.listDeleteBox setHidden:TRUE];
}

#pragma mark UI Event Callbacks

- (IBAction)createNewButtonClicked:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:CREATE_NEW_ENDPOINT]];
}

- (IBAction)listItemClicked:(id)sender
{
    RowColumnTableView *table = sender;

    NSInteger col = [table selectedCellColIndex];

    if ([table selectedRow] >= [self.keyfileList count])
    {
        return;
    }

    self.selectedKeyfile = [self.keyfileList objectAtIndex:[table selectedRow]];

    if (col == 0)
    {
        [self toggleActivateSelected];
    }
    else if (col == 1)
    {
        [self openDetailView];
    }
    else if (col == 2)
    {
        NSString *filePath = [self getSelectedPdf];

        if (filePath)
        {
            [[NSWorkspace sharedWorkspace] openFile:filePath];
        }
        else
        {
            [self openDetailView];
        }
    }
    else if (col == 3)
    {
        [self showDeleteConfirm];
    }
}

- (IBAction)listDeleteOkClicked:(id)sender
{
    [self deleteSelected];
}

- (IBAction)listDeleteCancelClicked:(id)sender
{
    [self.listDeleteBox setHidden:TRUE];
}

- (IBAction)listButtonPressed:(id)sender
{
    self.keyfileList = [self.keyControl getKeyfileList];

    [tabv_tabs selectTabViewItemWithIdentifier:@"list"];

    [self.listButton setImage:[NSImage imageNamed:@"List_Active.png"]];
    self.listButton.isSelected = true;
    [self.addButton setImage:[NSImage imageNamed:@"Add_Inactive.png"]];
    self.addButton.isSelected = false;
}

- (IBAction)addButtonPressed:(id)sender
{
    [tabv_tabs selectTabViewItemWithIdentifier:@"add"];
    [self.addButton setImage:[NSImage imageNamed:@"Add_Active.png"]];
    self.addButton.isSelected = true;
    [self.listButton setImage:[NSImage imageNamed:@"List_Inactive.png"]];
    self.listButton.isSelected = false;
}

- (IBAction)viewActivateButtonClicked:(id)sender
{
    [self toggleActivateSelected];
    [self updateActivateButton];
}

- (IBAction)viewPdfButtonClicked:(id)sender
{
    NSString *filePath = [self getSelectedPdf];

    if (filePath)
    {
        [[NSWorkspace sharedWorkspace] openFile:filePath];
    }
    else
    {
        [self startDownloadProcess];
    }
}

- (IBAction)viewCustomizeButtonClicked:(id)sender
{
    NSString *uuid = [self.selectedKeyfile valueForKey:KEYFILE_UUID_NODENAME];

    if (uuid)
    {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@/%@",WEB_KEYS_ENDPOINT,uuid,WEB_KEYS_CUSTOMIZE]]];
    }
}

- (IBAction)closeButtonPressed:(id)sender
{
    [self.window close];
}
@end
