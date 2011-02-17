//
//  NMLoginViewController.h
//  NinetyMinutes
//
//  Created by Nebil on 12/02/11.
//  Copyright 2011 Nebil Kriedi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMAuthenticationManager.h"


@interface NMLoginViewController : UIViewController <NMAuthenticationManagerDelegate> 
{
}

@property (nonatomic, retain) IBOutlet UIButton *signinButton;

- (IBAction)signin;

@end
