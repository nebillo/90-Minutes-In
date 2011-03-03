//
//  NMFriendsViewController.m
//  NinetyMinutes
//
//  Created by Nebil on 20/02/11.
//  Copyright 2011 Nebil Kriedi. All rights reserved.
//

#import "NMFriendsViewController.h"

#import "NMAuthenticationManager.h"
#import "NMUser.h"
#import "NMStatusUpdate.h"

#import "NMFriendsRequest.h"
#import "NMViewExtension.h"
#import "NMUserCell.h"

#import "NMUserViewController.h"

#import "NMUserAnnotationView.h"
#import <MapKit/MKUserLocation.h>
#import <MapKit/MKAnnotation.h>


@implementation NMFriendsViewController

- (id)init {
    if ((self = [super initWithNibName:@"NMFriendsViewController" bundle:nil])) {
        // Custom initialization
		_user = [[[NMAuthenticationManager sharedManager] authenticatedUser] retain];
		_friendsFilter = 0;
    }
    return self;
}


- (void)filterFriendsWithFilter:(NSString *)filter {
	NSMutableArray *filtered = [NSMutableArray array];
	NSMutableArray *locationOnly = [NSMutableArray array];
	
	for (NMUser *user in _user.friends) {
		if (!filter || (!user.lastStatus.expired && [user.lastStatus.status isEqualToString:filter])) {
			[filtered addObject:user];
			
			if (user.lastStatus.location) {
				[locationOnly addObject:user];
			}
		}
	}
	
	[_filteredFriends release];
	_filteredFriends = [filtered retain];
	
	[_mapFilteredFriends release];
	_mapFilteredFriends = [locationOnly retain];
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self.navigationItem setTitleView:self.filterControl];
	[self.navigationItem setRightBarButtonItem:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
																							  target:self 
																							  action:@selector(updateFriends)] autorelease]];
	[self.navigationItem setBackBarButtonItem:[[[UIBarButtonItem alloc] initWithTitle:@"Friends" 
																				style:UIBarButtonItemStyleBordered 
																			   target:nil 
																			   action:nil] autorelease]];
	
	[self.navigationItem setLeftBarButtonItem:[[[UIBarButtonItem alloc] initWithTitle:@"Map" 
																				style:UIBarButtonItemStyleBordered 
																			   target:self 
																			   action:@selector(changeView:)] autorelease]];
	// setting up views
	[self.tableView setRowHeight:kUserCellHeight];
	[self.view setBackgroundColor:[UIColor viewFlipsideBackgroundColor]];
	
	// restoring visible view
	if (_showingMap) {
		[self.mapContainer setFrame:self.contentView.bounds];
		[self.contentView addSubview:self.mapContainer];
	} else {
		[self.tableContainer setFrame:self.contentView.bounds];
		[self.contentView addSubview:self.tableContainer];
	}
	
	// restoring filter position and update source
	[self.filterControl setSelectedSegmentIndex:_friendsFilter];
	
	// setup clock
	_clock = [NSTimer scheduledTimerWithTimeInterval:60.0 
											  target:self
											selector:@selector(refreshInterface) 
											userInfo:nil repeats:YES];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	if (!_user.friends) {
		[self updateFriends];
	}
	
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
}


- (void)showView:(UIView *)destination fromView:(UIView *)origin animation:(UIViewAnimationTransition)transition {
	[destination setFrame:self.contentView.bounds];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationTransition:transition forView:self.contentView cache:YES];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.5];
	
	[origin removeFromSuperview];
	[self.contentView addSubview:destination];
	
	[UIView commitAnimations];
}


- (void)changeView:(UIBarButtonItem *)sender {
	if (_showingMap) {
		// show list
		[self showView:self.tableContainer 
			  fromView:self.mapContainer 
			 animation:UIViewAnimationTransitionFlipFromLeft];
		[sender setTitle:@"Map"];
		_showingMap = NO;
	} else {
		// show map
		[self showView:self.mapContainer 
			  fromView:self.tableContainer
			 animation:UIViewAnimationTransitionFlipFromRight];
		[sender setTitle:@"List"];
		_showingMap = YES;
	}
}


- (void)showAllFriendsOnMapAnimated:(BOOL)animated {
	if (_mapFilteredFriends.count == 0) {
		return;
	}
	
	double minLat = +90;
	double maxLat = -90;
	double minLng = +180;
	double maxLng = -180;
	
	for (id<MKAnnotation> annotation in _mapFilteredFriends) {
		minLat = MIN(annotation.coordinate.latitude, minLat);
		maxLat = MAX(annotation.coordinate.latitude, maxLat);
		minLng = MIN(annotation.coordinate.longitude, minLng);
		maxLng = MAX(annotation.coordinate.longitude, maxLng);
	}
	
	CLLocationCoordinate2D coordinate;
	coordinate.latitude = (maxLat + minLat) / 2.0;
	coordinate.longitude = (maxLng + minLng) / 2.0;
	
	MKCoordinateSpan span = MKCoordinateSpanMake(maxLat - minLat, maxLng - minLng);
	span.latitudeDelta += 0.02;
	span.longitudeDelta += 0.01;
	
	MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, span);	
	[self.mapView setRegion:[self.mapView regionThatFits:region] animated:animated];
}


