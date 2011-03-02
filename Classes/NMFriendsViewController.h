//
//  NMFriendsViewController.h
//  NinetyMinutes
//
//  Created by Nebil on 20/02/11.
//  Copyright 2011 Nebil Kriedi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMRequest.h"
#import <MapKit/MKMapView.h>

@class NMUser;


@interface NMFriendsViewController : UIViewController <NMRequestDelegate, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate>
{
	NMUser *_user;
	NSTimer *_clock;
	BOOL _showingMap;
	NSUInteger _friendsFilter;
	
	NSArray *_filteredFriends;
	NSArray *_tableIndex;
	
	NSArray *_mapFilteredFriends;
}

@property (nonatomic, retain) IBOutlet UIView *contentView;
@property (nonatomic, retain) IBOutlet UISegmentedControl *filterControl;

@property (nonatomic, retain) IBOutlet UIView *tableContainer;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) IBOutlet UIView *mapContainer;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;

- (IBAction)updateFriends;
- (IBAction)filterFriends:(UISegmentedControl *)control;

@end
