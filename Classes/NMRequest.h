//
//  NMRequest.h
//  NinetyMinutes
//
//  Created by Nebil Kriedi on 09/12/10.
//  Copyright 2010 Nebil Kriedi. All rights reserved.
//

#import <Foundation/Foundation.h>


@class NMRequest;
@protocol NMRequestDelegate <NSObject>

- (void)request:(NMRequest *)request didFailWithError:(NSError *)error;
- (void)request:(NMRequest *)request didFinishWithResponse:(id)response;

@optional
- (void)requestDidCancel:(NMRequest *)request;

@end


@class ASINetworkQueue;
@class ASIHTTPRequest;


extern NSString * const kNMRequestDomain;


@interface NMRequest : NSObject 
{
	id _delegate;
	NSURL *_rootURL;
	ASINetworkQueue *_networkQueue;
	BOOL _cancelled;
	id _userInfo;
}

- (id)initWithRootURL:(NSURL *)url;
@property (nonatomic, readonly) NSURL *rootURL;

@property(nonatomic, assign) id<NMRequestDelegate> delegate;
@property (nonatomic, retain) id userInfo;

@property (nonatomic, readonly, getter = isExecuting) BOOL executing;
- (BOOL)start;
- (void)cancel;

// protected
- (ASIHTTPRequest *)createMainRequest;
- (id)createResponseForMainRequest:(ASIHTTPRequest *)request;
- (NSError *)createErrorForResponseOfMainRequest:(ASIHTTPRequest *)request;

- (void)mainRequestFinished:(ASIHTTPRequest *)request;
- (void)mainRequestFailed:(ASIHTTPRequest *)request;

@end
