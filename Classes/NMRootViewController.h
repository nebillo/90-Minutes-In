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

@class MKMapView;
@class CLLocationManager;


@interface NMRootViewController : UIViewController <NMRequestDelegate, CLLocationManagerDelegate>
{
	CLLocationManager *_locationManager;
	NSTimer *_clock;
	NSTimer *_expirationClock;
}

@property (nonatomic, retain) IBOutlet UIButton *statusInButton;
@property (nonatomic, retain) IBOutlet UIButton *statusOutButton;

@property (nonatomic, retain) IBOutlet UILabel *userLabel;
@property (nonatomic, retain) IBOutlet UILabel *statusLabel;

@property (nonatomic, retain) IBOutlet MKMapView *mapView;

- (void)getUserLocation;
- (IBAction)getStatus;
- (IBAction)setStatusIn;
- (IBAction)setStatusOut;

@end
