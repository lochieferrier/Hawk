//
//  HWKMapAnnotation.m
//  Hawk
//
//  Created by Lochie Ferrier on 15/09/12.
//  Copyright (c) 2012 Lochie Ferrier. All rights reserved.
//

#import "HWKMapAnnotation.h"

@implementation HWKMapAnnotation

@synthesize coordinate;
@synthesize annotationType;


- (id) initWithCoordinate:(CLLocationCoordinate2D)coord
{
    
    // Set the coordinate.
    coordinate = coord;
    
    // Return self.
    return self;
    
}

@end
