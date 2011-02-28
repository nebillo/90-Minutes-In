//
//  NMCurrentUserAnnotationView.m
//  NinetyMinutes
//
//  Created by Nebil on 22/02/11.
//  Copyright 2011 Nebil Kriedi. All rights reserved.
//

#import "NMCurrentUserAnnotationView.h"
#import "NMUser.h"
#import "NMStatusUpdate.h"


const NSUInteger kUserAnnotationInButton = 21;
const NSUInteger kUserAnnotationOutButton = 20;


@implementation NMCurrentUserAnnotationView

- (UIView *)leftCalloutAccessoryView {
	NMUser *user = (NMUser *)self.annotation;
	
	if (user.lastStatus && !user.lastStatus.expired) {
		// show status image if there's a valid status
		return [super leftCalloutAccessoryView];
	}
	
	// no status or status expired, show "in" status button
	UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[button setTitle:@"in" forState:UIControlStateNormal];
	[button setFrame:CGRectMake(0, 0, 32, 32)];
	[button setTag:kUserAnnotationInButton];
	return button;
}


- (UIView *)rightCalloutAccessoryView {
	NMUser *user = (NMUser *)self.annotation;
	
	if (user.lastStatus && !user.lastStatus.expired) {
		// show detail button if there's a valid status
		return [super rightCalloutAccessoryView];
	}
	
	// no status or status expired, show "out" status button
	UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[button setTitle:@"out" forState:UIControlStateNormal];
	[button setFrame:CGRectMake(0, 0, 32, 32)];
	[button setTag:kUserAnnotationOutButton];
	return button;
}

@end
