//
//  HWKMapAnnotation.h
//  Hawk
//
//  Created by Lochie Ferrier on 15/09/12.
//  Copyright (c) 2012 Lochie Ferrier. All rights reserved.
//

#import <MapKit/MapKit.h>
@interface HWKMapAnnotation : NSObject <MKAnnotation> {
    CLLocationCoordinate2D coordinate;
    NSString *annotationType;
}

// The coordinate.
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

// The annotation's type.
@property (nonatomic, retain) NSString *annotationType;

// An init method to speed up setting up the annotation.
- (id) initWithCoordinate:(CLLocationCoordinate2D)coord;

@end