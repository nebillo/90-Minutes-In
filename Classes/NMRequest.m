//
//  NMRequest.m
//  NinetyMinutes
//
//  Created by Nebil Kriedi on 09/12/10.
//  Copyright 2010 Nebil Kriedi. All rights reserved.
//

#import "NMRequest.h"

#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "JSON.h"


NSString * const kNMRequestDomain = @"com.ninetyminutes.httpRequest";


@implementation NMRequest

- (id)initWithRootURL:(NSURL *)url {
	if (self = [super init]) {
		_rootURL = [url retain];
		_networkQueue = [[ASINetworkQueue alloc] init];
		[_networkQueue go];
	}
	return self;
}


- (void)dealloc {
	[_rootURL release];
	_cancelled = YES;
	[_networkQueue cancelAllOperations];
	[_networkQueue release];
	[_userInfo release];
	
	[super dealloc];
}


@synthesize rootURL = _rootURL;
@synthesize delegate = _delegate;
@synthesize userInfo = _userInfo;


+ (NSMutableSet *)operationsPool {
	static NSMutableSet *operationsPool = nil;
	if (!operationsPool) {
		operationsPool = [[NSMutableSet alloc] init];
	}
	return operationsPool;
}


- (BOOL)isExecuting {
	return [_networkQueue operationCount] > 0;
}
			

- (BOOL)start {
	// cannot start while is still running
	if ([self isExecuting]) {
		return NO;
	}
	
	ASIHTTPRequest *request = [self createMainRequest];
	// invalid request
	if (!request) {
		return NO;
	}
	
	_cancelled = NO;
	[[[self class] operationsPool] addObject:self];
	
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(mainRequestFinished:)];
	[request setDidFailSelector:@selector(mainRequestFailed:)];
	[_networkQueue addOperation:request];
	
	return YES;
}


- (void)cancel {
	_cancelled = YES;
	[_networkQueue cancelAllOperations];
	
	if ([self.delegate respondsToSelector:@selector(requestDidCancel:)]) {
		[self.delegate requestDidCancel:self];
	}
	
	[[[self class] operationsPool] removeObject:self];
}


- (ASIHTTPRequest *)createMainRequest {
	// overwrite in subclasses
	return [ASIHTTPRequest requestWithURL:_rootURL];
}


- (id)createResponseForMainRequest:(ASIHTTPRequest *)request {
	// overwrite in subclasses
	return [request JSONRepresentation];
}


- (NSError *)createErrorForResponseOfMainRequest:(ASIHTTPRequest *)request {
	return [NSError errorWithDomain:kNMRequestDomain 
							   code:[request responseStatusCode] 
						   userInfo:request.userInfo];
}


- (void)mainRequestFinished:(ASIHTTPRequest *)request {
	id response = [self createResponseForMainRequest:request];
	if (response) {
		NSLog(@"request finished with status: %d, %@: %@", 
			  [request responseStatusCode], 
			  [request requestMethod], 
			  [request.url absoluteString]);
		
		[self.delegate request:self didFinishWithResponse:response];
	} else {
		NSLog(@"request response failure with status: %d, %@: %@", 
			  [request responseStatusCode], 
			  [request requestMethod], 
			  [request.url absoluteString]);
		
		NSError *error = [self createErrorForResponseOfMainRequest:request];
		[self.delegate request:self didFailWithError:error];
	}
	
	[[[self class] operationsPool] removeObject:self];
}


- (void)mainRequestFailed:(ASIHTTPRequest *)request {
	if (_cancelled) {
		return;
	}
	
	NSLog(@"request failed with error: %@, %@: %@", 
		  [request error], 
		  [request requestMethod], 
		  [request.url absoluteString]);
	
	if ([request.error code] == ASIRequestCancelledErrorType) {
		if ([self.delegate respondsToSelector:@selector(requestDidCancel:)]) {
			[self.delegate requestDidCancel:self];
		}
	} else {
		[self.delegate request:self didFailWithError:request.error];
	}
	
	[[[self class] operationsPool] removeObject:self];
}


@end
