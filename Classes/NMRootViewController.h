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

@class CLLocationManager;


@interface NMRootViewController : UIViewController <NMRequestDelegate, CLLocationManagerDelegate, MKMapViewDelegate>
{
	CLLocationManager *_locationManager;
	NSTimer *_clock;
	NSTimer *_expirationClock;
	UIView *_overlay;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;

- (void)getUserLocation;
- (IBAction)getStatus;
- (IBAction)setStatusIn;
- (IBAction)setStatusOut;

@end