- (IBAction)updateFriends {
	[self.view presentLoadingViewWithTitle:@"Updating your friends…"];
	
	NMFriendsRequest *update = [[[NMFriendsRequest alloc] initWithRootURL:[NSURL URLWithString:kAPIRootURL]] autorelease];
	[update setDelegate:self];
	[update setUser:_user];
	[update start];
}


- (IBAction)filterFriends:(UISegmentedControl *)control {
	_friendsFilter = control.selectedSegmentIndex;
	
	if (_friendsFilter == 0) {
		[self filterFriendsWithFilter:nil];
	} else if (_friendsFilter == 1) {
		[self filterFriendsWithFilter:kNMStatusIn];
	} else if (_friendsFilter == 2) {
		[self filterFriendsWithFilter:kNMStatusOut];
	}
	
	[self.tableView reloadData];
	
	NSMutableArray *toRemove = [NSMutableArray arrayWithArray:self.mapView.annotations];
	if (self.mapView.userLocation) {
		[toRemove removeObject:self.mapView.userLocation];
	}
	[self.mapView removeAnnotations:toRemove];
	[self.mapView addAnnotations:_mapFilteredFriends];
	
	[self showAllFriendsOnMapAnimated:YES];
}


- (void)refreshInterface {
	NSArray *cells = [self.tableView visibleCells];
	[cells makeObjectsPerformSelector:@selector(updateStatus)];
	
	for (NMUser *user in _mapFilteredFriends) {
		NMUserAnnotationView *view = (NMUserAnnotationView *)[self.mapView viewForAnnotation:user];
		if (view) {
			[view updateStatusWithUser:user];
		}
	}
}


#pragma mark -
#pragma mark NMRequestDelegate

- (void)request:(NMRequest *)request didFailWithError:(NSError *)error {
	[[[[UIAlertView alloc] initWithTitle:@"Update friends error" 
								 message:[error localizedDescription] 
								delegate:nil 
					   cancelButtonTitle:@"Ok" 
					   otherButtonTitles:nil] autorelease] show];
	
	[self.view dismissStaticView];
}


- (void)request:(NMRequest *)request didFinishWithResponse:(id)response {
	[self filterFriends:self.filterControl];
	
	[self.view dismissStaticView];
}


#pragma mark -
#pragma mark Table view data source

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _filteredFriends.count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NMUserCell *cell = (NMUserCell *)[tableView dequeueReusableCellWithIdentifier:kUserCellIdentifier];
    if (cell == nil) {
        cell = [NMUserCell cellFromNib];
		[cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
		[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
	// Configure the cell.
	NMUser *friend = [_filteredFriends objectAtIndex:indexPath.row];
	[cell setUser:friend];
	
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NMUser *user = [_filteredFriends objectAtIndex:indexPath.row];
	
	NMUserViewController *detailViewController = [(NMUserViewController *)[NMUserViewController alloc] initWithUser:user];
	[self.navigationController pushViewController:detailViewController animated:YES];
	[detailViewController release];
}


#pragma mark -
#pragma mark MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	if (annotation == mapView.userLocation) {
		return nil;
	}
	
	MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:@"user"];
	if (!view) {
		view = [[[NMUserAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"user"] autorelease];
	}
	
	NMUser *user = (NMUser *)annotation;
	[(NMUserAnnotationView *)view updateStatusWithUser:user];
	
	return view;
}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
	NMUser *user = (NMUser *)view.annotation;
	
	// open user
	NMUserViewController *controller = [[(NMUserViewController *)[NMUserViewController alloc] initWithUser:user] autorelease];
	[self.navigationController pushViewController:controller animated:YES];
}


- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
	// update user location
	[_user setCurrentLocation:userLocation.location];
}


#pragma mark -
#pragma mark Memory management

- (void)viewDidUnload {
	[_clock invalidate];
	_clock = nil;
	self.tableView = nil;
	self.filterControl = nil;
	self.tableContainer = nil;
	self.mapView = nil;
	self.mapContainer = nil;
	self.contentView = nil;
	[super viewDidUnload];
}


- (void)dealloc {
	[_clock invalidate];
	[_filteredFriends release];
	[_mapFilteredFriends release];
	[_user release];
	self.tableView = nil;
	self.filterControl = nil;
	self.tableContainer = nil;
	self.mapView = nil;
	self.mapContainer = nil;
	self.contentView = nil;
    [super dealloc];
}


@synthesize contentView;
@synthesize filterControl;

@synthesize tableContainer;
@synthesize tableView;

@synthesize mapContainer;
@synthesize mapView;

@end
