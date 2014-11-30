//
//  HWKMapAnnotationView.h
//  Hawk
//
//  Created by Lochie Ferrier on 17/10/12.
//  Copyright (c) 2012 Lochie Ferrier. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>
#import "HWKMapAnnotation.h"

@interface HWKMapAnnotationView : MKAnnotationView {
    NSString *annotationType;
    
}

@end
