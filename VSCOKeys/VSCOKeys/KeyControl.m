//
//  KeyControl.m
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

#import "KeyControl.h"
#import "AppDelegate.h"

#import "SBJson.h"
#import "HttpRequest.h"

#import "AboutWindowController.h"
#import "QuickWindowController.h"
#import "MainWindowController.h"

#import "NSData+Cryption.h"
#import "NSString+UUID.h"
#import "NSString+Cryption.h"
#import "NSColor+FromHex.h"
#import "NSFileManager+DirectoryLocations.h"
#import "NSString+MD5.h"

@implementation KeyControl

@synthesize window;
@synthesize mainController;

@synthesize aboutWindow;
@synthesize quickWindow;
@synthesize licenseWindow;

@synthesize statusBar;
@synthesize statusBarIconActive;
@synthesize statusBarIconInactive;
@synthesize statusBarIconError;

@synthesize toggleMenuItem;

@synthesize activeKeyFile;

@synthesize keyThread;
@synthesize statusThread;

@synthesize authToken;
@synthesize authUUID;
@synthesize authTimestamp;
//@synthesize authSuccess;
@synthesize authContinueTrial;
@synthesize showQuickStart;

@synthesize keysDict;
@synthesize controlToggleKey;
@synthesize isServerAvailable;
@synthesize isKeyControlActive;
@synthesize eventTap;

@synthesize appIdList;
@synthesize lrVersion;

@synthesize keyfileList;

@synthesize keyMapping;
@synthesize adjustmentMapping;

@synthesize numFormatter;
@synthesize blackStyle;
@synthesize redStyle;
@synthesize goldStyle;

@synthesize keyfileDirectory;

@synthesize isInTextField;

- (id)init {
    self = [super init];
    if (self)
    {
        self.authContinueTrial = NO;

        self.keyfileDirectory = [[NSFileManager defaultManager] applicationSupportDirectory];

        [self copyBaseKeyfilesToDirectory];

        [self resetStatusMenu];

        [self initAppList];
        [self initMappings];

        self.lrVersion = [self getLRVersion];

        [self loadAllKeyfiles];

        self.statusBarIconActive = [NSImage imageNamed:@"StatusBarIcon_Active.png"];
        self.statusBarIconInactive = [NSImage imageNamed:@"StatusBarIcon_Inactive.png"];
        self.statusBarIconError = [NSImage imageNamed:@"StatusBarIcon_Error.png"];

        NSStatusBar *bar = [NSStatusBar systemStatusBar];

        statusBar = [bar statusItemWithLength:NSSquareStatusItemLength];

        [statusBar setImage:self.statusBarIconError];
        [statusBar setHighlightMode:YES];
        [self resetStatusMenu];

        self.numFormatter = [[NSNumberFormatter alloc] init];


        NSMutableParagraphStyle *centered = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [centered setAlignment:NSCenterTextAlignment];


        self.blackStyle = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSColor colorWithHex:0x000000], NSForegroundColorAttributeName,
                                    centered, NSParagraphStyleAttributeName,
                                    [NSFont fontWithName:PROXIMA_FONT_NAME size:11], NSFontAttributeName,
                                    nil];

        NSMutableDictionary *_redStyle = [blackStyle mutableCopy];
        [_redStyle setValue:[NSColor colorWithHex:0xff3300] forKey:NSForegroundColorAttributeName];
        self.redStyle = _redStyle;

        NSMutableDictionary *_goldStyle = [blackStyle mutableCopy];
        [_goldStyle setValue:[NSColor colorWithHex:0xa7a648] forKey:NSForegroundColorAttributeName];
        self.goldStyle = _goldStyle;
    }
    return self;
}



#pragma mark Server Connection


- (void)sendUpdate:(NSDictionary *)update
{
    self.isServerAvailable = false;

    [HttpRequest sendJsonTo:SERVER_UPDATE_ENDPOINT data:update
                  responded:^(NSURLConnection *connection, NSURLResponse *response, NSData *data, NSString *mimeType) {
                      DualLog(@"SendUpdate success: %@", update);
                      self.isServerAvailable = true;
                  }
                     failed:^(NSURLConnection *connection, NSError *error) {
                         DualLog(@"server connect failed with error: %@", error);
                         self.isServerAvailable = false;
                     }];
}


- (void)checkServerAvailability
{
    [self sendUpdate:[NSDictionary dictionary]];
}


#pragma mark Menu

- (void)showWindow
{
    [self.window setIsVisible:YES];

    [NSApp activateIgnoringOtherApps:YES];
    [self.window makeKeyAndOrderFront:nil];
}

