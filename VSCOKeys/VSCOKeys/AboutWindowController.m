//
//  AboutWindowController.m
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

#import "AboutWindowController.h"
#import "KeyControl.h"
#import "NSButton+TextColor.h"

@interface AboutWindowController ()

@end

@implementation AboutWindowController

@synthesize keyControl;
@synthesize tf_version;
@synthesize btn_tos;
@synthesize btn_privacy;
@synthesize btn_support;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }

    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    self.keyControl.aboutWindow = self;

    [self.tf_version setStringValue:[NSString stringWithFormat:ABOUT_VERSION_FORMAT,VERSION_SKU,[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]]];

    [self.btn_tos setTitle:self.btn_tos.title withColor:[NSColor redColor] withUnderline:YES];
    [self.btn_privacy setTitle:self.btn_privacy.title withColor:[NSColor redColor] withUnderline:YES];
    [self.btn_support setTitle:self.btn_support.title withColor:[NSColor redColor] withUnderline:YES];
}

- (void)windowWillClose:(NSNotification *)notification
{
    [self.window setIsVisible:NO];
    [self.keyControl makeLRActive];

    self.keyControl.aboutWindow = nil;
}

- (IBAction)tosClicked:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:WEB_TERMS_OF_SERVICE]];
}

- (IBAction)privacyClicked:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:WEB_PRIVACY_POLICY]];
}

- (IBAction)supportClicked:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:WEB_SUPPORT]];
}
@end
