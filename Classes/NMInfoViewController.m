//
//  NMInfoViewController.m
//  NinetyMinutes
//
//  Created by Nebil on 19/02/11.
//  Copyright 2011 Nebil Kriedi. All rights reserved.
//

#import "NMInfoViewController.h"
#import "NMAuthenticationManager.h"
#import "NinetyMinutesAppDelegate.h"


@implementation NMInfoViewController

- (id)init {
    self = [super initWithNibName:@"NMInfoViewController" bundle:nil];
    if (self) {
        // Custom initialization.
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self.navigationItem setTitle:@"About"];
}


- (IBAction)logout {
	UIActionSheet *sheet = [[[UIActionSheet alloc] initWithTitle:@"Do you really want to logout?" 
														delegate:self 
											   cancelButtonTitle:@"Cancel" 
										  destructiveButtonTitle:@"Logout" 
											   otherButtonTitles:nil] autorelease];
	[sheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
	
	UITabBarController *controller = [(NinetyMinutesAppDelegate *)[UIApplication sharedApplication].delegate tabBarController];
	[sheet showFromTabBar:controller.tabBar];
}


#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.cancelButtonIndex) {
		return;
	}
	
	// logout
	[[NMAuthenticationManager sharedManager] clearSession];
	
	// present login controller
	[(NinetyMinutesAppDelegate *)[UIApplication sharedApplication].delegate showLoginController];
}


#pragma mark -
#pragma mark Memory

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