- (void)showAbout
{
    if (self.aboutWindow == nil)
    {
        AboutWindowController *controller = [[AboutWindowController alloc] initWithWindowNibName:@"AboutWindow"];

        controller.keyControl = self;

        [controller.window display];
        self.aboutWindow = controller;
    }

    [NSApp activateIgnoringOtherApps:YES];
    [self.aboutWindow.window makeKeyAndOrderFront:nil];
}


- (void)quitApplication
{
    [[NSApplication sharedApplication] terminate:nil];
}

- (NSMenuItem *)addItem:(NSString *)title toMenu:(NSMenu *)menu target:(id)target selector:(SEL)selector object:(id)repObject
{
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title action:NULL keyEquivalent:@""];
    [item setTarget:target];
    [item setAction:selector];
    if (repObject != NULL)
    {
        [item setRepresentedObject:repObject];
    }

    [menu addItem:item];

    return item;
}

- (void)setMenuForKeyFileActive
{
    for (NSMenuItem *item in [[statusBar menu] itemArray])
    {
        NSString *obj = [item representedObject];

        if (obj != nil)
        {
            if ([obj compare:self.activeKeyFile] == NSOrderedSame)
            {
                [item setState:NSOnState];
            }
            else
            {
                [item setState:NSOffState];
            }
        }
    }
}

- (IBAction)selectedKeyFile:(id)sender
{
    self.activeKeyFile = [sender representedObject];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setValue:self.activeKeyFile forKey:DEFAULTS_ACTIVE_KEYFILE];

    [self setMenuForKeyFileActive];

    [self performSelector:@selector(loadDictionaryFromActiveKeysFile) onThread:self.keyThread withObject:NULL waitUntilDone:NO];
}

- (void)resetStatusMenu
{
    NSMenu *theMenu = [[NSMenu alloc] initWithTitle:@"main"];

    self.toggleMenuItem = [self addItem:STATUSMENUITEM_INACTIVE toMenu:theMenu target:self selector:@selector(toggleKeyControlActive) object:NULL];

    [self addItem:STATUSMENUITEM_PREFERENCES toMenu:theMenu target:self selector:@selector(showWindow) object:NULL];

    [theMenu addItem:[NSMenuItem separatorItem]];

    NSImage *onImage = [NSImage imageNamed:@"SelectedMenu.png"];

    for (NSString *key in [self getUUIDsSortedByName])
    {
        NSDictionary *keyfile = [self.keyfileList valueForKey:key];

        if (![[keyfile objectForKey:DEFAULTS_KEYFILE_ISACTIVE] boolValue])
        {
            continue;
        }

        NSString *name = [keyfile objectForKey:KEYFILE_NAME_NODENAME];

        NSMenuItem *menuItem = [self addItem:name toMenu:theMenu target:self selector:@selector(selectedKeyFile:) object:key];

        [menuItem setOnStateImage:onImage];
    }

    [theMenu addItem:[NSMenuItem separatorItem]];

    [self addItem:STATUSMENUITEM_ABOUT toMenu:theMenu target:self selector:@selector(showAbout) object:NULL];

    [self addItem:STATUSMENUITEM_QUIT toMenu:theMenu target:self selector:@selector(quitApplication) object:NULL];

    [self.statusBar setMenu:theMenu];

    [self setMenuForKeyFileActive];
}

- (void)statusBarUpdateLoop
{
    self.statusThread = [NSThread currentThread];

    self.isServerAvailable = NO;

    BOOL lastEngageState = ![self checkIsKeySystemEngaged];
    BOOL lastServerState = !self.isServerAvailable;

    while (true)
    {
        [self updateStatus:&lastEngageState server:&lastServerState];

        [NSThread sleepForTimeInterval:STATUSBAR_UPDATE_RATE];
    }
}

- (void)updateStatus:(BOOL *)lastEngageState server:(BOOL *)lastServerState
{
    @autoreleasepool
    {
        BOOL currEngageState = [self checkIsKeySystemEngaged];
        BOOL currServerState = self.isServerAvailable;
        BOOL changed = *lastEngageState != currEngageState || *lastServerState != currServerState;

        if (currEngageState)
        {
            if (changed)
            {
                [self.toggleMenuItem setTitle:STATUSMENUITEM_ACTIVE];
            }

            if (currServerState)
            {
                if (changed)
                {
                    [self.statusBar setImage:self.statusBarIconActive];
                }
            }
            else
            {
                if (changed)
                {
                    [self.statusBar setImage:self.statusBarIconError];
                    [self.toggleMenuItem setTitle:STATUSMENUITEM_ERROR];
                }
            }
        }
        else
        {
            if (changed)
            {
                [self.toggleMenuItem setTitle:STATUSMENUITEM_INACTIVE];
                [self.statusBar setImage:self.statusBarIconInactive];
            }
        }

        *lastEngageState = currEngageState;
        *lastServerState = currServerState;
    }
}

