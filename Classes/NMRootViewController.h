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
#import <MapKit/MKMapView.h>

@class NMUser;
@class CLLocationManager;


@interface NMRootViewController : UIViewController <NMRequestDelegate, CLLocationManagerDelegate, MKMapViewDelegate>
{
	NMUser *_user;
	CLLocationManager *_locationManager;
	NSTimer *_clock;
	NSTimer *_expirationClock;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;

- (void)updateData;
- (void)updateUserLocation;
- (void)updateFriends;

- (IBAction)setStatusIn;
- (IBAction)setStatusOut;

@end
