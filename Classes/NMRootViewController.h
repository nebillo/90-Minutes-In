//
//  RootViewController.h
//  NinetyMinutes
//
//  Created by Nebil on 12/02/11.
//  Copyright 2011 Nebil Kriedi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMRequest.h"
#import <CoreLocation/CLLocationManagerDelegate.h>

@class NMUser;
@class CLLocationManager;
@class TTImageView;


@interface NMRootViewController : UIViewController <NMRequestDelegate, CLLocationManagerDelegate>
{
	NMUser *_user;
	CLLocationManager *_locationManager;
	NSTimer *_clock;
	NSTimer *_expirationClock;
}

@property (nonatomic, retain) IBOutlet UIButton *inButton;
@property (nonatomic, retain) IBOutlet UIButton *outButton;
@property (nonatomic, retain) IBOutlet UILabel *userLabel;
@property (nonatomic, retain) IBOutlet UILabel *statusLabel;
@property (nonatomic, retain) IBOutlet TTImageView *pictureView;

- (void)updateData;
- (void)updateUserLocation;

- (IBAction)setStatusIn;
- (IBAction)setStatusOut;
- (IBAction)showTimeline;

@end
