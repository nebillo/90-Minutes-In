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
#import "NMFriendsRequest.h"

#import "NMViewExtension.h"
#import <Three20Core/NSDateAdditions.h>

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "NMUserAnnotationView.h"
#import "NMCurrentUserAnnotationView.h"
#import "NMMapOverlay.h"


@interface NMRootViewController ()

- (void)updateCurrentUserPinAnimated:(BOOL)animated;
- (void)updateUserAnnotationStatusAnimated:(BOOL)animated;
- (void)scrollMapToUserFixedLocationAnimated:(BOOL)animated;
- (void)updateFriendsOnMapAnimated:(BOOL)animated;

- (void)updateInterface;
- (void)setClockEnabled:(BOOL)enabled;

@end


@implementation NMRootViewController

- (id)init {
    if ((self = [super initWithNibName:@"NMRootViewController" bundle:nil])) {
        // Custom initialization
		_user = [[[NMAuthenticationManager sharedManager] authenticatedUser] retain];
		
		_locationManager = [[CLLocationManager alloc] init];
		[_locationManager setDelegate:self];
		[_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    }
    return self;
}


#pragma mark -
#pragma mark View lifecycle

static CLLocationDistance defaultRadius = 10000;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self.navigationItem setRightBarButtonItem:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
																							  target:self 
																							  action:@selector(updateData)] autorelease]];
	NMMapOverlay *overlay = [[[NMMapOverlay alloc] init] autorelease];
	[self.mapView addOverlay:overlay];
	[self updateCurrentUserPinAnimated:NO];
	[self updateFriendsOnMapAnimated:NO];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	if (_user.lastStatus) {
		[self setClockEnabled:YES];
		
		if (_user.lastStatus.expired && !_user.currentLocation) {
			[self updateUserLocation];
		} else {
			[self updateUserAnnotationStatusAnimated:NO];
		}
	} else {
		// get the status
		[self updateData];
	}
	
	[self updateInterface];
}


- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self setClockEnabled:NO];
}


- (void)updateCurrentUserPinAnimated:(BOOL)animated {
	if ([self.mapView.annotations containsObject:_user]) {
		[self.mapView removeAnnotation:_user];
	}
	[self.mapView addAnnotation:_user];
	
	[self scrollMapToUserFixedLocationAnimated:animated];
	
	if (_user.currentLocation || _user.lastStatus.location) {
		[self.mapView setScrollEnabled:YES];
		[self.mapView setZoomEnabled:YES];
	} else {
		[self.mapView setScrollEnabled:NO];
		[self.mapView setZoomEnabled:NO];
	}
}


- (void)updateUserAnnotationStatusAnimated:(BOOL)animated {
	// update callout
	[self.mapView deselectAnnotation:_user animated:NO];
	[self.mapView selectAnnotation:_user animated:animated];
	
	// update annotation
	NMUserAnnotationView *view = (NMUserAnnotationView *)[self.mapView viewForAnnotation:_user];
	[view updateStatusWithUser:_user];
}


- (void)scrollMapToUserFixedLocationAnimated:(BOOL)animated {
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(_user.coordinate, defaultRadius, defaultRadius);
	[self.mapView setRegion:[self.mapView regionThatFits:region] animated:animated];
}


- (void)updateFriendsOnMapAnimated:(BOOL)animated {
	NSMutableArray *annotationsToRemove = [[NSMutableArray alloc] initWithArray:self.mapView.annotations];
	[annotationsToRemove removeObject:_user];
	[self.mapView removeAnnotations:annotationsToRemove];
	[annotationsToRemove release];
	
	for (NMUser *friend in _user.friends) {
		if (friend.lastStatus && friend.lastStatus.location) {
			// registered user with a localized status
			[self.mapView addAnnotation:friend];
		}
	}
}


- (void)setBarColorWithHue:(CGFloat)hue saturation:(CGFloat)saturation {
	UIColor *color = [[UIColor alloc] initWithHue:hue 
									   saturation:saturation 
									   brightness:0.5 
											alpha:1.0];
	[self.navigationController.navigationBar setTintColor:color];
	[color release];
}


