//
//  HWKNavigationViewController.m
//  Hawk
//
//  Created by Lochie Ferrier on 7/10/12.
//  Copyright (c) 2012 Lochie Ferrier. All rights reserved.
//

#import "HWKNavigationViewController.h"

@interface HWKNavigationViewController ()

@end



@implementation HWKNavigationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create an image.
    UIImage *image = [UIImage imageNamed:@"navBarBackground.png"];
    
    // Set it as the background for the navigation bar.
    [self.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    
    // Set the navigation bar to have no shadow.
    [[UINavigationBar appearance] setShadowImage:NULL];
 
}

@end
