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
#import <Three20UI/TTImageView.h>


@implementation NMUserAnnotationView


- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
	if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
		[self setCanShowCallout:YES];
		
		self.frame = CGRectMake(0, 0, 64, 65);
		self.centerOffset = CGPointMake(0, -12);
		
		_pictureView = [[[TTImageView alloc] initWithFrame:CGRectMake(10, 11, 44, 33)] autorelease];
		[_pictureView setClipsToBounds:YES];
		[_pictureView setContentMode:UIViewContentModeScaleAspectFill];
		
		_statusFrame = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
		[_statusFrame setOpaque:NO];
		[_statusFrame setBackgroundColor:[UIColor clearColor]];
		
		[self addSubview:_pictureView];
		[self addSubview:_statusFrame];
	}
	return self;
}


- (void)prepareForReuse {
	[_pictureView setUrlPath:nil];
}


- (void)updateStatus {
	NMUser *user = (NMUser *)self.annotation;
	NMStatusUpdate *status = user.lastStatus;
	
	[_pictureView setUrlPath:user.picture];
	
	if (!status || status.expired) {
		_statusFrame.image = [UIImage imageNamed:@"mapPin_grey.png"];
	} else if ([status.status isEqualToString:kNMStatusIn]) {
		_statusFrame.image = [UIImage imageNamed:@"mapPin_green.png"];
	} else if ([status.status isEqualToString:kNMStatusOut]) {
		_statusFrame.image = [UIImage imageNamed:@"mapPin_red.png"];
	}
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