- (void)updateInterface {
	NMStatusUpdate *status = _user.lastStatus;
	if (status) {
		if (_user.lastStatus.expired) {
			[self.navigationItem setTitle:[NSString stringWithFormat:@"%@ %@", status.status, [status.expirationDate formatRelativeTime]]];
			[self setBarColorWithHue:1 saturation:0];
		} else {
			int minutes = floor(status.remainingTime / 60.0);
			int seconds = fmod(status.remainingTime, 60.0);
			[self.navigationItem setTitle:[NSString stringWithFormat:@"%d:%@%d minutes %@", minutes, seconds >= 10 ? @"" : @"0", seconds, status.status]];
			
			float hue, saturation;
			if ([status.status isEqualToString:kNMStatusIn]) {
				hue = 128.0 / 360.0; // green
			} else {
				hue = 360.0 / 360.0; // red
			}
			
			NSTimeInterval elapsed = - [status.createdAt timeIntervalSinceNow];
			NSTimeInterval total = [status.expirationDate timeIntervalSinceDate:status.createdAt];
			saturation = 1.0 - elapsed / total;
			[self setBarColorWithHue:hue saturation:saturation];
		}
	} else {
		[self.navigationItem setTitle:@"You"];
		[self setBarColorWithHue:1 saturation:0];
	}
}


- (void)setClockEnabled:(BOOL)enabled {
	[_clock invalidate];
	_clock = nil;
	[_expirationClock invalidate];
	_expirationClock = nil;
	
	if (!enabled || !_user.lastStatus) {
		return;
	}
	
	if (_user.lastStatus.expired) {
		_clock = [NSTimer scheduledTimerWithTimeInterval:60.0 
												  target:self 
												selector:@selector(updateInterface) 
												userInfo:nil 
												 repeats:YES];
	} else {
		_clock = [NSTimer scheduledTimerWithTimeInterval:1.0 
												  target:self 
												selector:@selector(updateInterface) 
												userInfo:nil 
												 repeats:YES];
		_expirationClock = [NSTimer scheduledTimerWithTimeInterval:_user.lastStatus.remainingTime 
															target:self 
														  selector:@selector(expires:) 
														  userInfo:nil 
														   repeats:NO];
	}
}


- (void)expires:(NSTimer *)timer {
	// update the clock
	[self setClockEnabled:YES];
	[self updateInterface];
	[self updateUserAnnotationStatusAnimated:NO];
	[self updateUserLocation];
}


#pragma mark Actions

- (void)updateData {
	[self.view presentLoadingViewWithTitle:@"Loading…"];
	
	NMGetStatusRequest *update = [[[NMGetStatusRequest alloc] initWithRootURL:[NSURL URLWithString:kAPIRootURL]] autorelease];
	[update setDelegate:self];
	[update setUser:_user];
	[update start];
	
	[self updateFriends];
}


- (void)updateUserLocation {
	[self.view presentLoadingViewWithTitle:@"Locating…"];
	[_locationManager startUpdatingLocation];
}


- (void)updateFriends {
	// get friends
	NMFriendsRequest *friendsRequest = [[[NMFriendsRequest alloc] initWithRootURL:[NSURL URLWithString:kAPIRootURL]] autorelease];
	[friendsRequest setUser:_user];
	[friendsRequest setDelegate:self];
	[friendsRequest start];
}


- (void)setStatus:(NSString *)status {
	[self.view presentLoadingViewWithTitle:@"Updating…"];
	
	NMUpdateStatusRequest *update = [[[NMUpdateStatusRequest alloc] initWithRootURL:[NSURL URLWithString:kAPIRootURL]] autorelease];
	[update setDelegate:self];
	[update setStatus:status];
	[update setLocation:_user.currentLocation];
	[update start];
}


- (IBAction)setStatusIn {
	[self setStatus:kNMStatusIn];
}


- (IBAction)setStatusOut {
	[self setStatus:kNMStatusOut];
}


