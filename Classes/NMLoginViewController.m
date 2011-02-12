//
//  NMLoginViewController.m
//  NinetyMinutes
//
//  Created by Nebil on 12/02/11.
//  Copyright 2011 Nebil Kriedi. All rights reserved.
//

#import "NMLoginViewController.h"


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
	[self.navigationItem setRightBarButtonItem:[[[UIBarButtonItem alloc] initWithTitle:@"Signup" 
																				 style:UIBarButtonItemStyleBordered 
																				target:self 
																				action:@selector(signin)] autorelease]];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (IBAction)signin {
}


- (IBAction)signup {
}


#pragma mark -
#pragma mark Memory

- (void)viewDidUnload {
	self.usernameField = nil;
	self.passwordField = nil;
	self.signinButton = nil;
	
    [super viewDidUnload];
}


- (void)dealloc {
	self.usernameField = nil;
	self.passwordField = nil;
	self.signinButton = nil;
	
    [super dealloc];
}


@synthesize usernameField;
@synthesize passwordField;
@synthesize signinButton;

@end
