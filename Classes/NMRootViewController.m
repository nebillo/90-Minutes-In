//
//  RootViewController.m
//  NinetyMinutes
//
//  Created by Nebil on 12/02/11.
//  Copyright 2011 Nebil Kriedi. All rights reserved.
//

#import "NMRootViewController.h"

#import "NMAuthenticationManager.h"
#import "NMUser.h"
#import "NMStatusUpdate.h"

#import "NMUpdateStatusRequest.h"
#import "NMGetStatusRequest.h"

#import "NMViewExtension.h"
#import <Three20Core/NSDateAdditions.h>

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "NMUserAnnotationView.h"
#import "NMCurrentUserAnnotationView.h"


@interface NMRootViewController ()

- (void)updateWithStatus:(NMStatusUpdate *)status;
- (void)updateWithLocation:(CLLocation *)location;

@end


@implementation NMRootViewController

- (id)init {
    if ((self = [super initWithNibName:@"NMRootViewController" bundle:nil])) {
        // Custom initialization
		_locationManager = [[CLLocationManager alloc] init];
		[_locationManager setDelegate:self];
		[_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    }
    return self;
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	NMUser *user = [[NMAuthenticationManager sharedManager] authenticatedUser];
	
	[self.navigationItem setTitle:@"90 Minutes In"];
	[self.navigationItem setRightBarButtonItem:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
																							  target:self 
																							  action:@selector(getStatus)] autorelease]];
		
	[self.userLabel setText:[NSString stringWithFormat:@"Hi %@, you are:", user.firstName]];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	NMUser *user = [[NMAuthenticationManager sharedManager] authenticatedUser];
	
	[self updateWithStatus:user.lastStatus];
	[self updateWithLocation:user.currentLocation];
}


#pragma mark Status

- (IBAction)getStatus {
	[self.view presentLoadingViewWithTitle:@"Getting your status…"];
	
	NMGetStatusRequest *update = [[[NMGetStatusRequest alloc] initWithRootURL:[NSURL URLWithString:kAPIRootURL]] autorelease];
	[update setDelegate:self];
	[update setUser:[[NMAuthenticationManager sharedManager] authenticatedUser]];
	[update start];
}


- (void)setStatus:(NSString *)status {
	[self.view presentLoadingViewWithTitle:@"Updating your status…"];
	
	NMUpdateStatusRequest *update = [[[NMUpdateStatusRequest alloc] initWithRootURL:[NSURL URLWithString:kAPIRootURL]] autorelease];
	[update setDelegate:self];
	[update setStatus:status];
	[update start];
}


- (IBAction)setStatusIn {
	[self setStatus:kNMStatusIn];
}


- (IBAction)setStatusOut {
	[self setStatus:kNMStatusOut];
}


- (void)updateRemainingTimeWithStatus:(NMStatusUpdate *)status {
	int minutes = floor(status.remainingTime / 60.0);
	int seconds = fmod(status.remainingTime, 60.0);
	[self.statusLabel setText:[NSString stringWithFormat:@"%@ for %d:%@%d more minutes", status.status, 
							   minutes, seconds >= 10 ? @"" : @"0", seconds]];
}


- (void)updateLastDateWithStatus:(NMStatusUpdate *)status {
	[self.statusLabel setText:[NSString stringWithFormat:@"You were '%@' until %@", 
							   status.status, [status.expirationDate formatRelativeTime]]];
}


- (void)updateWithStatus:(NMStatusUpdate *)status {
	// invalidate timers
	[_clock invalidate];
	_clock = nil;
	[_expirationClock invalidate];
	_expirationClock = nil;
	
	if (!status || status.expired) {
		// no status or status is expired
		[self.statusInButton setUserInteractionEnabled:YES];
		[self.statusOutButton setUserInteractionEnabled:YES];
		[self.statusInButton setSelected:NO];
		[self.statusOutButton setSelected:NO];
		
		if (status) {
			[self updateLastDateWithStatus:status];
			_clock = [NSTimer scheduledTimerWithTimeInterval:60.0 
													  target:self 
													selector:@selector(lastDateClock:) 
													userInfo:nil 
													 repeats:YES];
		} else {
			[self.statusLabel setText:@""];
		}
	} else {
		// there is a valid status
		[self.statusInButton setUserInteractionEnabled:NO];
		[self.statusOutButton setUserInteractionEnabled:NO];
		if ([status.status isEqualToString:kNMStatusIn]) {
			[self.statusInButton setSelected:YES];
			[self.statusOutButton setSelected:NO];
		} else {
			[self.statusOutButton setSelected:YES];
			[self.statusInButton setSelected:NO];
		}
		
		[self updateRemainingTimeWithStatus:status];
		
		_clock = [NSTimer scheduledTimerWithTimeInterval:1.0 
												  target:self 
												selector:@selector(remainingTimeClock:) 
												userInfo:nil 
												 repeats:YES];
		_expirationClock = [NSTimer scheduledTimerWithTimeInterval:status.remainingTime 
															target:self 
														  selector:@selector(expires:) 
														  userInfo:nil 
														   repeats:NO];
	}
}


- (void)remainingTimeClock:(NSTimer *)timer {
	NMUser *user = [[NMAuthenticationManager sharedManager] authenticatedUser];
	NMStatusUpdate *status = user.lastStatus;
	[self updateRemainingTimeWithStatus:status];
}


