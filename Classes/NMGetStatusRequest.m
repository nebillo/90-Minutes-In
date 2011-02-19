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
#import "NSDictionaryAdditions.h"


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
	response = [response objectForKeyOrNil:@"status"];
	if (!response) {
		// expired status
		return [NSNull null];
	}
	
	NMStatusUpdate *status = [[[NMStatusUpdate alloc] initWithDictionary:response] autorelease];
	[self.user setLastStatus:status];
	return status;
}

@end
