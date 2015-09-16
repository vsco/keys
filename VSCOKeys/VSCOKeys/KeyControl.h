//
//  KeyControl.h
//  VSCOKeys
//
//  Created by Sean Gubelman on 7/16/12.
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

#import <Foundation/Foundation.h>

@class AboutWindowController;
@class QuickWindowController;
@class LicenseWindowController;
@class MainWindowController;

@interface KeyControl : NSObject

@property (assign) IBOutlet NSWindow *window;
@property (retain) MainWindowController *mainController;

@property (retain) AboutWindowController *aboutWindow;
@property (retain) QuickWindowController *quickWindow;
@property (retain) LicenseWindowController *licenseWindow;

@property (retain) NSStatusItem *statusBar;
@property (retain) NSImage *statusBarIconActive;
@property (retain) NSImage *statusBarIconInactive;
@property (retain) NSImage *statusBarIconError;

@property (retain) NSMenuItem *toggleMenuItem;

@property (retain) NSString *activeKeyFile;

@property (retain) NSThread *keyThread;
@property (retain) NSThread *statusThread;

@property (retain) NSString *authToken;
@property (retain) NSString *authUUID;
@property (retain) NSString *authTimestamp;
@property (assign) BOOL authContinueTrial;
@property (assign) BOOL showQuickStart;

@property (retain) NSArray *keysDict;
@property (assign) int controlToggleKey;
@property (assign) BOOL isServerAvailable;
@property (assign) BOOL isKeyControlActive;
@property (assign) CFMachPortRef eventTap;

@property (retain) NSArray *appIdList;
@property (retain) NSString *lrVersion;

@property (retain) NSMutableDictionary *keyfileList;

@property (retain) NSDictionary *keyMapping;
@property (retain) NSDictionary *adjustmentMapping;

@property (retain) NSNumberFormatter *numFormatter;
@property (retain) NSDictionary *blackStyle;
@property (retain) NSDictionary *redStyle;
@property (retain) NSDictionary *goldStyle;

@property (retain) NSString *keyfileDirectory;

@property BOOL isInTextField;

- (void)importKeyFile:(NSString *)keyFileUrl;

- (void)quitApplication;

- (void)makeLRActive;
- (BOOL)isLRRunning;

- (NSArray *)getKeyfileList;

- (NSString *)getKeynameForVirtual:(NSString *)virtKey;
- (NSString *)getNormalNameForAdjustment:(NSString*)adjustment;
- (NSString *)getCommandStringForCommand:(NSDictionary *)command;
- (NSAttributedString *)getAmountString:(id)amount isRemap:(BOOL)isRemap;

- (NSString *)getPdfPath:(NSString *)uuid;

- (void)updateDefaults;
- (void)resetStatusMenu;

- (void)deleteKeyfile:(NSDictionary *)keyfile;

@end
