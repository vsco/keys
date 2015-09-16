//
//  HttpRequest.m
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

#import "HttpRequest.h"
#import "NSObject+SBJson.h"
#import "NSDictionary+UrlEncoding.h"

@implementation HttpRequest

@synthesize response;
@synthesize mimeType;
@synthesize data;

@synthesize responded;
@synthesize failed;


+(void)sendRequestTo:(NSString*)endpoint withMethod:(NSString*)method contentType:(NSString *)contentType data:(NSData *)data responded:(RespondedBlock)respondedBlock failed:(FailedBlock)failedBlock
{
    HttpRequest *httpRequest = [[HttpRequest alloc] init];
    httpRequest.responded = respondedBlock;
    httpRequest.failed = failedBlock;

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                    initWithURL:[NSURL
                                                 URLWithString:endpoint]];

    [request setHTTPMethod:method];

    if (data != nil)
    {
        [request setValue:contentType forHTTPHeaderField:@"Content-Type"];

        [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[data length]] forHTTPHeaderField:@"Content-Length"];

        [request setHTTPBody:data];
    }

    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:httpRequest];
    [connection self]; // suppress warning about not using the connection object (it handles its own memory)
}


+(void)sendPostTo:(NSString*)endpoint contentType:(NSString *)contentType data:(NSData *)data responded:(RespondedBlock)respondedBlock failed:(FailedBlock)failedBlock
{
    [HttpRequest sendRequestTo:endpoint withMethod:@"POST" contentType:contentType data:data responded:respondedBlock failed:failedBlock];
}

+(void)sendJsonTo:(NSString*)endpoint data:(NSDictionary *)json responded:(RespondedBlock)respondedBlock failed:(FailedBlock)failedBlock
{
    NSData *data = [[json JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
    [HttpRequest sendRequestTo:endpoint withMethod:@"POST" contentType:@"application/json" data:data responded:respondedBlock failed:failedBlock];
}

+(void)sendUrlEncodedTo:(NSString*)endpoint data:(NSDictionary *)queryParams responded:(RespondedBlock)respondedBlock failed:(FailedBlock)failedBlock
{
    NSData *data = [[queryParams urlEncodedString] dataUsingEncoding:NSUTF8StringEncoding];
    [HttpRequest sendRequestTo:endpoint withMethod:@"POST" contentType:@"application/x-www-form-urlencoded" data:data responded:respondedBlock failed:failedBlock];
}

+(void)sendGetTo:(NSString*)endpoint responded:(RespondedBlock)respondedBlock failed:(FailedBlock)failedBlock
{
    [HttpRequest sendRequestTo:endpoint withMethod:@"GET" contentType:nil data:nil responded:respondedBlock failed:failedBlock];
}

#pragma mark Connection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)_response
{
    self.response = _response;
    self.mimeType = _response.MIMEType;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)_data
{
    if (self.data == nil)
    {
        self.data = [_data mutableCopy];
    }
    else
    {
        [self.data appendData:_data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.responded(connection, self.response, self.data, self.mimeType);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.failed(connection, error);
}


@end