- (void)showQuickList
{
    NSString *pdfPath = [self getPdfPath:self.activeKeyFile];
    if (pdfPath != nil)
    {
        [[NSWorkspace sharedWorkspace] openFile:pdfPath];
    }
    else
    {
        [self.window display];

        self.mainController.selectedKeyfile = [self.keyfileList objectForKey:self.activeKeyFile];
        [self.mainController openDetailView];

        [NSApp activateIgnoringOtherApps:YES];
        [self.window makeKeyAndOrderFront:nil];
    }
}

- (void)dismissQuickList
{
    if (self.window != nil)
    {
        [self.window close];
    }
}

#pragma mark Importing

- (void)reportImportError:(NSString *)error
{
    NSAlert *alert = [NSAlert alertWithMessageText:IMPORT_KEYFILE_TITLE_ERROR defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", error];

    [alert runModal];
}

- (void)reportImportSuccess:(NSString *)filename
{
    NSAlert *alert = [NSAlert alertWithMessageText:IMPORT_KEYFILE_TITLE_SUCCESS defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:IMPORT_KEYFILE_SUCCESS,filename];

    [alert runModal];
}

- (void)importKeyFile:(NSString *)keyFilePath
{
    // copy file to resources
    NSError *error;

    NSString *fileName = [[keyFilePath stringByDeletingPathExtension] lastPathComponent];

    NSFileManager *fileManager = [NSFileManager defaultManager];

    // check for errors
    NSMutableDictionary *keyfileDict = [self decryptAndParseKeyfile:keyFilePath];

    if (![self verifyKeyfileFormat:keyfileDict filename:fileName])
    {
        [self reportImportError:IMPORT_KEYFILE_BAD_FORMAT];
        return;
    }

    NSString *vers = [keyfileDict valueForKey:KEYFILE_LRVERSION_NODENAME];
    if ([self.lrVersion caseInsensitiveCompare:vers] != NSOrderedSame)
    {
        [self reportImportError:[NSString stringWithFormat:IMPORT_KEYFILE_WRONG_VERSION, vers, self.lrVersion]];
        return;
    }

    NSString *layoutVersion = [keyfileDict valueForKey:KEYFILE_LAYOUTVERSION_NODENAME];
    if (layoutVersion)
    {
        NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        if ([appVersion caseInsensitiveCompare:layoutVersion] == NSOrderedAscending)
        {
            [self reportImportError:IMPORT_KEYFILE_NEWER_LAYOUT];
            return;
        }
    }

    NSString *uuid = [keyfileDict valueForKey:KEYFILE_UUID_NODENAME];
    NSString *name = [keyfileDict valueForKey:KEYFILE_NAME_NODENAME];

    NSString *toPathJSON = [[self.keyfileDirectory stringByAppendingPathComponent:uuid] stringByAppendingPathExtension:KEYFILE_JSON_EXTENSION];

    if ([fileManager fileExistsAtPath:toPathJSON])
    {
        if (![fileManager removeItemAtPath:toPathJSON error:NULL])
        {
            DualLog(@"Existing file couldn't be removed: %@", error);
            [self reportImportError:IMPORT_KEYFILE_SAME_NAME];
            return;
        }
    }

    NSString *toPathVKEYS = [[self.keyfileDirectory stringByAppendingPathComponent:uuid] stringByAppendingPathExtension:KEYFILE_VKEYS_EXTENSION];
    
    if ([fileManager fileExistsAtPath:toPathVKEYS])
    {
        if (![fileManager removeItemAtPath:toPathVKEYS error:NULL])
        {
            DualLog(@"Existing file couldn't be removed: %@", error);
            [self reportImportError:IMPORT_KEYFILE_SAME_NAME];
            return;
        }
    }

    if (![fileManager moveItemAtPath:keyFilePath toPath:toPathJSON error:&error])
    {
        DualLog(@"File could not be copied: %@", error);
        [self reportImportError:IMPORT_KEYFILE_SAME_NAME];
        return;
    }

    [self loadAllKeyfiles];
    [self loadDictionaryFromActiveKeysFile];
    [self resetStatusMenu];

    [self deletePdf:uuid];

    [self reportImportSuccess:name];
}

- (void)deleteKeyfile:(NSDictionary *)keyfile
{
    NSString *fileName = [keyfile valueForKey:KEYFILE_FILENAME_NODENAME];
    NSString *filePath = [self.keyfileDirectory stringByAppendingPathComponent:fileName];

    NSError *error;

    if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error])
    {
        DualLog(@"Error deleting file: %@", error);
    }

    [self loadAllKeyfiles];
    [self resetStatusMenu];
}

