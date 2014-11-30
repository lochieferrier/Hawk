//
//  HWKWaypoint.h
//  Hawk
//
//  Created by Lochie Ferrier on 13/09/12.
//  Copyright (c) 2012 Lochie Ferrier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HWKWaypointManagedObject.h"
#import "HWKTrackManagedObject.h"
#import "HWKAppDelegate.h"

@class HWKWaypointManagedObject;

@interface HWKWaypoint : NSObject

// The unique ID of the waypoint.
@property (nonatomic,retain) NSString *waypointID;

// The longitude in degrees.
@property (nonatomic,retain) NSNumber *latitude;

// The latitude in degrees.
@property (nonatomic,retain) NSNumber *longitude;

// The altitude in meters.
@property (nonatomic,retain) NSNumber *altitude;

// The heading in degrees.
@property (nonatomic,retain) NSNumber *heading;

// The speed in km/h.
@property (nonatomic,retain) NSNumber *speed;

// The time that the waypoint was recorded.
@property (nonatomic,retain) NSDate *timeRecorded;

// This method saves to Parse and Core Data with a track ID.
-(void)saveToParseAndCoreDataWithTrackID:(NSString *)_trackID;

// This method assigns properties from a Parse waypoint.
-(void)assignPropertiesFromParseWaypoint:(PFObject *)_parseWaypoint;

// This method assigns properties from a Core Data waypoint.
-(void)assignPropertiesFromCoreDataWaypoint:(HWKWaypointManagedObject *)_waypointManagedObject;

@end
