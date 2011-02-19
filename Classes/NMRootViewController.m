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
#import "NMViewExtension.h"


@interface NMRootViewController ()

- (void)updateWithStatus:(NMStatusUpdate *)status;

@end


@implementation NMRootViewController

- (id)initWithUser:(NMUser *)user {
    if ((self = [super initWithNibName:@"NMRootViewController" bundle:nil])) {
        // Custom initialization
		self.user = user;
    }
    return self;
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self.userLabel setText:[NSString stringWithFormat:@"Hi %@, your are:", self.user.firstName]];
	[self updateWithStatus:self.user.lastStatus];
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


- (IBAction)updateStatus {
	[self.view presentLoadingViewWithTitle:@"Updating your status…"];
	[self.statusControl setEnabled:NO];
	
	NMUpdateStatusRequest *update = [[[NMUpdateStatusRequest alloc] initWithRootURL:[NSURL URLWithString:kAPIRootURL]] autorelease];
	[update setDelegate:self];
	[update setStatus:self.statusControl.selectedSegmentIndex == 0 ? kNMStatusIn : kNMStatusOut];
	[update start];
}


- (void)updateWithStatus:(NMStatusUpdate *)status {
	if (!status || status.expired) {
		// no status or status is expired
		[self.statusControl setEnabled:YES];
		[self.statusControl setSelected:NO];
	} else {
		// there is a valid status
		[self.statusControl setEnabled:NO];
		if ([status.status isEqualToString:kNMStatusIn]) {
			[self.statusControl setSelectedSegmentIndex:0];
		} else {
			[self.statusControl setSelectedSegmentIndex:1];
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
	}
	[self.view dismissStaticView];
}


- (void)request:(NMRequest *)request didFinishWithResponse:(id)response {
	NMStatusUpdate *status = (NMStatusUpdate *)response;
	[self updateWithStatus:status];
	
	if ([request isKindOfClass:[NMGetStatusRequest class]]) {
	} else if ([request isKindOfClass:[NMUpdateStatusRequest class]]) {
		[[[[UIAlertView alloc] initWithTitle:@"Status updated" 
									 message:[NSString stringWithFormat:@"You'll be %@ for 90 minutes", status.status] 
									delegate:nil 
						   cancelButtonTitle:@"Ok" 
						   otherButtonTitles:nil] autorelease] show];
	}
	[self.view dismissStaticView];
}


#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Configure the cell.

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
	self.statusControl = nil;
	self.userLabel = nil;
}


- (void)dealloc {
	self.user = nil;
	self.tableView = nil;
	self.statusControl = nil;
	self.userLabel = nil;
    [super dealloc];
}


@synthesize tableView;
@synthesize statusControl;
@synthesize userLabel;
@synthesize user;

@end

