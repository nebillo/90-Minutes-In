//
//  NMUser.m
//  NinetyMinutes
//
//  Created by Nebil on 12/02/11.
//  Copyright 2011 Nebil Kriedi. All rights reserved.
//

#import "NMUser.h"
#import "NMStatusUpdate.h"
#import "NSDictionaryAdditions.h"


@implementation NMUser

- (id)initWithDictionary:(NSDictionary *)dictionary {
	if (self = [super init]) {
		self.identifier = [dictionary objectForKey:@"id"];
		self.facebookId = [dictionary objectForKey:@"facebook_id"];
		self.name = [dictionary objectForKey:@"name"];
		self.firstName = [dictionary objectForKeyOrNil:@"first_name"];
		self.lastName = [dictionary objectForKeyOrNil:@"last_name"];
		self.middleName = [dictionary objectForKeyOrNil:@"middle_name"];
		self.gender = [dictionary objectForKeyOrNil:@"gender"];
		self.picture = [dictionary objectForKeyOrNil:@"picture"];
		self.accessToken = [dictionary objectForKey:@"access_token"];
		
		if ([dictionary objectForKeyOrNil:@"status"]) {
			self.lastStatus = [[[NMStatusUpdate alloc] initWithDictionary:[dictionary objectForKey:@"status"]] autorelease];
		}
	}
	return self;
}


#pragma mark -
#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:self.identifier forKey:@"identifier"];
	[coder encodeObject:self.facebookId forKey:@"facebook_id"];
	[coder encodeObject:self.name forKey:@"name"];
	[coder encodeObject:self.lastName forKey:@"last_name"];
	[coder encodeObject:self.firstName forKey:@"first_name"];
	[coder encodeObject:self.middleName forKey:@"middle_name"];
	[coder encodeObject:self.gender forKey:@"gender"];
	[coder encodeObject:self.picture forKey:@"picture"];
	[coder encodeObject:self.accessToken forKey:@"access_token"];
}


- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		[self setIdentifier:[decoder decodeObjectForKey:@"identifier"]];
		[self setFacebookId:[decoder decodeObjectForKey:@"facebook_id"]];
		[self setName:[decoder decodeObjectForKey:@"name"]];
		[self setLastName:[decoder decodeObjectForKey:@"last_name"]];
		[self setFirstName:[decoder decodeObjectForKey:@"first_name"]];
		[self setMiddleName:[decoder decodeObjectForKey:@"middle_name"]];
		[self setGender:[decoder decodeObjectForKey:@"gender"]];
		[self setPicture:[decoder decodeObjectForKey:@"picture"]];
		[self setAccessToken:[decoder decodeObjectForKey:@"access_token"]];
	}
	return self;
}


#pragma mark -
#pragma mark Memory

- (void)dealloc {
	self.identifier = nil;
	self.facebookId = nil;
	self.name = nil;
	self.lastName = nil;
	self.firstName = nil;
	self.middleName = nil;
	self.gender = nil;
	self.picture = nil;
	self.accessToken = nil;
	self.lastStatus = nil;
	[super dealloc];
}


@synthesize identifier;
@synthesize facebookId;
@synthesize name;
@synthesize lastName;
@synthesize firstName;
@synthesize middleName;
@synthesize gender;
@synthesize picture;
@synthesize accessToken;
@synthesize lastStatus;

@end