- (void)copyBaseKeyfilesToDirectory
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDirectoryEnumerator *dirEnum = [fm enumeratorAtPath:[[NSBundle mainBundle] resourcePath]];

    NSString *file;
    while (file = [dirEnum nextObject])
    {
        if (([[file pathExtension] isEqualToString: KEYFILE_VKEYS_EXTENSION]) ||
            ([[file pathExtension] isEqualToString: KEYFILE_JSON_EXTENSION]) )
        {
            NSString *fromFile = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:file];
            NSString *toFile = [self.keyfileDirectory stringByAppendingPathComponent:file];

            if ([fm fileExistsAtPath:toFile])
            {
                [fm removeItemAtPath:toFile error:NULL];
            }

            [fm copyItemAtPath:fromFile toPath:toFile error:NULL];
        }
    }
}

- (NSString *)getPdfPath:(NSString *)uuid
{
    if (uuid)
    {
        NSString *filePath = [[self.keyfileDirectory stringByAppendingPathComponent:uuid] stringByAppendingPathExtension:KEYFILE_SHEET_EXTENSION];

        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
        {
            return filePath;
        }
        else
        {
            return nil;
        }
    }

    return nil;
}

- (void)deletePdf:(NSString*)uuid
{
    NSString *path = [self getPdfPath:uuid];
    if (path)
    {
        [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
    }
}



#pragma mark Lightroom Integration

- (void)initAppList
{
    self.appIdList = [NSArray arrayWithObjects:LIGHTROOM_BUNDLE_LR3,LIGHTROOM_BUNDLE_LR4,LIGHTROOM_BUNDLE_LR5,LIGHTROOM_BUNDLE_LR6,LIGHTROOM_BUNDLE_LR7, nil];
}

- (NSRunningApplication*)getLRRunningInstance
{
    for (NSString *appid in self.appIdList)
    {
        NSArray *apps = [NSRunningApplication runningApplicationsWithBundleIdentifier:appid];

        if ([apps count] > 0)
        {
            return [apps objectAtIndex:0];
        }
    }

    return nil;
}

- (BOOL)checkIsLRInForeground
{
    NSRunningApplication *lr = [self getLRRunningInstance];

    if (lr != nil)
    {
        return lr.active;
    }

    return NO;
}

- (BOOL)isLRRunning
{
    return [self getLRRunningInstance] != nil;
}

- (void)makeLRActive
{
    for (NSWindow *win in [NSApp windows])
    {
        if (win.canBecomeKeyWindow && win.isVisible)
        {
            return;
        }
    }

    NSRunningApplication *lr = [self getLRRunningInstance];

    if (lr != nil)
    {
        [lr activateWithOptions:NSApplicationActivateAllWindows];
    }
}

- (NSString *)getLRVersion
{
    NSRunningApplication *lr = [self getLRRunningInstance];

    if ([lr.bundleIdentifier caseInsensitiveCompare:LIGHTROOM_BUNDLE_LR3] == NSOrderedSame)
    {
        return LRVERSION_LR3;
    }

    if ([lr.bundleIdentifier caseInsensitiveCompare:LIGHTROOM_BUNDLE_LR4] == NSOrderedSame ||
        [lr.bundleIdentifier caseInsensitiveCompare:LIGHTROOM_BUNDLE_LR5] == NSOrderedSame ||
        [lr.bundleIdentifier caseInsensitiveCompare:LIGHTROOM_BUNDLE_LR6] == NSOrderedSame ||
        [lr.bundleIdentifier caseInsensitiveCompare:LIGHTROOM_BUNDLE_LR7] == NSOrderedSame)
    {
        return LRVERSION_LR4;
    }

    return LRVERSION_UNKNOWN;
}

void AXCallback(AXObserverRef observer, AXUIElementRef element, CFStringRef notification, void *refcon)
{
    KeyControl *appSelf = (__bridge KeyControl *)refcon;

    CFTypeRef elementRole = NULL;
    AXUIElementCopyAttributeValue( element, kAXRoleAttribute, &elementRole );

    CFStringRef roleString = elementRole;

    if (
        roleString != NULL &&
        (
            CFStringCompare(roleString, kAXTextFieldRole, kCFCompareCaseInsensitive) == kCFCompareEqualTo ||
            CFStringCompare(roleString, kAXTextAreaRole, kCFCompareCaseInsensitive) == kCFCompareEqualTo
        )
       )
    {
        DualLog(@"Focus change to %@ -- deactivating keys.", roleString);
        appSelf.isInTextField = YES;
    }
    else if (appSelf.isInTextField)
    {
        DualLog(@"Focus change to %@ -- no longer in text field.", roleString);
        appSelf.isInTextField = NO;
    }
}

- (void)startUpAXLoop
{
    NSRunningApplication *lr = [self getLRRunningInstance];

    if (lr)
    {
        AXUIElementRef app = AXUIElementCreateApplication( lr.processIdentifier );

        AXObserverRef observer = NULL;

        AXError error = AXObserverCreate(lr.processIdentifier, AXCallback, &observer);

        if (error != kAXErrorSuccess)
        {
            DualLog(@"Error creating AXObserver %d", error);
            return;
        }

        error = AXObserverAddNotification(observer, app, kAXFocusedUIElementChangedNotification, (__bridge void *)self);

        if (error != kAXErrorSuccess)
        {
            DualLog(@"Error adding focuschange notification %d", error);
            return;
        }

        CFRunLoopAddSource(CFRunLoopGetCurrent(), AXObserverGetRunLoopSource(observer), kCFRunLoopDefaultMode);

        CFRunLoopRun();
    }
}

#pragma mark Keyfile List management

- (NSArray *)getKeyfileList
{
    NSArray * sortedKeys = [self getUUIDsSortedByName];

    return [self.keyfileList objectsForKeys:sortedKeys notFoundMarker:[NSNull null]];
}

- (NSMutableDictionary *)decryptAndParseKeyfile:(NSString *)filePath
{
    NSData *data = [NSData dataWithContentsOfFile:filePath];

    if( [[filePath pathExtension] isEqualToString:KEYFILE_VKEYS_EXTENSION] == YES )
        data = [data decrypt];

    NSString *content = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];

    return [content JSONValue];
}

