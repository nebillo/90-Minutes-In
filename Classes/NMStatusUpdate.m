//
//  NMStatusUpdate.m
//  NinetyMinutes
//
//  Created by Nebil on 17/02/11.
//  Copyright 2011 Nebil Kriedi. All rights reserved.
//

#import "NMStatusUpdate.h"
#import "NSDateAdditions.h"


NSString * const kNMStatusOut = @"out";
NSString * const kNMStatusIn = @"in";


@implementation NMStatusUpdate

- (id)initWithDictionary:(NSDictionary *)dict {
	if (self = [super init]) {
		self.identifier = [dict objectForKey:@"id"];
		
		self.status = [dict objectForKey:@"status"];
		
		NSString *location = [dict objectForKey:@"location"];
		if (location) {
			NSArray *coords = [location componentsSeparatedByString:@","];
			CLLocation *location = [[[CLLocation alloc] initWithLatitude:[[coords objectAtIndex:0] floatValue] 
															   longitude:[[coords objectAtIndex:1] floatValue]] autorelease];
			self.location = location;
			self.address = [dict objectForKey:@"address"];
		}
		
		self.createdAt = [NSDate dateWithISOString:[dict objectForKey:@"created_at"]];
		self.expirationDate = [NSDate dateWithISOString:[dict objectForKey:@"expiration_date"]];
	}
	return self;
}


- (void)dealloc {
	self.identifier = nil;
	self.status = nil;
	self.createdAt = nil;
	self.expirationDate = nil;
	self.location = nil;
	self.address = nil;
	[super dealloc];
}


- (BOOL)isExpired {
	return [self.expirationDate timeIntervalSinceNow] > 0;
}


@synthesize identifier;
@synthesize status;
@synthesize createdAt;
@synthesize expirationDate;
@synthesize location;
@synthesize address;

@end
