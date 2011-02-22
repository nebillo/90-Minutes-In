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


const NSUInteger kUserAnnotationInButton = 1;
const NSUInteger kUserAnnotationOutButton = 2;


@implementation NMCurrentUserAnnotationView

- (UIView *)leftCalloutAccessoryView {
	NMUser *user = (NMUser *)self.annotation;
	UIView *view = [super leftCalloutAccessoryView];
	
	if (user.lastStatus && !user.lastStatus.expired) {
		return view;
	}
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[button setTitle:@"in" forState:UIControlStateNormal];
	[button setFrame:CGRectMake(0, 0, 32, 32)];
	[button setTag:kUserAnnotationInButton];
	return button;
}


- (UIView *)rightCalloutAccessoryView {
	NMUser *user = (NMUser *)self.annotation;
	UIView *view = [super rightCalloutAccessoryView];
	
	if (user.lastStatus && !user.lastStatus.expired) {
		return view;
	}
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[button setTitle:@"out" forState:UIControlStateNormal];
	[button setFrame:CGRectMake(0, 0, 32, 32)];
	[button setTag:kUserAnnotationOutButton];
	return button;
}

@end
