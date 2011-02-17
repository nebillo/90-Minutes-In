//
//  NMAuthenticationManager.m
//  NinetyMinutes
//
//  Created by Nebil Kriedi on 30/11/10.
//  Copyright 2010 Nebil Kriedi. All rights reserved.
//

#import "NMAuthenticationManager.h"
#import "ASINetworkQueue.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"


NSString * const kNMFacebookDomain = @"com.faceboook.connect";


@interface NMAuthenticationManager ()

- (NMUser *)savedUser;
- (BOOL)saveUser:(NMUser *)user;
- (BOOL)removeSavedUser;

@end


@implementation NMAuthenticationManager

static NMAuthenticationManager *sharedManager = nil;

+ (id)sharedManager {
	if (!sharedManager) {
		sharedManager = [[NMAuthenticationManager alloc] init];
	}
	return sharedManager;
}


- (id)init {
	if (self = [super init]) {
		_facebookManager = [[Facebook alloc] init];
		[_facebookManager setSessionDelegate:self];
		
		_networkQueue = [[ASINetworkQueue alloc] init];
		[_networkQueue setMaxConcurrentOperationCount:1];
		[_networkQueue go];
	}
	return self;
}


- (void)dealloc {
	[_networkQueue cancelAllOperations];
	[_networkQueue release];
	[_facebookManager setSessionDelegate:nil];
	[_facebookManager release];
	[super dealloc];
}


@synthesize delegate = _delegate;

#pragma mark -
#pragma mark Session

static NMUser *authenticatedUser = nil;

- (NMUser *)authenticatedUser {	
	if (!authenticatedUser) {
		NMUser *user = [self savedUser];
		if (user.identifier) {
			authenticatedUser = [user retain];
		}
	}
	return authenticatedUser;
}


- (void)setAuthenticatedUser:(NMUser *)user {
	if (authenticatedUser != user) {
		[authenticatedUser release];
		authenticatedUser = [user retain];
	}
	
	if (user) {
		// save new user
		[self saveUser:user];
	} else {
		// remove user
		[self removeSavedUser];
	}
}


- (BOOL)isSessionValid {
	return [self authenticatedUser] != nil;	
}


- (void)clearSession {
	if (![self authenticatedUser]) {
		return;
	}
	NSLog(@"clearing session for user: %@", [self authenticatedUser]);
	[self setAuthenticatedUser:nil];
	[_facebookManager logout:self];
}


#pragma mark Persistence

- (NSString *)userCacheFile {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *filename = [documentsDirectory stringByAppendingPathComponent:@"user.plist"];
	return filename;
}


- (NMUser *)savedUser {
	// read from disk		
	if (![[NSFileManager defaultManager] fileExistsAtPath:[self userCacheFile]]) {
		return nil;
	}
	
	NSData *data = [[NSData alloc] initWithContentsOfFile:[self userCacheFile]]; 
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];	
	
	NMUser *user = [unarchiver decodeObjectForKey:@"user"];
	[unarchiver finishDecoding];
	
	[unarchiver release]; 
	[data release];
	
	return user;
}


- (BOOL)saveUser:(NMUser *)user {
	// save to disk
	NSMutableData *data = [[NSMutableData alloc] init]; 
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	
	[archiver encodeObject:user forKey:@"user"];
	[archiver finishEncoding];
	
	BOOL result = [data writeToFile:[self userCacheFile] atomically:YES];
	if (result) {
		NSLog(@"user was saved to disk: %@", user);
	} else {
		NSLog(@"error while saving user to disk");
	}
	
	[archiver release]; 
	[data release];
	
	return result;
}


- (BOOL)removeSavedUser {
	// remove user file
	return [[NSFileManager defaultManager] removeItemAtPath:[self userCacheFile] error:nil];
}


#pragma mark -
#pragma mark Facebook

- (void)connectWithFacebookAppId:(NSString *)appId {
	if ([_facebookManager isSessionValid]) {
		[self fbDidLogin];
	} else {
		NSLog(@"login to facebook with appId: %@", appId);
		[_facebookManager authorize:appId 
						permissions:[NSArray arrayWithObjects:
									 @"offline_access",
									 @"publish_stream", nil] 
						   delegate:self];
	}
}


#pragma mark FBSessionDelegate

- (void)fbDidLogin {
	NSLog(@"user did login to facebook with token: %@", _facebookManager.accessToken);
	// read user data
	[_facebookManager requestWithGraphPath:@"me" 
								 andParams:[NSMutableDictionary dictionaryWithObject:@"friends" forKey:@"fields"] 
							   andDelegate:self];
}


- (void)fbDidNotLogin:(BOOL)cancelled {
	NSLog(@"user did fail login, cancelled: %d", cancelled);
	if ([self.delegate respondsToSelector:@selector(authenticationManager:didFailConnectUserWithError:)]) {
		[self.delegate authenticationManager:self didFailConnectUserWithError:[NSError errorWithDomain:kNMFacebookDomain 
																								  code:(NSUInteger)cancelled 
																							  userInfo:nil]];
	}
}


- (void)fbDidLogout {
	NSLog(@"user did logout from facebook");
}


#pragma mark FBRequestDelegate

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
	NSLog(@"fail to get user info with error: %@", error);
	if ([self.delegate respondsToSelector:@selector(authenticationManager:didFailConnectUserWithError:)]) {
		[self.delegate authenticationManager:self didFailConnectUserWithError:error];
	}
}


- (void)request:(FBRequest *)request didLoad:(id)result {
	NSDictionary *dict = (NSDictionary *)result;
	NSLog(@"did receive user info from facebook: %@", [dict objectForKey:@"id"]);
	
	NSString *url = [NSString stringWithFormat:@"%@/facebook-connect", kAPIRootURL];
	ASIFormDataRequest *connectRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
	[connectRequest setRequestMethod:@"PUT"];
	[connectRequest setPostValue:_facebookManager.accessToken forKey:@"facebook_access_token"];
	[connectRequest setPostValue:[dict objectForKey:@"id"] forKey:@"facebook_id"];
	[connectRequest setPostValue:[dict JSONRepresentation] forKey:@"facebook_data"];
	[connectRequest setDelegate:self];
	[connectRequest setDidFinishSelector:@selector(connectRequestDone:)];
	[connectRequest setDidFailSelector:@selector(connectRequestFail:)];
	[_networkQueue addOperation:connectRequest];
}


#pragma mark ASIHTTPRequest

- (void)connectRequestFail:(ASIHTTPRequest *)request {
	NSLog(@"did fail connect user with error: %@", [request error]);
	if ([self.delegate respondsToSelector:@selector(authenticationManager:didFailConnectUserWithError:)]) {
		[self.delegate authenticationManager:self didFailConnectUserWithError:[request error]];
	}
}


- (void)connectRequestDone:(ASIHTTPRequest *)request {
	NSDictionary *dict = [[request responseString] JSONValue];
	dict = [dict objectForKey:@"user"];
	
	if (!dict) {
		[self connectRequestFail:request];
		return;
	}
	
	NMUser *user = [[[NMUser alloc] initWithDictionary:dict] autorelease];
	[self setAuthenticatedUser:user];
	
	NSLog(@"did connect user with facebook id: %@, to id: %@", user.facebookId, user.identifier);
	if ([self.delegate respondsToSelector:@selector(authenticationManager:didConnectUser:)]) {
		[self.delegate authenticationManager:self didConnectUser:user];
	}
}


@end