- (BOOL)verifyKeyfileFormat:(NSDictionary *)settingsDict filename:(NSString *)file
{
    if (settingsDict == nil)
    {
        DualLog(@"Bad keyfile format for file: %@", file);

        return false;
    }

    if ([settingsDict objectForKey:KEYFILE_KEYS_NODENAME] == nil)
    {
        DualLog(@"Bad keyfile format: missing %@ for file: %@", KEYFILE_KEYS_NODENAME, file);

        return false;
    }

    if ([settingsDict objectForKey:KEYFILE_MODEKEY_NODENAME] == nil)
    {
        DualLog(@"Bad keyfile format: missing %@ for file: %@", KEYFILE_MODEKEY_NODENAME, file);

        return false;
    }

    if ([settingsDict objectForKey:KEYFILE_NAME_NODENAME] == nil)
    {
        DualLog(@"Bad keyfile format: missing %@ for file: %@", KEYFILE_NAME_NODENAME, file);

        return false;
    }

    if ([settingsDict objectForKey:KEYFILE_UUID_NODENAME] == nil)
    {
        DualLog(@"Bad keyfile format: missing %@ for file: %@", KEYFILE_UUID_NODENAME, file);

        return false;
    }

    id vers = [settingsDict objectForKey:KEYFILE_LRVERSION_NODENAME];
    if (vers == nil)
    {
        DualLog(@"Bad keyfile format: missing %@ for file: %@", KEYFILE_LRVERSION_NODENAME, file);

        return false;
    }

    if (![vers isKindOfClass:[NSString class]])
    {
        DualLog(@"Bad keyfile format: %@ is not a string in %@", KEYFILE_LRVERSION_NODENAME, file);

        return false;
    }

    return true;
}

- (void)loadAllKeyfiles
{
    self.keyfileList = [NSMutableDictionary dictionary];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:self.keyfileDirectory];

    NSString *file;
    while (file = [dirEnum nextObject])
    {
        if (([[file pathExtension] isEqualToString: KEYFILE_VKEYS_EXTENSION]) ||
            ([[file pathExtension] isEqualToString: KEYFILE_JSON_EXTENSION]) )
        {
            NSMutableDictionary *settingsDict = [self decryptAndParseKeyfile:[self.keyfileDirectory stringByAppendingPathComponent:file]];

            NSString *vers = [settingsDict objectForKey:KEYFILE_LRVERSION_NODENAME];
            if (![self verifyKeyfileFormat:settingsDict filename:file] || [self.lrVersion caseInsensitiveCompare:vers] != NSOrderedSame)
            {
                continue;
            }

            NSString *uuid = [settingsDict objectForKey:KEYFILE_UUID_NODENAME];

            NSString *defaultsKeyfileKey = [NSString stringWithFormat:DEFAULTS_KEYFILE_FORMAT, uuid];

            NSMutableDictionary *defaultsData = [[defaults valueForKey:defaultsKeyfileKey] mutableCopy];
            if (defaultsData == nil)
            {
                defaultsData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithBool:YES], DEFAULTS_KEYFILE_ISACTIVE,
                                nil];

                [defaults setValue:defaultsData forKey:defaultsKeyfileKey];
            }

            [defaultsData setValue:LIST_PDF forKey:LIST_PDF_NAME];
            [defaultsData setValue:LIST_DELETE forKey:LIST_DELETE_NAME];
            [defaultsData setValue:file forKey:KEYFILE_FILENAME_NODENAME];

            [settingsDict addEntriesFromDictionary:defaultsData];

            [self.keyfileList setObject:settingsDict forKey:uuid];
        }
    }

    [self initActiveKeyfile];
}

