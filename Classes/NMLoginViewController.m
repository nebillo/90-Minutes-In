//
//  NMLoginViewController.m
//  NinetyMinutes
//
//  Created by Nebil on 12/02/11.
//  Copyright 2011 Nebil Kriedi. All rights reserved.
//

#import "NMLoginViewController.h"
#import "NinetyMinutesAppDelegate.h"


@interface NMLoginViewController ()

- (NSString *)username;
- (NSString *)password;
- (BOOL)canSubmitWithUsername:(NSString *)username password:(NSString *)password;

@end


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
																				action:@selector(signup)] autorelease]];
	
	[self.signinButton setEnabled:[self canSubmitWithUsername:[self username] 
													 password:[self password]]];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark Fields

- (NSString *)username {
	return self.usernameField.text;
}


- (NSString *)password {
	return self.passwordField.text;
}


- (BOOL)canSubmitWithUsername:(NSString *)username password:(NSString *)password {
	if ([username length] < 1) {
		return NO;
	}
	if ([password length] < 1) {
		return NO;
	}
	
	return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	NSString *editedString = [textField.text stringByReplacingCharactersInRange:range withString:string];
	NSString *username, *password;
	
	if (textField == self.usernameField) {
		username = editedString;
		password = [self password];
	} else {
		username = [self username];
		password = editedString;
	}
	
	[self.signinButton setEnabled:[self canSubmitWithUsername:username 
													 password:password]];
	
	return YES;
}


- (BOOL)textFieldShouldClear:(UITextField *)textField {
	[self.signinButton setEnabled:NO];
	return YES;
}


- (IBAction)signin {
	if (![self canSubmitWithUsername:[self username] 
							password:[self password]]) {
		return;
	}
	
	[[NMAuthenticationManager sharedManager] setDelegate:self];
	[[NMAuthenticationManager sharedManager] loginWithUserName:[self username] 
													  password:[self password]];
	//TODO: lock view
}


- (IBAction)signup {
	//TODO: open smoodit registration page
}


#pragma mark -
#pragma mark NMAuthenticationManagerDelegate

- (void)authenticationManager:(NMAuthenticationManager *)manager didLoginUser:(NMUser *)user {
	// show root controller
	[(NinetyMinutesAppDelegate *)[UIApplication sharedApplication].delegate showRootController];
	
	// and dismiss login
	[self dismissModalViewControllerAnimated:YES];
}


- (void)authenticationManager:(NMAuthenticationManager *)manager didFailLoginUserWithError:(NSError *)error {
	[[[[UIAlertView alloc] initWithTitle:@"Login failed"
								 message:@"Check your credentials" 
								delegate:nil 
					   cancelButtonTitle:@"Ok"
					   otherButtonTitles:nil] autorelease] show];
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
