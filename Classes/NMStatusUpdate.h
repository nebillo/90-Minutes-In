//
//  NMStatusUpdate.h
//  NinetyMinutes
//
//  Created by Nebil on 17/02/11.
//  Copyright 2011 Nebil Kriedi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


typedef enum {
	NMStatusOut = 0,
	NMStatusIn = 1,
} NMStatus;


@interface NMStatusUpdate : NSObject 
{
}

- (id)initWithDictionary:(NSDictionary *)dict;

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, assign) NMStatus status;
@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) NSDate *expirationDate;
@property (nonatomic, retain) CLLocation *location;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, readonly, getter = isExpired) BOOL expired;

@end
