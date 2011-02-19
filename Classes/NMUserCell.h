//
//  NMUserCell.h
//  NinetyMinutes
//
//  Created by Nebil on 19/02/11.
//  Copyright 2011 Nebil Kriedi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NMUser;
@class TTImageView;


extern const CGFloat kUserCellHeight;
extern NSString * const kUserCellIdentifier;


@interface NMUserCell : UITableViewCell 
{
	NMUser *_user;
}

+ (id)cellFromNib;
@property (nonatomic, retain) NMUser *user;

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet TTImageView *userPicture;

@property (nonatomic, retain) IBOutlet UIImageView *statusImage;
@property (nonatomic, retain) IBOutlet UILabel *statusLocation;
@property (nonatomic, retain) IBOutlet UILabel *statusDate;


@end
