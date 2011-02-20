//
//  RootViewController.m
//  NinetyMinutes
//
//  Created by Nebil on 12/02/11.
//  Copyright 2011 Nebil Kriedi. All rights reserved.
//

#import "NMRootViewController.h"
#import "NMStatusUpdate.h"
#import "NMUpdateStatusRequest.h"
#import "NMGetStatusRequest.h"
#import "NMFriendsRequest.h"
#import "NMViewExtension.h"
#import "NMUserCell.h"


@interface NMRootViewController ()

- (void)updateWithStatus:(NMStatusUpdate *)status;

@end


@implementation NMRootViewController

- (id)initWithUser:(NMUser *)user {
    if ((self = [super initWithNibName:@"NMRootViewController" bundle:nil])) {
        // Custom initialization
		self.user = user;
		_friendsFilter = 0;
    }
    return self;
}


- (void)filterFriendsWithFilter:(NSString *)filter {
	NSMutableArray *filtered = [NSMutableArray array];
	
	for (NMUser *user in _friends) {
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
	
	[self.navigationItem setTitle:@"90 Minutes In"];
	[self.navigationItem setRightBarButtonItem:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
																							  target:self 
																							  action:@selector(getStatus)] autorelease]];
	
	[self.tableView setRowHeight:kUserCellHeight];
	
	[self.userLabel setText:[NSString stringWithFormat:@"Hi %@, your are:", self.user.firstName]];
	[self updateWithStatus:self.user.lastStatus];
	
	[self.filterControl setSelectedSegmentIndex:_friendsFilter];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	[self getStatus];
}


/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */


- (IBAction)getStatus {
	[self.view presentLoadingViewWithTitle:@"Getting your status…"];
	
	NMGetStatusRequest *update = [[[NMGetStatusRequest alloc] initWithRootURL:[NSURL URLWithString:kAPIRootURL]] autorelease];
	[update setDelegate:self];
	[update setUser:self.user];
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


- (IBAction)updateFriends {
	[self.view presentLoadingViewWithTitle:@"Updating your friends…"];
	
	NMFriendsRequest *update = [[[NMFriendsRequest alloc] initWithRootURL:[NSURL URLWithString:kAPIRootURL]] autorelease];
	[update setDelegate:self];
	[update setUser:self.user];
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


- (void)updateWithStatus:(NMStatusUpdate *)status {
	if (!status || (NSNull *)status == [NSNull null] || status.expired) {
		// no status or status is expired
		[self.statusControl setUserInteractionEnabled:YES];
		[self.statusInButton setSelected:NO];
		[self.statusOutButton setSelected:NO];
	} else {
		// there is a valid status
		[self.statusControl setUserInteractionEnabled:NO];
		if ([status.status isEqualToString:kNMStatusIn]) {
			[self.statusInButton setSelected:YES];
			[self.statusOutButton setSelected:NO];
		} else {
			[self.statusOutButton setSelected:YES];
			[self.statusInButton setSelected:NO];
		}
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
	} else if ([request isKindOfClass:[NMFriendsRequest class]]) {
		[[[[UIAlertView alloc] initWithTitle:@"Update friends error" 
									 message:[error localizedDescription] 
									delegate:nil 
						   cancelButtonTitle:@"Ok" 
						   otherButtonTitles:nil] autorelease] show];
	}
	[self.view dismissStaticView];
}


- (void)request:(NMRequest *)request didFinishWithResponse:(id)response {
	
	[self.view dismissStaticView];
	
	if ([request isKindOfClass:[NMGetStatusRequest class]]) {
		
		NMStatusUpdate *status = (NMStatusUpdate *)response;
		[self updateWithStatus:status];
		[self updateFriends];
		
	} else if ([request isKindOfClass:[NMUpdateStatusRequest class]]) {
		
		NMStatusUpdate *status = (NMStatusUpdate *)response;
		[self updateWithStatus:status];
		[[[[UIAlertView alloc] initWithTitle:@"Status updated" 
									 message:[NSString stringWithFormat:@"You'll be %@ for 90 minutes", status.status] 
									delegate:nil 
						   cancelButtonTitle:@"Ok" 
						   otherButtonTitles:nil] autorelease] show];
		
	} else if ([request isKindOfClass:[NMFriendsRequest class]]) {
		
		[_friends release];
		_friends = [response retain];
		[self filterFriends:self.filterControl];
		
	}
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
    }
    
	// Configure the cell.
	NMUser *friend = [[_filteredFriends objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	[cell setUser:friend];

    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}


#pragma mark -
#pragma mark Memory management

- (void)viewDidUnload {
	self.tableView = nil;
	self.statusInButton = nil;
	self.statusOutButton = nil;
	self.statusControl = nil;
	self.userLabel = nil;
	self.filterControl = nil;
	[super viewDidUnload];
}


- (void)dealloc {
	[_filteredFriends release];
	[_friends release];
	[_tableIndex release];
	self.user = nil;
	self.tableView = nil;
	self.statusInButton = nil;
	self.statusOutButton = nil;
	self.statusControl = nil;
	self.userLabel = nil;
	self.filterControl = nil;
    [super dealloc];
}


@synthesize filterControl;
@synthesize tableView;
@synthesize statusInButton;
@synthesize statusOutButton;
@synthesize statusControl;
@synthesize userLabel;
@synthesize user;

@end

