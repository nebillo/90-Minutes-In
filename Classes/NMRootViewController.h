//
//  RootViewController.h
//  NinetyMinutes
//
//  Created by Nebil on 12/02/11.
//  Copyright 2011 Nebil Kriedi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMRequest.h"


@interface NMRootViewController : UIViewController <NMRequestDelegate>
{
}

@property (nonatomic, retain) IBOutlet UIButton *statusInButton;
@property (nonatomic, retain) IBOutlet UIButton *statusOutButton;

@property (nonatomic, retain) IBOutlet UILabel *userLabel;

- (IBAction)getStatus;
- (IBAction)setStatusIn;
- (IBAction)setStatusOut;

@end