- (void)initActiveKeyfile
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSString *activeKeyfileDefault = [defaults valueForKey:DEFAULTS_ACTIVE_KEYFILE];

    if ([self.keyfileList valueForKey:activeKeyfileDefault] != nil && [[[self.keyfileList valueForKey:activeKeyfileDefault] valueForKey:DEFAULTS_KEYFILE_ISACTIVE] boolValue])
    {
        self.activeKeyFile = activeKeyfileDefault;
    }
    else if ([self.keyfileList count] > 0)
    {
        self.activeKeyFile = [[self getUUIDsSortedByName] objectAtIndex:0];
        [defaults setValue:self.activeKeyFile forKey:DEFAULTS_ACTIVE_KEYFILE];
    }

    [self setMenuForKeyFileActive];
}

- (NSArray *)getUUIDsSortedByName
{
    NSArray *sortedFiles =[[self.keyfileList allValues] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
                           {
                               NSDictionary *keyfile1 = (NSDictionary *)obj1;
                               NSDictionary *keyfile2 = (NSDictionary *)obj2;

                               return [[keyfile1 objectForKey:KEYFILE_NAME_NODENAME] compare:[keyfile2 objectForKey:KEYFILE_NAME_NODENAME]];
                           }];

    NSMutableArray *sortedUUIDs = [NSMutableArray array];

    for (NSDictionary *keyfile in sortedFiles)
    {
        [sortedUUIDs addObject:[keyfile objectForKey:KEYFILE_UUID_NODENAME]];
    }

    return sortedUUIDs;
}

- (CGEventFlags)convertModifiers:(int)mod
{
    CGEventFlags flags = 0;

    if (mod & kModifierShift)
    {
        flags |= kCGEventFlagMaskShift;
    }

    if (mod & kModifierControl)
    {
        flags |= kCGEventFlagMaskControl;
    }

    if (mod & kModifierOption)
    {
        flags |= kCGEventFlagMaskAlternate;
    }

    if (mod & kModifierCommand)
    {
        flags |= kCGEventFlagMaskCommand;
    }

    return flags;
}

- (void)loadDictionaryFromActiveKeysFile
{
    self.isKeyControlActive = false;

    NSDictionary *settingsDict = [self.keyfileList objectForKey:self.activeKeyFile];
    NSArray *keysDictionary = [settingsDict objectForKey:KEYFILE_KEYS_NODENAME];

    if (keysDictionary == nil)
    {
        self.keysDict = [NSDictionary dictionary];
        DualLog(@"Bad keyfile format: missing %@", KEYFILE_KEYS_NODENAME);
    }
    else
    {
        // convert the modifiers into mac modifiers
        NSMutableArray *newArr = [NSMutableArray arrayWithCapacity:[keysDictionary count]];

        for (int i = 0; i < [keysDictionary count]; ++i)
        {
            NSMutableDictionary *newDict = [[keysDictionary objectAtIndex:i] mutableCopy];

            [newDict setValue:[NSNumber numberWithUnsignedLongLong:[self convertModifiers:[[newDict objectForKey:KEYFILE_MODIFIERS_NODENAME] intValue]]] forKey:KEYFILE_MODIFIERS_NODENAME];

            NSMutableDictionary *adjustments = [[newDict objectForKey:KEYFILE_ADJUSTMENTS_NODENAME] mutableCopy];

            id remap = [adjustments objectForKey:KEYFILE_ADJUSTMENT_REMAP_NODENAME];

            if (remap)
            {
                NSNumber *key = NULL;
                NSNumber *mod = NULL;

                if ([remap isKindOfClass:[NSNumber class]] || [remap isKindOfClass:[NSString class]])
                {
                    key = [NSNumber numberWithInt:[remap intValue]];
                    mod = [NSNumber numberWithUnsignedLongLong:[self convertModifiers:0]];
                }
                else
                {
                    key = [remap objectForKey:KEYFILE_KEY_NODENAME];
                    mod = [NSNumber numberWithUnsignedLongLong:[self convertModifiers:[[remap objectForKey:KEYFILE_MODIFIERS_NODENAME] intValue]]];
                }

                [adjustments setObject:[NSDictionary dictionaryWithObjectsAndKeys:key,KEYFILE_KEY_NODENAME, mod,KEYFILE_MODIFIERS_NODENAME, nil] forKey:KEYFILE_ADJUSTMENT_REMAP_NODENAME];
                [newDict setObject:adjustments forKey:KEYFILE_ADJUSTMENTS_NODENAME];
            }

            [newArr addObject:newDict];
        }

        self.keysDict = newArr;
    }

    if ([settingsDict objectForKey:KEYFILE_MODEKEY_NODENAME] == nil)
    {
        self.controlToggleKey = 53;
        DualLog(@"Bad keyfile format: missing %@", KEYFILE_MODEKEY_NODENAME);
    }
    else
    {
        self.controlToggleKey = [[settingsDict objectForKey:KEYFILE_MODEKEY_NODENAME] intValue];
    }
}

