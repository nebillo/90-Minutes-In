//
//  NMUpdateStatusRequest.m
//  NinetyMinutes
//
//  Created by Nebil on 17/02/11.
//  Copyright 2011 Nebil Kriedi. All rights reserved.
//

#import "NMUpdateStatusRequest.h"
#import "NMUser.h"
#import "ASIFormDataRequest.h"

#import <CoreLocation/CoreLocation.h>


@implementation NMUpdateStatusRequest

@synthesize status = _status;
@synthesize location = _location;

- (void)dealloc {
	self.location = nil;
	[super dealloc];
}


- (ASIHTTPRequest *)createMainRequest {
	NSString *url = [NSString stringWithFormat:@"%@/user/%@/status", [self.rootURL absoluteString]];
	ASIFormDataRequest *updateRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
	[updateRequest setRequestMethod:@"PUT"];
	
	[updateRequest setPostValue:self.status == NMStatusIn ? @"in" : @"out" 
						 forKey:@"status"];
	
	if (self.location) {
		[updateRequest setPostValue:[NSNumber numberWithFloat:self.location.coordinate.latitude] forKey:@"lat"];
		[updateRequest setPostValue:[NSNumber numberWithFloat:self.location.coordinate.longitude] forKey:@"lon"];
	}
	
	return updateRequest;
}


- (id)createResponseForMainRequest:(ASIHTTPRequest *)request {
	NSDictionary *response = [super createResponseForMainRequest:request];
	response = [response objectForKey:@"status"];
	NMStatusUpdate *status = [[[NMStatusUpdate alloc] initWithDictionary:response] autorelease];
	return status;
}

@end
