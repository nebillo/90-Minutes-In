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


@implementation NMCurrentUserAnnotationView

- (UIView *)leftCalloutAccessoryView {
	NMUser *user = (NMUser *)self.annotation;
	UIView *view = [super leftCalloutAccessoryView];
	
	if (user.lastStatus && !user.lastStatus.expired) {
		return view;
	}
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setTitle:@"in" forState:UIControlStateNormal];
	[button setFrame:CGRectMake(0, 0, 32, 32)];
	return button;
}


- (UIView *)rightCalloutAccessoryView {
	NMUser *user = (NMUser *)self.annotation;
	UIView *view = [super rightCalloutAccessoryView];
	
	if (user.lastStatus && !user.lastStatus.expired) {
		return view;
	}
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setTitle:@"out" forState:UIControlStateNormal];
	[button setFrame:CGRectMake(0, 0, 32, 32)];
	return button;
}

@end
