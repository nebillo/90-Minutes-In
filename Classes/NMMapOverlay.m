//
//  NMMapOverlay.m
//  NinetyMinutes
//
//  Created by Nebil on 23/02/11.
//  Copyright 2011 Nebil Kriedi. All rights reserved.
//

#import "NMMapOverlay.h"
#import <MapKit/MapKit.h>


@implementation NMMapOverlay

- (id)init {
    if (self = [super init]) {
        MKMapPoint points[4];
        CLLocationCoordinate2D c1 = {85,-180.0};
        points[0] = MKMapPointForCoordinate(c1);
        CLLocationCoordinate2D c2 = {85,180.0};
        points[1] = MKMapPointForCoordinate(c2);
        CLLocationCoordinate2D c3 = {-85,180.0};
        points[2] = MKMapPointForCoordinate(c3);
        CLLocationCoordinate2D c4 = {-85,-180.0};
        points[3] = MKMapPointForCoordinate(c4);
		
        self.polygon = [MKPolygon polygonWithPoints:points count:4];
    }
    return self;
}


- (MKMapRect)boundingMapRect {
    CLLocationCoordinate2D corner1 = CLLocationCoordinate2DMake(85, -180.0);
    MKMapPoint mp1 = MKMapPointForCoordinate(corner1);
	
    CLLocationCoordinate2D corner2 = CLLocationCoordinate2DMake(-85, 180.0);
    MKMapPoint mp2 = MKMapPointForCoordinate(corner2);
	
    MKMapRect bounds = MKMapRectMake(mp1.x, mp1.y, (mp2.x-mp1.x), (mp2.y-mp1.y));
	
    return bounds;
}


- (CLLocationCoordinate2D)coordinate{
    return CLLocationCoordinate2DMake(0, 0);
}


@synthesize polygon;

@end
