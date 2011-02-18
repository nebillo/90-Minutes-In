//
//  ASIHTTPRequest+Signature.m
//  Glamour
//
//  Created by Nebil Kriedi on 01/12/10.
//  Copyright 2010 H-art. All rights reserved.
//

#import "ASIHTTPRequest+Signature.h"
#import "NMUser.h"
#import "NSURL+QueryParameters.h"
#import <Three20Core/NSStringAdditions.h>
#import <CommonCrypto/CommonDigest.h>


NSString * const kSignedRequestUserKey = @"user";
NSString * const kSecretToken = @"gkig1ì£$%&%?-.qde/&$£Ghkjho12";


@implementation ASIHTTPRequest (Signature)

+ (NSString *)generateSignatureForAccessToken:(NSString *)accessToken {
	NSString *token = [NSString stringWithFormat:@"~%@~%@~", accessToken, kSecretToken];
	NSString *signature = [token sha1Hash];
	return signature;
}


- (id)initWithAPIPath:(NSString *)path 
		   parameters:(NSDictionary *)parameters 
			  rootURL:(NSURL *)rootURL 
		 signWithUser:(NMUser *)user {
		
	if (![path hasPrefix:@"/"]) {
		path = [@"/" stringByAppendingString:path];
	}
	
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	for (NSString *key in parameters) {
		id object = [parameters objectForKey:key];
		if ([object isKindOfClass:[NSNumber class]]) {
			object = [(NSNumber *)object stringValue];
		} else {
			object = [object description];
		}
		[params setObject:object forKey:key];
	}
	
	if (user.accessToken) {
		NSString *signature = [[self class] generateSignatureForAccessToken:user.accessToken];
		[params setObject:signature forKey:@"signature"];
		[params setObject:user.accessToken forKey:@"access_token"];
	} else {
		NSLog(@"signing of call %@ skipped due to invalid access token", path);
	}
	
	NSURL *apiURL = [NSURL URLWithString:[[rootURL absoluteString] stringByAppendingString:path]];
	apiURL = [apiURL urlByAddingQueryStringParameters:params];
	
	if (self = [self initWithURL:apiURL]) {
		if (user.accessToken) {
			// set a mutable dictionary with user reference for easy access
			[self setUserInfo:[NSMutableDictionary dictionaryWithObject:user 
																 forKey:kSignedRequestUserKey]];
		}
	}
	return self;
}


+ (id)requestWithAPIPath:(NSString *)path
			  parameters:(NSDictionary *)parameters
				 rootURL:(NSURL *)rootURL
			signWithUser:(NMUser *)user {
	return [[[[self class] alloc]  initWithAPIPath:path 
										parameters:parameters 
										   rootURL:rootURL
									  signWithUser:user] autorelease];
}


- (NMUser *)signedUser {
	return (NMUser *)[self.userInfo objectForKey:kSignedRequestUserKey];
}


@end