#pragma mark MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	MKAnnotationView *view;
	
	NMUser *user = (NMUser *)annotation;
	
	if (user == _user) {
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
	
	[(NMUserAnnotationView *)view updateStatusWithUser:user];
	
	return view;
}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
	if (control.tag == kUserAnnotationDetailButton) {
		// TODO: open user
	} else if (control.tag == kUserAnnotationInButton) {
		// set in
		[self setStatusIn];
	} else {
		// set out
		[self setStatusOut];
	}
}


- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    if ([overlay isKindOfClass:[NMMapOverlay class]]) {
		MKPolygon *proPolygon = [(NMMapOverlay *)overlay polygon];
		MKPolygonView *aView = [[[MKPolygonView alloc] initWithPolygon:proPolygon] autorelease];
	   
		aView.fillColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
		//aView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
		//aView.lineWidth = 3;
		return aView;
	}
    return nil;
}


#pragma mark -
#pragma mark NMRequestDelegate

- (void)request:(NMRequest *)request didFailWithError:(NSError *)error {
	if ([request isKindOfClass:[NMGetStatusRequest class]]) {
		[[[[UIAlertView alloc] initWithTitle:@"Cannot get your data" 
									 message:[error localizedDescription] 
									delegate:nil 
						   cancelButtonTitle:@"Ok" 
						   otherButtonTitles:nil] autorelease] show];
		[self.view dismissStaticView];
	} else if ([request isKindOfClass:[NMUpdateStatusRequest class]]) {
		[[[[UIAlertView alloc] initWithTitle:@"Cannot update your status" 
									 message:[error localizedDescription] 
									delegate:nil 
						   cancelButtonTitle:@"Ok" 
						   otherButtonTitles:nil] autorelease] show];
		[self.view dismissStaticView];
	}
}


- (void)request:(NMRequest *)request didFinishWithResponse:(id)response {
	
	if ([request isKindOfClass:[NMGetStatusRequest class]]) {
		NMStatusUpdate *status = response == [NSNull null] ? nil : (NMStatusUpdate *)response;
		[self.view dismissStaticView];
		
		// update user annotation
		[self updateInterface];
		[self setClockEnabled:YES];
		
		if (!status || status.expired) {
			[self updateUserLocation];
		} else {
			[self updateCurrentUserPinAnimated:YES];
			[self scrollMapToUserFixedLocationAnimated:YES];
			[self updateUserAnnotationStatusAnimated:YES];
		}
		
	} else if ([request isKindOfClass:[NMUpdateStatusRequest class]]) {
		NMStatusUpdate *status = response == [NSNull null] ? nil : (NMStatusUpdate *)response;
		[self.view dismissStaticView];
		
		// update the annotation
		[self updateInterface];
		[self setClockEnabled:YES];
		[self updateUserAnnotationStatusAnimated:YES];
		[[[[UIAlertView alloc] initWithTitle:@"Status updated" 
									 message:[NSString stringWithFormat:@"You'll be %@ for 90 minutes", status.status] 
									delegate:nil 
						   cancelButtonTitle:@"Ok" 
						   otherButtonTitles:nil] autorelease] show];
		
	} else if ([request isKindOfClass:[NMFriendsRequest class]]) {
		// update friends on map
		[self updateFriendsOnMapAnimated:YES];
	}
}


#pragma mark -
#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation {
	[manager stopUpdatingLocation];
	
	[self.view dismissStaticView];
	
	// updating current location
	[_user setCurrentLocation:newLocation];
	[self updateCurrentUserPinAnimated:YES];
	[self updateUserAnnotationStatusAnimated:YES];
}


- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error {
	NSLog(@"error updating location: %@", [error localizedDescription]);
	[manager stopUpdatingLocation];
	[self.view dismissStaticView];
}


#pragma mark -
#pragma mark Memory management

- (void)viewDidUnload {
	[self setClockEnabled:NO];
	[self.mapView setDelegate:nil];
	self.mapView = nil;
	[super viewDidUnload];
}


- (void)dealloc {
	[_user release];
	[_locationManager stopUpdatingLocation];
	[_locationManager setDelegate:nil];
	[_locationManager release];
	[_clock invalidate];
	[_expirationClock invalidate];
	[self.mapView setDelegate:nil];
	self.mapView = nil;
    [super dealloc];
}


@synthesize mapView;

@end

