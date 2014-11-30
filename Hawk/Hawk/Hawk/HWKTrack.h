//
//  HWKTrack.h
//  Hawk
//
//  Created by Lochie Ferrier on 13/09/12.
//  Copyright (c) 2012 Lochie Ferrier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HWKTrackManagedObject.h"
#import "HWKWaypointManagedObject.h"
#import "HWKWaypoint.h"
#import "HWKAppDelegate.h"
@class HWKTrackerViewController;
@class HWKTrackManagedObject;

@interface HWKTrack : NSObject

// The unique ID of the track used for sharing.
@property (nonatomic,retain) NSString *trackID;

// The device ID of the track used to identify who created it.
@property (nonatomic,retain) NSString *deviceID;

// The name of the track.
@property (nonatomic,retain) NSString *name;

// The track's date of creation.
@property (nonatomic,retain) NSDate *dateCreated;

// The waypoints array.
@property (nonatomic,retain) NSMutableArray *waypoints;

// This method is used for the initial upload of the track to Parse and saving to Core Data. This tracker view controller is passed in so we can manipulate the progress HUD and access the location manager.
-(void)saveToParseAndCoreDataWithTrackerViewController:(HWKTrackerViewController *)_trackerViewController;

// This method is used to assign properties from a Parse track in the background.
-(void)assignPropertiesFromParseTrackInBackground:(PFObject *)_parseTrack;

// This method is used to assign properties from a Parse track in the foreground.
-(void)assignPropertiesFromParseTrackInForeground:(PFObject *)_parseTrack;

// This method is used to assign properties from a Core Data track.
-(void)assignPropertiesFromCoreDataTrack:(HWKTrackManagedObject *)_trackManagedObject;

// This method is used to delete the track and waypoints from Core Data and Parse. Used by the tracker view controller.
-(void)deleteTrackAndWaypointsFromCoreDataAndParse;

// This method is used to delete the track and waypoints from Core Data. Used by the viewer view controller.
-(void)deleteTrackAndWaypointsFromCoreData;

@end
