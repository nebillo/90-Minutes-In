//
//  NMUpdateStatusRequest.m
//  NinetyMinutes
//
//  Created by Nebil on 17/02/11.
//  Copyright 2011 Nebil Kriedi. All rights reserved.
//

#import "NMUpdateStatusRequest.h"
#import "NMUser.h"
#import "NMStatusUpdate.h"

#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest+Signature.h"
#import "NMAuthenticationManager.h"


#import <CoreLocation/CoreLocation.h>


@implementation NMUpdateStatusRequest

@synthesize status = _status;
@synthesize location = _location;


- (void)dealloc 
{
	self.status = nil;
	self.location = nil;
	[super dealloc];
}


- (ASIHTTPRequest *)createMainRequest 
{
	NMUser *user = [[NMAuthenticationManager sharedManager] authenticatedUser];
	NSString *path = [NSString stringWithFormat:@"/user/%@/status", user.facebookId];
	ASIFormDataRequest *updateRequest = [ASIFormDataRequest requestWithAPIPath:path
																	parameters:nil 
																	   rootURL:self.rootURL 
																  signWithUser:user];
	[updateRequest setRequestMethod:@"PUT"];
	
	[updateRequest setPostValue:self.status forKey:@"status"];
	
	if (self.location) {
		[updateRequest setPostValue:[NSNumber numberWithFloat:self.location.coordinate.latitude] forKey:@"lat"];
		[updateRequest setPostValue:[NSNumber numberWithFloat:self.location.coordinate.longitude] forKey:@"lon"];
	}
	
	return updateRequest;
}


- (id)createResponseForMainRequest:(ASIHTTPRequest *)request 
{
	if ([request responseStatusCode] != 201) {
		return nil;
	}
	
	NSDictionary *response = [super createResponseForMainRequest:request];
	response = [response objectForKey:@"status"];
	NMStatusUpdate *status = [[[NMStatusUpdate alloc] initWithDictionary:response] autorelease];
	return status;
}

@end
