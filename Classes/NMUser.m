//
//  NMUser.m
//  NinetyMinutes
//
//  Created by Nebil on 12/02/11.
//  Copyright 2011 Nebil Kriedi. All rights reserved.
//

#import "NMUser.h"


@implementation NMUser

#pragma mark -
#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:self.identifier forKey:@"identifier"];
	[coder encodeObject:self.username forKey:@"username"];
	[coder encodeObject:self.fullname forKey:@"fullname"];
}


- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		[self setIdentifier:[decoder decodeObjectForKey:@"identifier"]];
		[self setUsername:[decoder decodeObjectForKey:@"username"]];
		[self setFullname:[decoder decodeObjectForKey:@"fullname"]];
	}
	return self;
}


#pragma mark -
#pragma mark Memory

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
