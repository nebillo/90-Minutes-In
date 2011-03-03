//
//  NinetyMinutesAppDelegate.m
//  NinetyMinutes
//
//  Created by Nebil on 12/02/11.
//  Copyright 2011 Nebil Kriedi. All rights reserved.
//

#import "NinetyMinutesAppDelegate.h"

#import "NMAuthenticationManager.h"
#import "NMLoginViewController.h"

#import "NMRootViewController.h"
#import "NMFriendsViewController.h"
#import "NMInfoViewController.h"


@implementation NinetyMinutesAppDelegate

@synthesize window;
@synthesize tabBarController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
    
    // Add the navigation controller's view to the window and display.
    [self.window addSubview:self.tabBarController.view];
    [self.window makeKeyAndVisible];
	
	if ([[NMAuthenticationManager sharedManager] isSessionValid]) {
		[self showRootController];
	} else {
		[self showLoginController];
	}

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


- (void)showLoginController {
	NMLoginViewController *controller = [[[NMLoginViewController alloc] init] autorelease];
	UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
	UIColor *color = [[UIColor alloc] initWithHue:1 
									   saturation:0 
									   brightness:0.5 
											alpha:1.0];
	[nav.navigationBar setTintColor:color];
	[self.tabBarController presentModalViewController:nav animated:YES];
}


- (void)showRootController {
	[self.tabBarController setViewControllers:nil];
	
	UIColor *color = [[UIColor alloc] initWithHue:1 
									   saturation:0 
									   brightness:0.5 
											alpha:1.0];
	
	// status controller
	NMRootViewController *root = [[(NMRootViewController *)[NMRootViewController alloc] init] autorelease];
	UINavigationController *rootNav = [[[UINavigationController alloc] initWithRootViewController:root] autorelease];
	[rootNav.tabBarItem setTitle:@"You"];
	
	// friends controller
	NMFriendsViewController *friends = [[[NMFriendsViewController alloc] init] autorelease];
	UINavigationController *friendsNav = [[[UINavigationController alloc] initWithRootViewController:friends] autorelease];
	[friendsNav.navigationBar setTintColor:color];
	[friendsNav.tabBarItem setTitle:@"Friends"];
	
	// info controller
	NMInfoViewController *info = [[[NMInfoViewController alloc] init] autorelease];
	UINavigationController *infoNav = [[[UINavigationController alloc] initWithRootViewController:info] autorelease];
	[infoNav.navigationBar setTintColor:color];
	[infoNav.tabBarItem setTitle:@"More"];
	
	[self.tabBarController setViewControllers:[NSArray arrayWithObjects:rootNav, friendsNav, infoNav, nil]];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[tabBarController release];
	[window release];
	[super dealloc];
}


@end

