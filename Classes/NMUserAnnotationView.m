//
//  NMUserAnnotationView.m
//  NinetyMinutes
//
//  Created by Nebil on 22/02/11.
//  Copyright 2011 Nebil Kriedi. All rights reserved.
//

#import "NMUserAnnotationView.h"
#import "NMUser.h"
#import "NMStatusUpdate.h"


@implementation NMUserAnnotationView


- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
	if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
		[self setCanShowCallout:YES];
	}
	return self;
}


- (UIView *)leftCalloutAccessoryView {
	NMUser *user = (NMUser *)self.annotation;
	if (!user.lastStatus) {
		return nil;
	}
	
	if (![user.lastStatus.status isEqualToString:kNMStatusIn]) {
		return nil;
	}
	
	//FIXME: this should not be an UIControl
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setTitle:@"in" forState:UIControlStateNormal];
	[button setFrame:CGRectMake(0, 0, 32, 32)];
	[button setUserInteractionEnabled:NO];
	return button;
}


- (UIView *)rightCalloutAccessoryView {
	NMUser *user = (NMUser *)self.annotation;
	if (!user.lastStatus) {
		return nil;
	}
	
	if (![user.lastStatus.status isEqualToString:kNMStatusOut]) {
		return nil;
	}
	
	//FIXME: this should not be an UIControl
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setTitle:@"out" forState:UIControlStateNormal];
	[button setFrame:CGRectMake(0, 0, 32, 32)];
	[button setUserInteractionEnabled:NO];
	return button;
}


@end
