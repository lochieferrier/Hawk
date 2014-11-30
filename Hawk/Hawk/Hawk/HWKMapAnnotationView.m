//
//  HWKMapAnnotationView.m
//  Hawk
//
//  Created by Lochie Ferrier on 17/10/12.
//  Copyright (c) 2012 Lochie Ferrier. All rights reserved.
//

#import "HWKMapAnnotationView.h"

@implementation HWKMapAnnotationView

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    
    if(self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
        
        // Set the background to be a clear color.
        self.backgroundColor = [UIColor clearColor];
        
    }
    
    return self;
    
}
- (void)setAnnotation:(id <MKAnnotation>)annotation {
    
    // Set the annotation of super.
    super.annotation = annotation;
    
    // Set the frame.
    self.frame = CGRectMake(0, 0, 12, 12);
    
}
- (void)drawRect:(CGRect)rect
{
    
    // Set the context to the current context.
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Fill in with a half opaque red.
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.91 green:0.27 blue:0.23 alpha:0.50].CGColor);
        CGContextFillEllipseInRect(context, rect);

}

+ (Class) layerClass //3
{
    // Return the CAEmitterLayer class.
    return [CAEmitterLayer class];
}

@end
