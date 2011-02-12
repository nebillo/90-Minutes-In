//
//  NMLoginViewController.h
//  NinetyMinutes
//
//  Created by Nebil on 12/02/11.
//  Copyright 2011 Nebil Kriedi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMAuthenticationManager.h"


@interface NMLoginViewController : UIViewController <NMAuthenticationManagerDelegate, UITextFieldDelegate> 
{
}

@property (nonatomic, retain) IBOutlet UITextField *usernameField;
@property (nonatomic, retain) IBOutlet UITextField *passwordField;
@property (nonatomic, retain) IBOutlet UIButton *signinButton;

- (IBAction)signin;
- (IBAction)signup;

@end
