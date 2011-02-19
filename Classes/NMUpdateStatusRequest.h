//
//  NMUpdateStatusRequest.h
//  NinetyMinutes
//
//  Created by Nebil on 17/02/11.
//  Copyright 2011 Nebil Kriedi. All rights reserved.
//

#import "NMRequest.h"

@class CLLocation;


@interface NMUpdateStatusRequest : NMRequest 
{
}

@property (nonatomic, copy) NSString *status;
@property (nonatomic, retain) CLLocation *location;

@end
