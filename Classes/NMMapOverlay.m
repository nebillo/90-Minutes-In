//
//  NMMapOverlay.m
//  NinetyMinutes
//
//  Created by Nebil on 23/02/11.
//  Copyright 2011 Nebil Kriedi. All rights reserved.
//

#import "NMMapOverlay.h"
#import <MapKit/MapKit.h>

#import <CoreGraphics/CoreGraphics.h>


@implementation NMMapOverlay


- (CLLocationCoordinate2D)coordinate {
	// 0,0 coordinate
	CLLocationCoordinate2D zero;
	zero.latitude = 0;
	zero.longitude = 0;
	return zero;
}


- (MKMapRect)boundingMapRect {
	// full area
	MKMapRect rect;
	MKMapPoint point;
	MKMapSize size;
	
	point.x = -180.0;
	point.y = -90.0;
	size.width = 320.0;
	size.height = 180.0;
	
	rect.origin = point;
	rect.size = size;
	return rect;
}


@end


@implementation NMMapOverlayView

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context {
	CGContextSetAlpha(context, 1.0);
    CGColorRef color = [UIColor colorWithWhite:1 alpha:1].CGColor;
    CGContextSetFillColorWithColor(context, color);
            
	// Convert the MKMapRect (absolute points on the map proportional to screen points) to
	// a CGRect (points relative to the origin of this view) that can be drawn.
	CGRect boundaryCGRect = [self rectForMapRect:mapRect];
	CGContextFillRect(context, boundaryCGRect);
}

@end
