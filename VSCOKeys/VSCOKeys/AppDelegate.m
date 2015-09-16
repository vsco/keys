//
//  AppDelegate.m
//  VSCOKeys
//
//  Created by Sean Gubelman on 6/25/12.
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

#import "AppDelegate.h"
#import "KeyControl.h"
#import "MainWindowController.h"
#include <libkern/OSAtomic.h>
#include <execinfo.h>
#include <ExceptionHandling/ExceptionHandling.h>
#import <CoreServices/CoreServices.h>

@implementation AppDelegate

@synthesize window = _window;

@synthesize keyControl;
@synthesize mainController;
@synthesize quitTimer;

NSString * const UncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";

volatile int32_t UncaughtExceptionCount = 0;
const int32_t UncaughtExceptionMaximum = 10;

NSString *traceFilePath = NULL;

void uncaughtExceptionHandler(NSException *exception)
{
    DualLog(@"CRASH: %@", exception);

    NSArray *callstack = [NSThread callStackSymbols];

    DualLog(@"Stack Trace: %@", callstack);

    NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

    if (dirs && dirs.count >= 1)
    {
        NSFileManager *fileMan = [NSFileManager defaultManager];
        NSString *logDir = [((NSString *)[dirs objectAtIndex:0]) stringByAppendingPathComponent:@"VSCOKeysLogs"];

        if (![fileMan fileExistsAtPath:logDir])
        {
            [fileMan createDirectoryAtPath:logDir withIntermediateDirectories:YES attributes:nil error:nil];
        }

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-M-d-HH-mm-ss"];

        NSString *filestamp = [dateFormatter stringFromDate:[NSDate date]];

        NSString *filePath = [logDir stringByAppendingPathComponent:[NSString stringWithFormat:@"VSCOKeysErrorLog_%@.log",filestamp]];

        NSMutableString *fileContents = [[NSMutableString alloc] init];

        [fileContents appendFormat:@"%@\n", [NSDate date]];
        [fileContents appendFormat:@"%@\n", [[NSHost currentHost] name]];
        [fileContents appendFormat:@"Exception: %@\n\n", exception];
        [fileContents appendFormat:@"%@\n\n", callstack];

        NSError *error;

        [fileContents writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];

        if (error)
        {
            DualLog(@"Error writing error log. %@", error);
        }

        NSString *alertString = @"%@\n\nThe crash has been logged to disk at:\n%@\n\nThe run log has been stored at:\n%@\n\nPlease send an email to support@visualsupply.co with the above files attached.";

        NSAlert *alert = [NSAlert alertWithMessageText:@"An Unhandled Exception Occurred" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:alertString, exception, filePath, traceFilePath];

        [alert runModal];
    }

    exit(0);
}

void SignalHandler(int signal)
{
	int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
	if (exceptionCount > UncaughtExceptionMaximum)
	{
		return;
	}

    uncaughtExceptionHandler([NSException
                              exceptionWithName: UncaughtExceptionHandlerSignalExceptionName
                              reason: [NSString stringWithFormat: NSLocalizedString(@"Signal %d was raised.", nil), signal]
                              userInfo: NULL]);
}

- (BOOL)exceptionHandler:(NSExceptionHandler *)sender shouldHandleException:(NSException *)exception mask:(unsigned long)aMask
{
    uncaughtExceptionHandler(exception);
    return YES;
}

