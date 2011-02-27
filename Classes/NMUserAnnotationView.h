//
//  NMUserAnnotationView.h
//  NinetyMinutes
//
//  Created by Nebil on 22/02/11.
//  Copyright 2011 Nebil Kriedi. All rights reserved.
//

#import <MapKit/MKAnnotationView.h>

@class TTImageView;


@interface NMUserAnnotationView : MKAnnotationView 
{
	UIImageView *_statusFrame;
	TTImageView *_pictureView;
}

- (void)updateStatus;

@end
