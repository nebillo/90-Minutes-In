//
//  ASIHTTPRequest+Signature.h
//  Glamour
//
//  Created by Nebil Kriedi on 01/12/10.
//  Copyright 2010 H-art. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@class NMUser;


@interface ASIHTTPRequest (Signature)

- (id)initWithAPIPath:(NSString *)path 
		   parameters:(NSDictionary *)parameters 
			  rootURL:(NSURL *)rootURL 
		 signWithUser:(NMUser *)user;

+ (id)requestWithAPIPath:(NSString *)path
			  parameters:(NSDictionary *)parameters
				 rootURL:(NSURL *)rootURL
			signWithUser:(NMUser *)user;

@property (nonatomic, readonly) NMUser *signedUser;

@end
