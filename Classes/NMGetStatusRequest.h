//
//  NMGetStatusRequest.h
//  NinetyMinutes
//
//  Created by Nebil on 19/02/11.
//  Copyright 2011 Nebil Kriedi. All rights reserved.
//

#import "NMRequest.h"

@class NMUser;


@interface NMGetStatusRequest : NMRequest 
{
	NMUser *_user;
}

@property (nonatomic, retain) NMUser *user;

@end
