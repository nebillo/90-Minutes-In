//
//  NMMapOverlay.h
//  NinetyMinutes
//
//  Created by Nebil on 23/02/11.
//  Copyright 2011 Nebil Kriedi. All rights reserved.
//

#import <MapKit/MKOverlay.h>

@class MKPolygon;


@interface NMMapOverlay : NSObject <MKOverlay>
{
}
@property (nonatomic, retain) MKPolygon *polygon;

@end
