//
//  HWKWaypointManagedObject.h
//  Hawk
//
//  Created by Lochie Ferrier on 23/09/12.
//  Copyright (c) 2012 Lochie Ferrier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "HWKWaypoint.h"
#import "HWKTrackManagedObject.h"

@class HWKTrackManagedObject;

@class  HWKWaypoint;

@interface HWKWaypointManagedObject : NSManagedObject

// The the altitude in meters.
@property (nonatomic, retain) NSNumber * altitude;

// The heading in degrees.
@property (nonatomic, retain) NSNumber * heading;

// The latitude in degrees.
@property (nonatomic, retain) NSNumber * latitude;

// The longitude in degrees.
@property (nonatomic, retain) NSNumber * longitude;

// The time that the waypoint was recorded.
@property (nonatomic, retain) NSDate * timeRecorded;

// The speed in km/h.
@property (nonatomic, retain) NSNumber * speed;

// The track.
@property (nonatomic, retain) HWKTrackManagedObject *track;

// This method assigns properties from a waypoint.
-(void)assignPropertiesFromWaypoint:(HWKWaypoint *)_waypoint;

@end
