//
//  NMAuthenticationManager.h
//  NinetyMinutes
//
//  Created by Nebil Kriedi on 30/11/10.
//  Copyright 2010 Nebil Kriedi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NMUser.h"


@protocol NMAuthenticationManagerDelegate;


@interface NMAuthenticationManager : NSObject
{
	id _delegate;
}

@property (nonatomic, assign) id<NMAuthenticationManagerDelegate> delegate;

+ (id)sharedManager;

- (BOOL)isSessionValid;
- (NMUser *)authenticatedUser;
- (void)clearSession;

- (void)loginWithUserName:(NSString *)username password:(NSString *)password;

@end


@protocol NMAuthenticationManagerDelegate <NSObject>

@optional

- (void)authenticationManager:(NMAuthenticationManager *)manager didLoginUser:(NMUser *)user;
- (void)authenticationManager:(NMAuthenticationManager *)manager didFailLoginUserWithError:(NSError *)error;

@end
