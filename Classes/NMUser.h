//
//  NMUser.h
//  NinetyMinutes
//
//  Created by Nebil on 12/02/11.
//  Copyright 2011 Nebil Kriedi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>

@class NMStatusUpdate;
@class CLLocation;


@interface NMUser : NSObject <NSCoding, MKAnnotation>
{
}

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSString *facebookId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *middleName;
@property (nonatomic, copy) NSString *gender;
@property (nonatomic, copy) NSString *picture;
@property (nonatomic, retain) NMStatusUpdate *lastStatus;
@property (nonatomic, retain) CLLocation *currentLocation;
@property (nonatomic, retain) NSArray *friends;

- (id)initWithDictionary:(NSDictionary *)dictionary;

- (NSComparisonResult)compareWithUser:(NMUser *)user;

@end
