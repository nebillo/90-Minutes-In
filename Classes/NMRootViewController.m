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
#import <Three20UI/TTImageView.h>

#import <CoreLocation/CoreLocation.h>

#import "NMUserViewController.h"
#import <QuartzCore/QuartzCore.h>


@interface NMRootViewController ()

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

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self.navigationItem setTitle:@"You"];
	[self.navigationItem setBackBarButtonItem:[[[UIBarButtonItem alloc] initWithTitle:@"You" 
																				style:UIBarButtonItemStyleBordered 
																			   target:nil 
																			   action:nil] autorelease]];
	[self.navigationItem setRightBarButtonItem:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
																							  target:self 
																							  action:@selector(updateData)] autorelease]];
	
	[self.userLabel setText:[NSString stringWithFormat:@"Hi %@!", _user.firstName]];
	[self.pictureView setUrlPath:_user.picture];
	[self.pictureView.layer setCornerRadius:8.0f];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	[self updateInterface];
	
	if (_user.lastStatus) {
		[self setClockEnabled:YES];
		
		if (_user.lastStatus.expired && !_user.currentLocation) {
			[self updateUserLocation];
		}
	} else {
		// get the status
		[self updateData];
	}
}


- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self setClockEnabled:NO];
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
	
	[self.inButton setAlpha:1];
	[self.outButton setAlpha:1];
	[self.inButton setEnabled:YES];
	[self.outButton setEnabled:YES];
	
	if (status) {
		if (_user.lastStatus.expired) {
			[self.statusLabel setText:[NSString stringWithFormat:@"You were %@ %@", 
									   status.status, 
									   [status.expirationDate formatRelativeTime]]];
			
			[self setBarColorWithHue:1 saturation:0];
		} else {
			int minutes = floor(status.remainingTime / 60.0);
			int seconds = fmod(status.remainingTime, 60.0);
			[self.statusLabel setText:[NSString stringWithFormat:@"%@ for %d:%@%d minutes", status.status, 
									   minutes, 
									   seconds >= 10 ? @"" : @"0", seconds]];
			
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
			
			[self.inButton setEnabled:NO];
			[self.outButton setEnabled:NO];
			if ([status.status isEqualToString:kNMStatusIn]) {
				[self.outButton setAlpha:0.35];
			} else {
				[self.inButton setAlpha:0.35];
			}
		}
	} else {
		[self.statusLabel setText:@"are you in or out?"];
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
	[self updateUserLocation];
}


#pragma mark Actions

- (void)updateData {
	[self.view presentLoadingViewWithTitle:@"Loading…"];
	
	[self setClockEnabled:NO];
	[self.statusLabel setText:@"..."];
	
	NMGetStatusRequest *update = [[[NMGetStatusRequest alloc] initWithRootURL:[NSURL URLWithString:kAPIRootURL]] autorelease];
	[update setDelegate:self];
	[update setUser:_user];
	[update start];
}


- (void)updateUserLocation {
	[_locationManager startUpdatingLocation];
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


- (IBAction)showTimeline {
	NMUserViewController *detailViewController = [(NMUserViewController *)[NMUserViewController alloc] initWithUser:_user];
	[self.navigationController pushViewController:detailViewController animated:YES];
	[detailViewController release];	
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
		}
		
	} else if ([request isKindOfClass:[NMUpdateStatusRequest class]]) {
		NMStatusUpdate *status = response == [NSNull null] ? nil : (NMStatusUpdate *)response;
		[self.view dismissStaticView];
		
		// update the annotation
		[self updateInterface];
		[self setClockEnabled:YES];
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
	
	// updating current location
	[_user setCurrentLocation:newLocation];
}


- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error {
	NSLog(@"error updating location: %@", [error localizedDescription]);
	[manager stopUpdatingLocation];
}


#pragma mark -
#pragma mark Memory management

@synthesize inButton;
@synthesize outButton;
@synthesize userLabel;
@synthesize statusLabel;
@synthesize pictureView;


- (void)viewDidUnload {
	[self setClockEnabled:NO];
	self.inButton = nil;
	self.outButton = nil;
	self.statusLabel = nil;
	self.userLabel = nil;
	self.pictureView = nil;
	[super viewDidUnload];
}


- (void)dealloc {
	self.inButton = nil;
	self.outButton = nil;
	self.statusLabel = nil;
	self.userLabel = nil;
	self.pictureView = nil;
	
	[_user release];
	[_locationManager stopUpdatingLocation];
	[_locationManager setDelegate:nil];
	[_locationManager release];
	[_clock invalidate];
	[_expirationClock invalidate];
    [super dealloc];
}

@end

