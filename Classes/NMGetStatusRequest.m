//
//  NMGetStatusRequest.m
//  NinetyMinutes
//
//  Created by Nebil on 19/02/11.
//  Copyright 2011 Nebil Kriedi. All rights reserved.
//

#import "NMGetStatusRequest.h"
#import "NMUser.h"
#import "NMStatusUpdate.h"

#import "ASIHTTPRequest+Signature.h"
#import "NMAuthenticationManager.h"


#import <CoreLocation/CoreLocation.h>


@implementation NMGetStatusRequest

@synthesize user = _user;


- (void)dealloc 
{
	self.user = nil;
	[super dealloc];
}


- (ASIHTTPRequest *)createMainRequest 
{
	NSString *path = [NSString stringWithFormat:@"/user/%@/status", self.user.facebookId];
	ASIHTTPRequest *updateRequest = [ASIHTTPRequest requestWithAPIPath:path
															parameters:nil 
															   rootURL:self.rootURL 
														  signWithUser:[[NMAuthenticationManager sharedManager] authenticatedUser]];
	
	return updateRequest;
}


- (id)createResponseForMainRequest:(ASIHTTPRequest *)request 
{
	if ([request responseStatusCode] != 200) {
		return nil;
	}
	
	NSDictionary *response = [super createResponseForMainRequest:request];
	response = [response objectForKey:@"status"];
	if (!response) {
		return nil;
	}
	
	NMStatusUpdate *status = [[[NMStatusUpdate alloc] initWithDictionary:response] autorelease];
	[self.user setLastStatus:status];
	return status;
}

@end
