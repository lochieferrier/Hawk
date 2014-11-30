//
//  HWKWaypointManagedObject.m
//  Hawk
//
//  Created by Lochie Ferrier on 23/09/12.
//  Copyright (c) 2012 Lochie Ferrier. All rights reserved.
//

#import "HWKWaypointManagedObject.h"


@implementation HWKWaypointManagedObject

@dynamic altitude;
@dynamic heading;
@dynamic latitude;
@dynamic longitude;
@dynamic timeRecorded;
@dynamic speed;
@dynamic track;

-(void)assignPropertiesFromWaypoint:(HWKWaypoint *)_waypoint{
    
    // Set the numbers from the waypoint passed in.
    self.heading = _waypoint.heading;
    self.latitude = _waypoint.latitude;
    self.longitude = _waypoint.longitude;
    self.speed = _waypoint.speed;
    self.altitude = _waypoint.altitude;
    self.timeRecorded = _waypoint.timeRecorded;
     
}
@end
