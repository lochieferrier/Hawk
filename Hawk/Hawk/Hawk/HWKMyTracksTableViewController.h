//
//  HWKMyTracksTableViewController.h
//  Hawk
//
//  Created by Lochie Ferrier on 19/09/12.
//  Copyright (c) 2012 Lochie Ferrier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HWKAppDelegate.h"
#import "HWKTrackManagedObject.h"
#import "HWKWaypointManagedObject.h"
#import "HWKTrackerViewController.h"
#import "HWKCustomCell.h"
#import "HWKMapAnnotation.h"
#import "HWKViewerViewController.h"

@interface HWKMyTracksTableViewController : UITableViewController

// The track objects array.
@property (nonatomic,retain) NSMutableArray *trackObjectsArray;

// The managed object context.
@property (nonatomic,retain) NSManagedObjectContext *managedObjectContext;

@end
