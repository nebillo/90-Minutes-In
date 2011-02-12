//
//  NMAuthenticationManager.m
//  NinetyMinutes
//
//  Created by Nebil Kriedi on 30/11/10.
//  Copyright 2010 Nebil Kriedi. All rights reserved.
//

#import "NMAuthenticationManager.h"


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
	}
	return self;
}


- (void)dealloc {
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
#pragma mark Login

- (void)loginWithUserName:(NSString *)username password:(NSString *)password {
	//TODO: to be implemented
}


@end
