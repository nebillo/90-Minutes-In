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
#import <CoreLocation/CLLocation.h>
#import <Three20Core/NSDateAdditions.h>


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


- (NSComparisonResult)compareWithUser:(NMUser *)user {
	// compare by last name
	NSComparisonResult result = [self.lastName compare:user.lastName options:NSCaseInsensitiveSearch];
	if (result == NSOrderedSame) {
		// and by middle name
		result = [self.middleName compare:user.middleName options:NSCaseInsensitiveSearch];
	}
	if (result == NSOrderedSame) {
		// and by first name
		result = [self.firstName compare:user.firstName options:NSCaseInsensitiveSearch];
	}
	return result;
}


- (NSComparisonResult)compareWithUserByStatus:(NMUser *)user {
	if (!self.lastStatus && !user.lastStatus) {
		// both with no status: compare by name
		return [self compareWithUser:user];
	}
	if (!self.lastStatus) {
		// user with status goes first
		return NSOrderedAscending;
	}
	if (!user.lastStatus) {
		// user with status goes first
		return NSOrderedDescending;
	}
	// user with most recent status goes first
	return [self.lastStatus compareWithStatus:user.lastStatus];
}


- (NSString *)statusDescriptionWithDefaultText:(NSString *)defaultOrNil {
	NMStatusUpdate *status = self.lastStatus;
	
	if (!status) {
		// no status
		return defaultOrNil;
	}
	
	if (status.expired) {
		// expired status
		return [NSString stringWithFormat:@"was %@ %@", status.status, [status.expirationDate formatRelativeTime]];
	}
	
	int minutes = ceil(status.remainingTime / 60.0);
	NSString *format = minutes == 1 ? @"%@ for %d more minute" : @"%@ for %d more minutes";
	return [NSString stringWithFormat:format, status.status, minutes];
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
#pragma mark MKAnnotation

- (CLLocationCoordinate2D)coordinate {
	if (self.currentLocation && (!self.lastStatus || self.lastStatus.expired)) {
		return self.currentLocation.coordinate;
	}
	if (self.lastStatus.location) {
		return self.lastStatus.location.coordinate;
	}
	// 0,0 coordinate
	return CLLocationCoordinate2DMake(0, 0);
}


- (NSString *)title {
	return self.name;
}


- (NSString *)subtitle {
	return [self statusDescriptionWithDefaultText:@"in or out?"];
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
	self.currentLocation = nil;
	self.friends = nil;
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
@synthesize currentLocation;
@synthesize coordinate;
@synthesize friends;

@end
