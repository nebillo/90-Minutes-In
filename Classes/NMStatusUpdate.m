//
//  NMStatusUpdate.m
//  NinetyMinutes
//
//  Created by Nebil on 17/02/11.
//  Copyright 2011 Nebil Kriedi. All rights reserved.
//

#import "NMStatusUpdate.h"
#import "NSDateAdditions.h"
#import "NSDictionaryAdditions.h"


NSString * const kNMStatusOut = @"out";
NSString * const kNMStatusIn = @"in";


@implementation NMStatusUpdate

- (id)initWithDictionary:(NSDictionary *)dict {
	if (self = [super init]) {
		self.identifier = [dict objectForKey:@"id"];
		
		self.status = [dict objectForKey:@"status"];
		
		NSString *location = [dict objectForKeyOrNil:@"location"];
		if (location) {
			NSArray *coords = [location componentsSeparatedByString:@","];
			CLLocation *location = [[[CLLocation alloc] initWithLatitude:[[coords objectAtIndex:0] floatValue] 
															   longitude:[[coords objectAtIndex:1] floatValue]] autorelease];
			self.location = location;
			self.address = [dict objectForKeyOrNil:@"address"];
		}
		
		self.createdAt = [NSDate dateWithISOString:[dict objectForKey:@"created_at"]];
		
		NSTimeInterval remainingTime = [[dict objectForKeyOrNil:@"remaining_time"] floatValue];
		if (remainingTime > 0) {
			_expired = NO;
			self.expirationDate = [NSDate dateWithTimeIntervalSinceNow:remainingTime];
		} else {
			_expired = YES;
			self.expirationDate = [NSDate dateWithISOString:[dict objectForKey:@"expiration_date"]];
		}
		
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
	if (_expired) {
		return YES;
	}
	return [self.expirationDate timeIntervalSinceNow] <= 0;
}


- (NSTimeInterval)remainingTime {
	if (self.expired) {
		return 0.0f;
	}
	return [self.expirationDate timeIntervalSinceNow];
}


- (NSComparisonResult)compareWithStatus:(NMStatusUpdate *)status {
	NSComparisonResult creationDateCompare = [self.createdAt compare:status.createdAt];
	if (creationDateCompare == NSOrderedAscending) {
		return NSOrderedDescending;
	}
	if (creationDateCompare == NSOrderedDescending) {
		return NSOrderedAscending;
	}
	return NSOrderedSame;
}


@synthesize identifier;
@synthesize status;
@synthesize createdAt;
@synthesize expirationDate;
@synthesize location;
@synthesize address;

@end
