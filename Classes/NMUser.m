//
//  NMUser.m
//  NinetyMinutes
//
//  Created by Nebil on 12/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NMUser.h"


@implementation NMUser

- (void)dealloc {
	self.identifier = nil;
	self.username = nil;
	self.fullname = nil;
	[super dealloc];
}


@synthesize identifier;
@synthesize username;
@synthesize fullname;

@end
