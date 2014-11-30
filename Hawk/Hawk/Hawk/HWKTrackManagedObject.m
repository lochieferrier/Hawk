//
//  HWKTrackManagedObject.m
//  Hawk
//
//  Created by Lochie Ferrier on 3/10/12.
//  Copyright (c) 2012 Lochie Ferrier. All rights reserved.
//

#import "HWKTrackManagedObject.h"
#import "HWKWaypointManagedObject.h"


@implementation HWKTrackManagedObject

@dynamic deviceID;
@dynamic dateCreated;
@dynamic trackID;
@dynamic name;
@dynamic waypoints;

-(void)assignPropertiesFromTrack:(HWKTrack *)_track{
    
    // Set the strings and date from the track passed in.
    self.trackID = _track.trackID;
    self.deviceID = _track.deviceID;
    self.name = _track.name;
    self.dateCreated = _track.dateCreated;
    
    // Create an array.
    NSMutableArray *waypointsArray = [[NSMutableArray alloc] init];
    
    // Enumerate through the array.
    for (HWKWaypoint *waypoint in _track.waypoints){
        
        // Create an entity description.
        NSEntityDescription *waypointEntityDescription = [NSEntityDescription entityForName:@"Waypoint" inManagedObjectContext:((HWKAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext];
        
        // Create a waypoint managed object.
        HWKWaypointManagedObject *waypointManagedObject = [[HWKWaypointManagedObject alloc] initWithEntity:waypointEntityDescription insertIntoManagedObjectContext:((HWKAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext];
        
        // Assign the waypoint managed object's properties from a waypoint.
        [waypointManagedObject assignPropertiesFromWaypoint:waypoint];

        // Create an error.
        NSError *error = [[NSError alloc] init];
        
        // Save the managed object context.
        [((HWKAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext save:&error];
        
        // Add the waypoint to the waypoints array.
        [waypointsArray addObject:waypointManagedObject];
        
    }
    
    // Set the waypoints set to be the waypoints array.
    self.waypoints = [NSSet setWithArray:waypointsArray];
    
}

@end
