//
//  NMUserViewController.m
//  NinetyMinutes
//
//  Created by Nebil on 28/02/11.
//  Copyright 2011 Nebil Kriedi. All rights reserved.
//

#import "NMUserViewController.h"
#import "NMUser.h"

#import <Three20UI/TTImageView.h>


@interface NMUserViewController ()

- (void)updateInterface;

@end


@implementation NMUserViewController

- (id)initWithUser:(NMUser *)user {
	if (self = [super initWithNibName:@"NMUserViewController" bundle:nil]) {
		_user = [user retain];
	}
	return self;
}


@synthesize user = _user;

#pragma mark -
#pragma mark View lifecycle

@synthesize tableView = _tableView;
@synthesize pictureView;
@synthesize userNameLabel;
@synthesize lastStatusLabel;


- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self.navigationItem setTitle:@"Timeline"];
	[self.pictureView setUrlPath:_user.picture];
	[self.userNameLabel setText:_user.name];
	[self.lastStatusLabel setText:[_user subtitle]];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	[self updateInterface];
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
	[self setBarColorWithHue:1 saturation:0];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	//TODO: get number of statuses
    return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    //TODO: Configure the cell...
    
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//TODO: show status detail
}


#pragma mark -
#pragma mark Memory management

- (void)viewDidUnload {
	[self.tableView setDelegate:nil];
	[self.tableView setDataSource:nil];
	self.tableView = nil;
	self.pictureView = nil;
	self.userNameLabel = nil;
	self.lastStatusLabel = nil;
	[super viewDidUnload];
}


- (void)dealloc {
	[self.tableView setDelegate:nil];
	[self.tableView setDataSource:nil];
	self.tableView = nil;
	self.pictureView = nil;
	self.userNameLabel = nil;
	self.lastStatusLabel = nil;
	[_user release];
    [super dealloc];
}


@end

