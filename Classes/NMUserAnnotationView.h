//
//  NMUserAnnotationView.h
//  NinetyMinutes
//
//  Created by Nebil on 22/02/11.
//  Copyright 2011 Nebil Kriedi. All rights reserved.
//

#import <MapKit/MKAnnotationView.h>

@class TTImageView;
@class NMUser;


extern const NSUInteger kUserAnnotationDetailButton;


@interface NMUserAnnotationView : MKAnnotationView 
{
	UIImageView *_statusFrame;
	TTImageView *_pictureView;
	UIView *_selectionMask;
}

- (void)updateStatusWithUser:(NMUser *)user;

@end
