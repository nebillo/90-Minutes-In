//
//  NMLoginViewController.m
//  NinetyMinutes
//
//  Created by Nebil on 12/02/11.
//  Copyright 2011 Nebil Kriedi. All rights reserved.
//

#import "NMLoginViewController.h"
#import "NinetyMinutesAppDelegate.h"
#import "NMViewExtension.h"


@implementation NMLoginViewController

- (id)init {
    if ((self = [super initWithNibName:@"NMLoginViewController" bundle:nil])) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self.navigationItem setTitle:@"Signin"];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (IBAction)signin {
	[self.view presentLoadingViewWithTitle:@"Connecting…"];
	[[NMAuthenticationManager sharedManager] setDelegate:self];
	[[NMAuthenticationManager sharedManager] connectWithFacebookAppId:kFacebookAppId];
}


#pragma mark -
#pragma mark NMAuthenticationManagerDelegate

- (void)authenticationManager:(NMAuthenticationManager *)manager didConnectUser:(NMUser *)user {
	[self.view dismissStaticView];
	// show root controller
	[(NinetyMinutesAppDelegate *)[UIApplication sharedApplication].delegate showRootController];
	
	// and dismiss login
	[self dismissModalViewControllerAnimated:YES];
}


- (void)authenticationManager:(NMAuthenticationManager *)manager didFailConnectUserWithError:(NSError *)error {
	[self.view dismissStaticView];
	
	if ([[error domain] isEqualToString:kNMFacebookDomain] && [error code] == 1) {
		// cancelled by user
		return;
	}
	
	[[[[UIAlertView alloc] initWithTitle:@"Login failed"
								 message:@"Check your network connection and try again" 
								delegate:nil 
					   cancelButtonTitle:@"Ok"
					   otherButtonTitles:nil] autorelease] show];
}


#pragma mark -
#pragma mark Memory

- (void)viewDidUnload {
	self.signinButton = nil;
	
    [super viewDidUnload];
}


- (void)dealloc {
	self.signinButton = nil;
	
    [super dealloc];
}


@synthesize signinButton;

@end
