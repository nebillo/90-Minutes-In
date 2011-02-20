//
//  NMFriendsRequest.m
//  NinetyMinutes
//
//  Created by Nebil on 19/02/11.
//  Copyright 2011 Nebil Kriedi. All rights reserved.
//

#import "NMFriendsRequest.h"
#import "NMUser.h"
#import "NMStatusUpdate.h"

#import "ASIHTTPRequest+Signature.h"
#import "NMAuthenticationManager.h"


@implementation NMFriendsRequest

@synthesize user = _user;


- (void)dealloc 
{
	self.user = nil;
	[super dealloc];
}


- (ASIHTTPRequest *)createMainRequest 
{
	NSString *path = [NSString stringWithFormat:@"/user/%@/friends", self.user.facebookId];
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
	NSArray *dicts = [response objectForKey:@"friends"];
	if (!dicts) {
		return nil;
	}
	
	NSMutableArray *friends = [NSMutableArray arrayWithCapacity:dicts.count];
	for (NSDictionary *dict in dicts) {
		NMUser *user = [[[NMUser alloc] initWithDictionary:dict] autorelease];
		[friends addObject:user];
	}
	// name ordering
	[friends sortUsingSelector:@selector(compareWithUser:)];
	
	return friends;
}
@end
