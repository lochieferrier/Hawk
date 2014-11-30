//
//  HWKFollowingTableViewController.h
//  Hawk
//
//  Created by Lochie Ferrier on 23/09/12.
//  Copyright (c) 2012 Lochie Ferrier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HWKTrack.h"
#import "HWKCustomCell.h"
#import "HWKViewerViewController.h"

@interface HWKFollowingTableViewController : UITableViewController

// The track objects array.
@property (nonatomic,retain) NSMutableArray *trackObjectsArray;

// The managed object context.
@property (nonatomic,retain) NSManagedObjectContext *managedObjectContext;

@end
