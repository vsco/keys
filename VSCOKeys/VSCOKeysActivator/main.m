//
//  main.m
//  VSCOKeysActivator
//
//  Created by Sean Gubelman on 6/29/12.
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

#import <CoreFoundation/CoreFoundation.h>
#import <ApplicationServices/ApplicationServices.h>
#import <Cocoa/Cocoa.h>

#pragma mark Main method

int main(int argc, const char * argv[])
{
    if (argc != 4)
    {
        return 1;
    }

    // wait until app is shutdown to relaunch
	pid_t parentPID = atoi(argv[3]);
	ProcessSerialNumber psn;
	while (GetProcessForPID(parentPID, &psn) != procNotFound)
		sleep(1);

    const char *appPathCString = argv[1];
    const char *appExePathCString = argv[2];
    NSString *appPath = [NSString stringWithCString:appPathCString encoding:NSUTF8StringEncoding];

    CFStringRef cfAppPath = CFStringCreateWithCString(NULL, appPathCString, kCFStringEncodingASCII);

    AXError error = AXMakeProcessTrusted(cfAppPath);

    CFRelease(cfAppPath);

    if (error != noErr)
    {
        NSLog(@"Error: could not make application trusted: %@", appPath);
        return 1;
    }

    CFStringRef cfAppExePath = CFStringCreateWithCString(NULL, appExePathCString, kCFStringEncodingASCII);

    error = AXMakeProcessTrusted(cfAppExePath);

    CFRelease(cfAppExePath);

    if (error != noErr)
    {
        NSLog(@"Error: could not make application trusted: %s", appExePathCString);
        return 1;
    }

    // relaunch app
    BOOL success = [[NSWorkspace sharedWorkspace] launchApplication:[appPath stringByExpandingTildeInPath]];

    if (!success)
    {
        NSLog(@"Error: could not relaunch application at %@", appPath);
    }

    return (success) ? 0 : 1;
}

