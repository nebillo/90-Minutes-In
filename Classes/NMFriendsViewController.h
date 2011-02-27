//
//  NMFriendsViewController.h
//  NinetyMinutes
//
//  Created by Nebil on 20/02/11.
//  Copyright 2011 Nebil Kriedi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMRequest.h"

@class NMUser;


@interface NMFriendsViewController : UIViewController <NMRequestDelegate, UITableViewDelegate, UITableViewDataSource>
{
	NMUser *_user;
	NSArray *_filteredFriends;
	NSUInteger _friendsFilter;
	NSArray *_tableIndex;
	NSTimer *_clock;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UISegmentedControl *filterControl;

- (IBAction)updateFriends;
- (IBAction)filterFriends:(UISegmentedControl *)control;

@end
