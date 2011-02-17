//
//  RootViewController.h
//  NinetyMinutes
//
//  Created by Nebil on 12/02/11.
//  Copyright 2011 Nebil Kriedi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMUser.h"


@interface NMRootViewController : UIViewController 
{
}

- (id)initWithUser:(NMUser *)user;
@property (nonatomic, retain) NMUser *user;

@property (nonatomic, retain) IBOutlet UISegmentedControl *statusControl;
@property (nonatomic, retain) IBOutlet UILabel *userLabel;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

- (IBAction)updateStatus;

@end
