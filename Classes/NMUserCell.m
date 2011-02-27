//
//  NMUserCell.m
//  NinetyMinutes
//
//  Created by Nebil on 19/02/11.
//  Copyright 2011 Nebil Kriedi. All rights reserved.
//

#import "NMUserCell.h"
#import "NMUser.h"
#import "NMStatusUpdate.h"
#import <Three20UI/TTImageView.h>
#import <Three20Core/NSDateAdditions.h>


const CGFloat kUserCellHeight = 50.0f;
NSString * const kUserCellIdentifier = @"user_cell_id";


@implementation NMUserCell

+ (id)cellFromNib {
	return [[[NSBundle mainBundle] loadNibNamed:@"NMUserCell" owner:nil options:nil] objectAtIndex:0];
}


- (void)prepareForReuse {
	[self.userPicture setUrlPath:nil];
}


- (void)setUser:(NMUser *)user {
	if (user != _user) {
		[_user release];
		_user = [user retain];
		
		[self.nameLabel setText:user.name];
	}
	
	[self.userPicture setUrlPath:user.picture];
	[self updateStatus];
}

- (void)updateStatus {
	NMStatusUpdate *status = _user.lastStatus;
	
	if (status) {
		if (status.expired) {
			// expired status
			[self.statusImage setHidden:YES];
			[self.statusDate setText:[NSString stringWithFormat:@"%@ %@", status.status, [status.expirationDate formatRelativeTime]]];
		} else {
			// valid status
			if ([status.status isEqualToString:kNMStatusIn]) {
				// green for in
				[self.statusImage setBackgroundColor:[UIColor greenColor]];
			} else {
				// red for out
				[self.statusImage setBackgroundColor:[UIColor redColor]];
			}
			[self.statusImage setHidden:NO];
			
			int minutes = ceil(status.remainingTime / 60.0);
			NSString *format = minutes == 1 ? @"%@ for %d more minute" : @"%@ for %d more minutes";
			[self.statusDate setText:[NSString stringWithFormat:format, status.status, minutes]];
		}
		[self.statusDate setHidden:NO];
	} else {
		// no status
		[self.statusImage setHidden:YES];
		[self.statusDate setHidden:YES];
	}
}


- (void)dealloc {
	[_user release];
	self.nameLabel = nil;
	self.userPicture = nil;
	self.statusImage = nil;
	self.statusLocation = nil;
	self.statusDate = nil;
    [super dealloc];
}

@synthesize user = _user;

@synthesize nameLabel;
@synthesize userPicture;
@synthesize statusImage;
@synthesize statusLocation;
@synthesize statusDate;

@end
