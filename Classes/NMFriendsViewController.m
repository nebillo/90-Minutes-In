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
	
	for (NMUser *user in _user.friends) {
		if (!filter || (!user.lastStatus.expired && [user.lastStatus.status isEqualToString:filter])) {
			[filtered addObject:user];
		}
	}
	
	// group friends by first letter of last name
	NSMutableArray *groups = [NSMutableArray array];
	NSMutableArray *indexes = [NSMutableArray array];
	
	for (NMUser *user in filtered) {
		NSString *firstLetter = [user.lastName substringToIndex:1];
		firstLetter = [firstLetter uppercaseString];
		
		if (NSNotFound == [indexes indexOfObject:firstLetter]) {
			[indexes addObject:firstLetter];
			NSMutableArray *sectionArray = [NSMutableArray array];
			[groups addObject:sectionArray];
			[sectionArray addObject:user];
		} else {
			NSMutableArray *sectionArray = [groups lastObject];
			[sectionArray addObject:user];			
		}
		
	}
	
	[_filteredFriends release];
	_filteredFriends = [groups retain];
	[_tableIndex release];
	_tableIndex = [indexes retain];
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
	
	[self.tableView setRowHeight:kUserCellHeight];
	
	[self.filterControl setSelectedSegmentIndex:_friendsFilter];
	
	_clock = [NSTimer scheduledTimerWithTimeInterval:60.0 
											  target:self
											selector:@selector(refreshCells) 
											userInfo:nil repeats:YES];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	if (_user.friends) {
		[self filterFriends:self.filterControl];
	} else {
		[self updateFriends];
	}
	
	[self.navigationController.navigationBar setTintColor:nil];
	[self.filterControl setTintColor:nil];
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
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
}


- (void)refreshCells {
	NSArray *cells = [self.tableView visibleCells];
	[cells makeObjectsPerformSelector:@selector(updateStatus)];
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

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _filteredFriends.count;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *friends = [_filteredFriends objectAtIndex:section];
	return friends.count;
}


// return list of section titles to display in section index view (e.g. "ABCD...Z#")
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	return _tableIndex;
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
	NMUser *friend = [[_filteredFriends objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	[cell setUser:friend];
	
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NMUser *user = [[_filteredFriends objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	
	NMUserViewController *detailViewController = [(NMUserViewController *)[NMUserViewController alloc] initWithUser:user];
	[self.navigationController pushViewController:detailViewController animated:YES];
	[detailViewController release];
}


#pragma mark -
#pragma mark Memory management

- (void)viewDidUnload {
	[_clock invalidate];
	_clock = nil;
	self.tableView = nil;
	self.filterControl = nil;
	[super viewDidUnload];
}


- (void)dealloc {
	[_clock invalidate];
	[_filteredFriends release];
	[_user release];
	[_tableIndex release];
	self.tableView = nil;
	self.filterControl = nil;
    [super dealloc];
}


@synthesize filterControl;
@synthesize tableView;

@end

