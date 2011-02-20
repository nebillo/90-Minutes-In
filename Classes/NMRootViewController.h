//
//  RootViewController.h
//  NinetyMinutes
//
//  Created by Nebil on 12/02/11.
//  Copyright 2011 Nebil Kriedi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMUser.h"
#import "NMRequest.h"


@interface NMRootViewController : UIViewController <NMRequestDelegate>
{
	NSArray *_friends;
	NSArray *_filteredFriends;
	NSUInteger _friendsFilter;
	NSArray *_tableIndex;
}

- (id)initWithUser:(NMUser *)user;
@property (nonatomic, retain) NMUser *user;

@property (nonatomic, retain) IBOutlet UIButton *statusInButton;
@property (nonatomic, retain) IBOutlet UIButton *statusOutButton;
@property (nonatomic, retain) IBOutlet UIView *statusControl;

@property (nonatomic, retain) IBOutlet UILabel *userLabel;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UISegmentedControl *filterControl;

- (IBAction)getStatus;
- (IBAction)setStatusIn;
- (IBAction)setStatusOut;
- (IBAction)updateFriends;

- (IBAction)filterFriends:(UISegmentedControl *)control;

@end