- (void)initMappings
{
    self.keyMapping = [[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"KeyMapping" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil] JSONValue];

    self.adjustmentMapping = [[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AdjustmentMapping" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil] JSONValue];
}

- (NSString *)getKeynameForVirtual:(NSString *)virtKey
{
    return [self.keyMapping objectForKey:virtKey];
}

- (NSString *)getNormalNameForAdjustment:(NSString *)adjustment
{
    return [self.adjustmentMapping valueForKey:adjustment];
}

- (NSString *)getCommandStringForCommand:(NSDictionary *)command
{
    NSString *cmdString = @"";

    NSInteger mod = [[command valueForKey:KEYFILE_MODIFIERS_NODENAME] intValue];

    if (mod & kModifierShift)
        cmdString = [cmdString stringByAppendingString:@"SHIFT + "];

    if (mod & kModifierControl)
        cmdString = [cmdString stringByAppendingString:@"CONTROL + "];

    if (mod & kModifierOption)
        cmdString = [cmdString stringByAppendingString:@"OPTION + "];

    if (mod & kModifierCommand)
        cmdString = [cmdString stringByAppendingString:@"COMMAND + "];

    NSString *keyName = [self getKeynameForVirtual:[command valueForKey:KEYFILE_KEY_NODENAME]];

    if (keyName)
    {
        cmdString = [cmdString stringByAppendingString:keyName];
    }
    else
    {
        cmdString = [cmdString stringByAppendingString:@"?"];
    }

    return cmdString;
}

- (NSAttributedString *)getAmountString:(id)amount isRemap:(BOOL)isRemap
{
    NSString *stringValue = NULL;

    NSDictionary *attribs = self.blackStyle;

    if (isRemap)
    {
        if ([amount isKindOfClass:[NSString class]])
        {
            stringValue = [self getKeynameForVirtual:amount];
        }
        else
        {
            stringValue = [self getCommandStringForCommand:amount];
        }
    }
    else
    {
        NSNumber *numValue = [self.numFormatter numberFromString:amount];

        if (numValue != nil)
        {
            float floatVal = [numValue floatValue];
            stringValue = [NSString stringWithFormat:@"%+g", floatVal];

            attribs = self.goldStyle;

            if (floatVal < 0)
            {
                attribs = self.redStyle;
            }
        }
        else
        {
            stringValue = amount;
        }
    }

    return [[NSAttributedString alloc] initWithString:stringValue attributes:attribs];
}

- (void)updateDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    for (NSDictionary *keyfile in [self.keyfileList allValues])
    {
        NSString *uuid = [keyfile valueForKey:KEYFILE_UUID_NODENAME];
        NSString *defaultsKeyfileKey = [NSString stringWithFormat:DEFAULTS_KEYFILE_FORMAT, uuid];

        NSDictionary *defaultsData = [NSDictionary dictionaryWithObjectsAndKeys:
                        [keyfile valueForKey:DEFAULTS_KEYFILE_ISACTIVE], DEFAULTS_KEYFILE_ISACTIVE,
                        nil];

        [defaults setValue:defaultsData forKey:defaultsKeyfileKey];
    }

    [self resetStatusMenu];
    [self initActiveKeyfile];
}

#pragma mark Key Loop


- (BOOL)checkIsKeySystemEngaged
{
    return self.isKeyControlActive && [self checkIsLRInForeground] && !self.isInTextField;
}

- (void)toggleKeyControlActive
{
    self.isKeyControlActive = !self.isKeyControlActive;
    DualLog(@"KeyControl Active: %d", self.isKeyControlActive);

    [self checkServerAvailability];
}

NSString *GetModString(CGEventFlags modifiers)
{
    NSString *modString = @"";

    if (modifiers & kCGEventFlagMaskShift)
    {
        modString = [modString stringByAppendingString:@"SHIFT + "];
    }

    if (modifiers & kCGEventFlagMaskControl)
    {
        modString = [modString stringByAppendingString:@"CTRL + "];
    }

    if (modifiers & kCGEventFlagMaskAlternate)
    {
        modString = [modString stringByAppendingString:@"OPT + "];
    }

    if (modifiers & kCGEventFlagMaskCommand)
    {
        modString = [modString stringByAppendingString:@"CMD + "];
    }

    return modString;
}

void printKeyDebug(CGEventType type, CGEventFlags modifiers, int keyCode)
{
    NSString *modString = GetModString(modifiers);

    if (type == kCGEventKeyDown)
    {
        DualLog(@"Key Down: %@%d (%llx)", modString, keyCode, modifiers);
    }
    else
    {
        DualLog(@"Key Up: %@%d (%llx)", modString, keyCode, modifiers);
    }
}

CGEventRef myCGCreateEventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon)
{
    KeyControl *appSelf = (__bridge KeyControl *)refcon;

    // handle kill-event cases
    if (type == kCGEventTapDisabledByTimeout || type == kCGEventTapDisabledByUserInput)
    {
        CGEventTapEnable(appSelf.eventTap, YES);
        DualLog(@"Event Tap was disabled. Re-enable attempted.");

        return NULL;
    }

    int keyCode = (int)CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode);
    CGEventFlags modifiers = CGEventGetFlags(event);

    // Mode switch for app
    if ( !(modifiers & (kCGEventFlagMaskShift | kCGEventFlagMaskControl | kCGEventFlagMaskAlternate | kCGEventFlagMaskCommand)) && keyCode == appSelf.controlToggleKey && [appSelf checkIsLRInForeground])
    {
        if (type == kCGEventKeyDown)
        {
            [appSelf toggleKeyControlActive];
        }

        return NULL;
    }

    // show/hide quick keylist ( CMD + / )
    if (appSelf.isKeyControlActive && modifiers & kCGEventFlagMaskCommand && keyCode == 44)
    {
        if (type == kCGEventKeyUp)
        {
            if ([appSelf checkIsKeySystemEngaged])
            {
                [appSelf performSelectorOnMainThread:@selector(showQuickList) withObject:nil waitUntilDone:NO];
            }
            else
            {
                [appSelf performSelectorOnMainThread:@selector(dismissQuickList) withObject:nil waitUntilDone:NO];
            }
        }

        return NULL;
    }

    if ([appSelf checkIsKeySystemEngaged])
    {
        if (appSelf.keysDict)
        {
            // check if any key combos match
            for (int i = 0; i < [appSelf.keysDict count]; ++i)
            {
                NSDictionary *command = [appSelf.keysDict objectAtIndex:i];

                if (
                    keyCode == [[command objectForKey:KEYFILE_KEY_NODENAME] intValue] &&
                    (modifiers & (kCGEventFlagMaskShift | kCGEventFlagMaskControl | kCGEventFlagMaskAlternate | kCGEventFlagMaskCommand)) ==  [[command objectForKey:KEYFILE_MODIFIERS_NODENAME] unsignedLongLongValue]
                    )
                {
                    NSMutableDictionary *adjustments = [[command objectForKey:KEYFILE_ADJUSTMENTS_NODENAME] mutableCopy];

                    NSDictionary *remap = [adjustments objectForKey:KEYFILE_ADJUSTMENT_REMAP_NODENAME];

                    CGEventRef newEvent = NULL;

                    if (remap)
                    {
                        int newKey = [[remap objectForKey:KEYFILE_KEY_NODENAME] intValue];
                        CGEventFlags newMod = [[remap objectForKey:KEYFILE_MODIFIERS_NODENAME] unsignedLongLongValue];

                        newEvent = CGEventCreateKeyboardEvent(NULL, newKey, type == kCGEventKeyDown);
                        CGEventSetFlags(newEvent, newMod);

                        [adjustments removeObjectForKey:KEYFILE_ADJUSTMENT_REMAP_NODENAME];

                        NSString *modString = GetModString(newMod);
                        DualLog(@"Remapping key to %@%d", modString, newKey);
                    }

                    if (type == kCGEventKeyDown)
                    {
                        if (adjustments && [adjustments count] > 0)
                        {
                            [appSelf sendUpdate:adjustments];
                            DualLog(@"Key Command Executed");
                        }
                    }

                    return newEvent;
                }
            }
        }
    }

    return event;
}

// suppress false positive on event-tap create
#ifndef __clang_analyzer__

- (void)startUpEventLoop
{
    self.keyThread = [NSThread currentThread];

    // initialize keys dictionary
    [self loadDictionaryFromActiveKeysFile];

    CFRunLoopSourceRef runLoopSource;

    self.eventTap = CGEventTapCreate(kCGHIDEventTap, kCGHeadInsertEventTap, kCGEventTapOptionDefault, CGEventMaskBit(kCGEventKeyUp) | CGEventMaskBit(kCGEventKeyDown), myCGCreateEventCallback, (__bridge void *)self);

    if (!self.eventTap) {
        DualLog(@"Couldn't create event tap!");

        exit(0);
    }

    runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, self.eventTap, 0);

    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);

    CGEventTapEnable(self.eventTap, true);

    CFRunLoopRun();

    CFRelease(runLoopSource);
}

#endif


@end
