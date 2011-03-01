//
//  NMUserViewController.h
//  NinetyMinutes
//
//  Created by Nebil on 28/02/11.
//  Copyright 2011 Nebil Kriedi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NMUser;
@class TTImageView;


@interface NMUserViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
	NMUser *_user;
	UITableView *_tableView;
}

- (id)initWithUser:(NMUser *)user;
@property (nonatomic, readonly) NMUser *user;

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet TTImageView *pictureView;
@property (nonatomic, retain) IBOutlet UILabel *userNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *lastStatusLabel;

@end
