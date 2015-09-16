//
//  HttpRequest.h
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

typedef void (^RespondedBlock)(NSURLConnection *connection, NSURLResponse *response, NSData *data, NSString *mimeType);
typedef void (^FailedBlock)(NSURLConnection *connection, NSError *error);

@interface HttpRequest : NSObject<NSURLConnectionDelegate, NSConnectionDelegate>

@property (retain) NSURLResponse *response;
@property (retain) NSString *mimeType;
@property (retain) NSMutableData *data;

@property (copy) RespondedBlock responded;
@property (copy) FailedBlock failed;

+(void)sendRequestTo:(NSString*)endpoint withMethod:(NSString*)method contentType:(NSString *)contentType data:(NSData *)data responded:(RespondedBlock)respondedBlock failed:(FailedBlock)failedBlock;

+(void)sendPostTo:(NSString*)endpoint contentType:(NSString *)contentType data:(NSData *)data responded:(RespondedBlock)respondedBlock failed:(FailedBlock)failedBlock;

+(void)sendJsonTo:(NSString*)endpoint data:(NSDictionary *)json responded:(RespondedBlock)respondedBlock failed:(FailedBlock)failedBlock;

+(void)sendUrlEncodedTo:(NSString*)endpoint data:(NSDictionary *)queryParams responded:(RespondedBlock)respondedBlock failed:(FailedBlock)failedBlock;

+(void)sendGetTo:(NSString*)endpoint responded:(RespondedBlock)respondedBlock failed:(FailedBlock)failedBlock;

@end
