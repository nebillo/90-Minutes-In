//
//  NMStatusUpdate.h
//  NinetyMinutes
//
//  Created by Nebil on 17/02/11.
//  Copyright 2011 Nebil Kriedi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


extern NSString * const kNMStatusOut;
extern NSString * const kNMStatusIn;


@interface NMStatusUpdate : NSObject 
{
	BOOL _expired;
}

- (id)initWithDictionary:(NSDictionary *)dict;

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) NSDate *expirationDate;
@property (nonatomic, readonly) NSTimeInterval remainingTime;
@property (nonatomic, retain) CLLocation *location;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, readonly, getter = isExpired) BOOL expired;

- (NSComparisonResult)compareWithStatus:(NMStatusUpdate *)status;

@end
