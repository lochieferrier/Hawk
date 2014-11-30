//
//  HWKTrackManagedObject.h
//  Hawk
//
//  Created by Lochie Ferrier on 3/10/12.
//  Copyright (c) 2012 Lochie Ferrier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "HWKTrack.h"

@class HWKTrack;

@class HWKWaypointManagedObject;

@interface HWKTrackManagedObject : NSManagedObject

// The device ID is a string that is stored on the device. A device ID can only exist for one device. It's used to identify track's owners.
@property (nonatomic, retain) NSString * deviceID;

// The date of creation.
@property (nonatomic, retain) NSDate * dateCreated;

// The track ID is a unique string which is used for sharing the track.
@property (nonatomic, retain) NSString * trackID;

// The track name.
@property (nonatomic, retain) NSString * name;

// The track's waypoints.
@property (nonatomic, retain) NSSet *waypoints;

@end

@interface HWKTrackManagedObject (CoreDataGeneratedAccessors)

// This method assigns properties from a track.
- (void)assignPropertiesFromTrack:(HWKTrack *)_track;

// These methods are used to add or remove waypoints from the track.
- (void)addWaypointsObject:(HWKWaypointManagedObject *)value;
- (void)removeWaypointsObject:(HWKWaypointManagedObject *)value;
- (void)addWaypoints:(NSSet *)values;
- (void)removeWaypoints:(NSSet *)values;

@end