void SetUpLogging()
{
    NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

    if (dirs && dirs.count >= 1)
    {
        NSFileManager *fileMan = [NSFileManager defaultManager];
        NSString *logDir = [((NSString *)[dirs objectAtIndex:0]) stringByAppendingPathComponent:@"VSCOKeysLogs"];

        if (![fileMan fileExistsAtPath:logDir])
        {
            [fileMan createDirectoryAtPath:logDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        else
        {
            // clean up existing logs
            NSArray *files = [fileMan contentsOfDirectoryAtPath:logDir error:NULL];

            NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:NO selector:@selector(localizedCompare:)];
            files = [files sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];

            int count = 0;
            for (NSString *file in files)
            {
                if ([file rangeOfString:@"RunTrace"].location != NSNotFound)
                {
                    count++;

                    if (count > RUNTRACE_MAX_FILE_COUNT)
                    {
                        [fileMan removeItemAtPath:[logDir stringByAppendingPathComponent:file] error:NULL];
                    }
                }
            }
        }

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-M-d-HH-mm-ss"];

        NSString *filestamp = [dateFormatter stringFromDate:[NSDate date]];

        traceFilePath = [logDir stringByAppendingPathComponent:[NSString stringWithFormat:@"VSCOKeysRunTrace_%@.log",filestamp]];

        [[NSFileManager defaultManager] createFileAtPath:traceFilePath contents:NULL attributes:NULL];
    }
}

void DualLog(NSString* format, ...)
{
    va_list argList;
    va_start(argList, format);
    NSString* formattedMessage = [[NSString alloc] initWithFormat: format arguments: argList];
    va_end(argList);
    NSLog(@"%@", formattedMessage);

    if (traceFilePath != NULL)
    {
        formattedMessage = [formattedMessage stringByAppendingString:@"\n"];
        NSFileHandle *myHandle = [NSFileHandle fileHandleForWritingAtPath:traceFilePath];
        [myHandle seekToEndOfFile];
        [myHandle writeData:[formattedMessage dataUsingEncoding:NSUTF8StringEncoding]];
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSExceptionHandler *handler = [NSExceptionHandler defaultExceptionHandler];
    [handler setExceptionHandlingMask:NSLogAndHandleEveryExceptionMask];
    [handler setDelegate:self];

    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
	signal(SIGABRT, SignalHandler);
	signal(SIGILL, SignalHandler);
	signal(SIGSEGV, SignalHandler);
	signal(SIGFPE, SignalHandler);
	signal(SIGBUS, SignalHandler);
	signal(SIGPIPE, SignalHandler);

    SetUpLogging();

    [self checkOSVersion];

    self.keyControl = [[KeyControl alloc] init];
    self.mainController.keyControl = self.keyControl;
    self.keyControl.mainController = self.mainController;

    [self checkTrusted];

    [NSThread detachNewThreadSelector:@selector(startUpEventLoop) toTarget:self.keyControl withObject:nil];
    [NSThread detachNewThreadSelector:@selector(startUpAXLoop) toTarget:self.keyControl withObject:nil];
    [NSThread detachNewThreadSelector:@selector(statusBarUpdateLoop) toTarget:self.keyControl withObject:nil];
    self.quitTimer = [NSTimer scheduledTimerWithTimeInterval:APP_RUNNING_UPDATE_RATE target:self selector:@selector(lrRunningCheckLoop) userInfo:NULL repeats:YES];

    [self.keyControl makeLRActive];
}

- (void)lrRunningCheckLoop
{
    @autoreleasepool
    {
        if (![self.keyControl isLRRunning])
        {
            DualLog(@"Application was terminated because LR was not running.");
            [self.keyControl quitApplication];
        }
    }
}

- (void)checkOSVersion
{
    SInt32 major, minor, bugfix;
    Gestalt(gestaltSystemVersionMajor, &major);
    Gestalt(gestaltSystemVersionMinor, &minor);
    Gestalt(gestaltSystemVersionBugFix, &bugfix);

    NSString *systemVersion = [NSString stringWithFormat:@"%d.%d.%d",
                               major, minor, bugfix];
    NSString *minSystemVersion = [NSString stringWithFormat:@"%d.%d.%d",
                               OS_VERSION_MIN_MAJOR, OS_VERSION_MIN_MINOR, OS_VERSION_MIN_BUGFIX];

    if (major < OS_VERSION_MIN_MAJOR ||
        (major == OS_VERSION_MIN_MAJOR && minor < OS_VERSION_MIN_MINOR) ||
        (major == OS_VERSION_MIN_MAJOR && minor == OS_VERSION_MIN_MINOR && bugfix < OS_VERSION_MIN_BUGFIX))
    {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Operating System Not Supported" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@ is not a supported operating system version. Minimum required version is %@", systemVersion, minSystemVersion];

        [alert runModal];

        exit(0);
    }
}

// Authorize Accessibility Client
- (void)checkTrusted
{
    if (!AXIsProcessTrusted() && !AXAPIEnabled())
    {
        // request permission to change settingz
        DualLog(@"process is not trusted");

        DualLog(@"Prompting for authentication.");

        AuthorizationRef auth;

        OSStatus junk = AuthorizationCreate(NULL, NULL, kAuthorizationFlagDefaults, &auth);
        assert(junk == noErr);

        [self restartToInitializePrivileges:auth];

        AuthorizationFree(auth, kAuthorizationFlagDestroyRights);
    }
}

- (void)restartToInitializePrivileges:(AuthorizationRef)auth
{
    FILE *communicationsPipe = NULL;

    char appPathArg[MAXPATHLEN];
    [[[NSBundle mainBundle] bundlePath] getCString:appPathArg maxLength:MAXPATHLEN encoding:[NSString defaultCStringEncoding]];

    char appExePathArg[MAXPATHLEN];
    [[[NSBundle mainBundle] executablePath] getCString:appExePathArg maxLength:MAXPATHLEN encoding:[NSString defaultCStringEncoding]];

    char pidString[MAXPATHLEN];
    [[NSString stringWithFormat:@"%d", [[NSProcessInfo processInfo] processIdentifier]] getCString:pidString maxLength:MAXPATHLEN encoding:[NSString defaultCStringEncoding]];


    char *args[] = { appPathArg, appExePathArg, pidString, NULL };
    char toolPathString[MAXPATHLEN];

    NSString* path = [[NSBundle mainBundle] pathForResource:@"VSCOKeysActivator" ofType:nil];

    [path getCString:toolPathString maxLength:MAXPATHLEN encoding:[NSString defaultCStringEncoding]];

    #pragma GCC diagnostic ignored "-Wdeprecated"
    OSStatus status = AuthorizationExecuteWithPrivileges (auth,
                                                          toolPathString, kAuthorizationFlagDefaults, args,
                                                          &communicationsPipe);
    #pragma GCC diagnostic pop

    if (status != noErr)
    {
        // auth failed
        DualLog(@"Authentication failed: %d", status);
    }

    [[NSApplication sharedApplication] terminate:nil];
}


#pragma mark File Handling Methods

- (IBAction)openFileManually:(id)sender;
{
    NSOpenPanel *openPanel  = [NSOpenPanel openPanel];
    NSArray *fileTypes = [NSArray arrayWithObjects:@"xml",nil];
    NSInteger result  = [openPanel runModalForDirectory:NSHomeDirectory() file:nil types:fileTypes ];
    if(result == NSOKButton){
        [self processFile:[openPanel filename]];
    }
}

- (BOOL)processFile:(NSString *)file
{
    [self.keyControl importKeyFile:file];

    return YES;
}

#pragma mark File Handling Delegate Methods

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
    return [self processFile:filename];
}


@end
