//
//  RootViewController.m
//  NinetyMinutes
//
//  Created by Nebil on 12/02/11.
//  Copyright 2011 Nebil Kriedi. All rights reserved.
//

#import "NMRootViewController.h"

#import "NMAuthenticationManager.h"
#import "NMUser.h"
#import "NMStatusUpdate.h"

#import "NMUpdateStatusRequest.h"
#import "NMGetStatusRequest.h"

#import "NMViewExtension.h"


@interface NMRootViewController ()

- (void)updateWithStatus:(NMStatusUpdate *)status;

@end


@implementation NMRootViewController

- (id)init {
    if ((self = [super initWithNibName:@"NMRootViewController" bundle:nil])) {
        // Custom initialization
    }
    return self;
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	NMUser *user = [[NMAuthenticationManager sharedManager] authenticatedUser];
	
	[self.navigationItem setTitle:@"90 Minutes In"];
	[self.navigationItem setRightBarButtonItem:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
																							  target:self 
																							  action:@selector(getStatus)] autorelease]];
		
	[self.userLabel setText:[NSString stringWithFormat:@"Hi %@, your are:", user.firstName]];
	[self updateWithStatus:user.lastStatus];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	[self getStatus];
}


- (IBAction)getStatus {
	[self.view presentLoadingViewWithTitle:@"Getting your status…"];
	
	NMGetStatusRequest *update = [[[NMGetStatusRequest alloc] initWithRootURL:[NSURL URLWithString:kAPIRootURL]] autorelease];
	[update setDelegate:self];
	[update setUser:[[NMAuthenticationManager sharedManager] authenticatedUser]];
	[update start];
}


- (void)setStatus:(NSString *)status {
	[self.view presentLoadingViewWithTitle:@"Updating your status…"];
	
	NMUpdateStatusRequest *update = [[[NMUpdateStatusRequest alloc] initWithRootURL:[NSURL URLWithString:kAPIRootURL]] autorelease];
	[update setDelegate:self];
	[update setStatus:status];
	[update start];
}


- (IBAction)setStatusIn {
	[self setStatus:kNMStatusIn];
}


- (IBAction)setStatusOut {
	[self setStatus:kNMStatusOut];
}


- (void)updateWithStatus:(NMStatusUpdate *)status {
	if (!status || (NSNull *)status == [NSNull null] || status.expired) {
		// no status or status is expired
		[self.statusInButton setUserInteractionEnabled:YES];
		[self.statusOutButton setUserInteractionEnabled:YES];
		[self.statusInButton setSelected:NO];
		[self.statusOutButton setSelected:NO];
	} else {
		// there is a valid status
		[self.statusInButton setUserInteractionEnabled:NO];
		[self.statusOutButton setUserInteractionEnabled:NO];
		if ([status.status isEqualToString:kNMStatusIn]) {
			[self.statusInButton setSelected:YES];
			[self.statusOutButton setSelected:NO];
		} else {
			[self.statusOutButton setSelected:YES];
			[self.statusInButton setSelected:NO];
		}
	}
}


#pragma mark -
#pragma mark NMRequestDelegate

- (void)request:(NMRequest *)request didFailWithError:(NSError *)error {
	if ([request isKindOfClass:[NMGetStatusRequest class]]) {
		[[[[UIAlertView alloc] initWithTitle:@"Get status error" 
									 message:[error localizedDescription] 
									delegate:nil 
						   cancelButtonTitle:@"Ok" 
						   otherButtonTitles:nil] autorelease] show];
	} else if ([request isKindOfClass:[NMUpdateStatusRequest class]]) {
		[[[[UIAlertView alloc] initWithTitle:@"Update status error" 
									 message:[error localizedDescription] 
									delegate:nil 
						   cancelButtonTitle:@"Ok" 
						   otherButtonTitles:nil] autorelease] show];
	}
	[self.view dismissStaticView];
}


- (void)request:(NMRequest *)request didFinishWithResponse:(id)response {
	
	NMStatusUpdate *status = (NMStatusUpdate *)response;
	[self updateWithStatus:status];
	[self.view dismissStaticView];
	
	if ([request isKindOfClass:[NMGetStatusRequest class]]) {
		//
	} else if ([request isKindOfClass:[NMUpdateStatusRequest class]]) {
		//
		[[[[UIAlertView alloc] initWithTitle:@"Status updated" 
									 message:[NSString stringWithFormat:@"You'll be %@ for 90 minutes", status.status] 
									delegate:nil 
						   cancelButtonTitle:@"Ok" 
						   otherButtonTitles:nil] autorelease] show];
	}
}


#pragma mark -
#pragma mark Memory management

- (void)viewDidUnload {
	self.statusInButton = nil;
	self.statusOutButton = nil;
	self.userLabel = nil;
	[super viewDidUnload];
}


- (void)dealloc {
	self.statusInButton = nil;
	self.statusOutButton = nil;
	self.userLabel = nil;
    [super dealloc];
}


@synthesize statusInButton;
@synthesize statusOutButton;
@synthesize userLabel;

@end

