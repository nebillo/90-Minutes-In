//
//  NMAuthenticationManager.h
//  NinetyMinutes
//
//  Created by Nebil Kriedi on 30/11/10.
//  Copyright 2010 Nebil Kriedi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NMUser.h"
#import "Facebook.h"

@class ASINetworkQueue;


extern NSString * const kNMFacebookDomain;


@protocol NMAuthenticationManagerDelegate;


@interface NMAuthenticationManager : NSObject <FBSessionDelegate, FBRequestDelegate>
{
	id _delegate;
	Facebook *_facebookManager;
	ASINetworkQueue *_networkQueue;
}

@property (nonatomic, assign) id<NMAuthenticationManagerDelegate> delegate;

+ (id)sharedManager;

- (BOOL)isSessionValid;
- (NMUser *)authenticatedUser;
- (void)clearSession;

// authenticate with facebook
- (void)connectWithFacebookAppId:(NSString *)appId;

@end


@protocol NMAuthenticationManagerDelegate <NSObject>

@optional

- (void)authenticationManager:(NMAuthenticationManager *)manager didConnectUser:(NMUser *)user;
- (void)authenticationManager:(NMAuthenticationManager *)manager didFailConnectUserWithError:(NSError *)error;

@end