- (void)lastDateClock:(NSTimer *)timer {
	NMUser *user = [[NMAuthenticationManager sharedManager] authenticatedUser];
	NMStatusUpdate *status = user.lastStatus;
	[self updateLastDateWithStatus:status];
}


- (void)expires:(NSTimer *)timer {
	NMUser *user = [[NMAuthenticationManager sharedManager] authenticatedUser];
	NMStatusUpdate *status = user.lastStatus;
	[self updateWithStatus:status];
}


#pragma mark Location


- (void)getUserLocation {
	//[self.view presentLoadingViewWithTitle:@"Getting your location…"];
	[_locationManager startUpdatingLocation];
}


- (void)updateWithLocation:(CLLocation *)location {
	NMUser *user = [[NMAuthenticationManager sharedManager] authenticatedUser];
	
	[self.mapView removeAnnotations:self.mapView.annotations];
	[self.mapView addAnnotation:user];
	[self.mapView selectAnnotation:user animated:YES];
	
	if (location) {
		// TODO: add friends
		// TODO: show an area containing 10 nearest friends
	} else {
		[self.mapView setCenterCoordinate:user.coordinate animated:NO];
	}
}


#pragma mark MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	MKAnnotationView *view;
	
	NMUser *user = (NMUser *)annotation;
	NMUser *currentUser = [[NMAuthenticationManager sharedManager] authenticatedUser];
	
	if (user == currentUser) {
		view = [mapView dequeueReusableAnnotationViewWithIdentifier:@"current-user"];
		if (!view) {
			view = [[[NMCurrentUserAnnotationView alloc] initWithAnnotation:annotation 
															reuseIdentifier:@"current-user"] autorelease];
		}
	} else {
		view = [mapView dequeueReusableAnnotationViewWithIdentifier:@"user"];
		if (!view) {
			view = [[[NMUserAnnotationView alloc] initWithAnnotation:annotation 
													 reuseIdentifier:@"user"] autorelease];
		}
	}
	
	return view;
}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
	NMUser *currentUser = [[NMAuthenticationManager sharedManager] authenticatedUser];
	if (currentUser != (NMUser *)(view.annotation)) {
		return;
	}
	
	if (control.tag == kUserAnnotationInButton) {
		// set in
		[self setStatusIn];
	} else {
		// set out
		[self setStatusOut];
	}
}


#pragma mark -
#pragma mark NMRequestDelegate

- (void)request:(NMRequest *)request didFailWithError:(NSError *)error {
	if ([request isKindOfClass:[NMGetStatusRequest class]]) {
		[[[[UIAlertView alloc] initWithTitle:@"Get status error" 
									 message:[error localizedDescription] 
									delegate:nil 
						   cancelButtonTitle:@"Ok" 
						   otherButtonTitles:nil] autorelease] show];
	} else if ([request isKindOfClass:[NMUpdateStatusRequest class]]) {
		[[[[UIAlertView alloc] initWithTitle:@"Update status error" 
									 message:[error localizedDescription] 
									delegate:nil 
						   cancelButtonTitle:@"Ok" 
						   otherButtonTitles:nil] autorelease] show];
	}
	[self.view dismissStaticView];
}


- (void)request:(NMRequest *)request didFinishWithResponse:(id)response {
	
	NMStatusUpdate *status = response == [NSNull null] ? nil : (NMStatusUpdate *)response;
	[self updateWithStatus:status];
	[self.view dismissStaticView];
	
	if ([request isKindOfClass:[NMGetStatusRequest class]]) {
		// get the location
		[self getUserLocation];
	} else if ([request isKindOfClass:[NMUpdateStatusRequest class]]) {
		//
		[[[[UIAlertView alloc] initWithTitle:@"Status updated" 
									 message:[NSString stringWithFormat:@"You'll be %@ for 90 minutes", status.status] 
									delegate:nil 
						   cancelButtonTitle:@"Ok" 
						   otherButtonTitles:nil] autorelease] show];
	}
}


#pragma mark -
#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation {
	[self.view dismissStaticView];
	
	NMUser *user = [[NMAuthenticationManager sharedManager] authenticatedUser];
	[user setCurrentLocation:newLocation];
	[self updateWithLocation:newLocation];
}


- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error {
	[self.view dismissStaticView];
}


#pragma mark -
#pragma mark Memory management

- (void)viewDidUnload {
	[_clock invalidate];
	_clock = nil;
	[_expirationClock invalidate];
	_expirationClock = nil;
	self.statusInButton = nil;
	self.statusOutButton = nil;
	self.userLabel = nil;
	self.statusLabel = nil;
	[self.mapView setDelegate:nil];
	self.mapView = nil;
	[super viewDidUnload];
}


- (void)dealloc {
	[_locationManager stopUpdatingLocation];
	[_locationManager setDelegate:nil];
	[_locationManager release];
	[_clock invalidate];
	[_expirationClock invalidate];
	self.statusInButton = nil;
	self.statusOutButton = nil;
	self.userLabel = nil;
	self.statusLabel = nil;
	[self.mapView setDelegate:nil];
	self.mapView = nil;
    [super dealloc];
}


@synthesize statusInButton;
@synthesize statusOutButton;
@synthesize userLabel;
@synthesize statusLabel;
@synthesize mapView;

@end

