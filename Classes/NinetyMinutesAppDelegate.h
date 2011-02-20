//
//  NinetyMinutesAppDelegate.h
//  NinetyMinutes
//
//  Created by Nebil on 12/02/11.
//  Copyright 2011 Nebil Kriedi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NinetyMinutesAppDelegate : NSObject <UIApplicationDelegate> 
{
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

- (void)showLoginController;
- (void)showRootController;

@end

