//
//  HWKWaypoint.m
//  Hawk
//
//  Created by Lochie Ferrier on 13/09/12.
//  Copyright (c) 2012 Lochie Ferrier. All rights reserved.
//

#import "HWKWaypoint.h"

@implementation HWKWaypoint


-(void)saveToParseAndCoreDataWithTrackID:(NSString *)_trackID{
    
    // Create a managed object context.
    NSManagedObjectContext *managedObjectContext = ((HWKAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
    
    // Create a managed waypoint object.
    HWKWaypointManagedObject *waypointObject =[NSEntityDescription insertNewObjectForEntityForName:@"Waypoint" inManagedObjectContext:managedObjectContext];
    
    // Set the waypoint object's properties.
    waypointObject.heading = self.heading;
    waypointObject.latitude = self.latitude;
    waypointObject.longitude = self.longitude;
    waypointObject.speed = self.speed;
    waypointObject.altitude = self.altitude;
    waypointObject.timeRecorded = self.timeRecorded;
    
    // Create a entity description.
    NSEntityDescription *trackEntityDescription = [NSEntityDescription entityForName:@"Track" inManagedObjectContext:managedObjectContext];
    
    // Create a fetch request.
    NSFetchRequest *trackFetchRequest = [[NSFetchRequest alloc] init];
    
    // Set the fetch request's entity description.
    [trackFetchRequest setEntity:trackEntityDescription];
    
    // Create an error.
    NSError *error = nil;
    
    // Execute the fetch request and store the results in an array.
    NSArray *theTrackObjectArray = [managedObjectContext executeFetchRequest:trackFetchRequest error:&error];
    
    // Enumerate through the tracks in the track object array.
    for (HWKTrackManagedObject *track in theTrackObjectArray){
        
        // Check that the track's track ID is the same as the one passed in.
        if([track.trackID isEqualToString:_trackID]){
            
            // Set the waypoint object's track to be the track passed in.
            waypointObject.track = track;
            
            // Create a mutable set of waypoints.
            NSMutableSet *waypoints = [NSMutableSet setWithSet:track.waypoints];
            
            // Add the waypoint to that set.
            [waypoints addObject:waypointObject];
            
            // Set the track's waypoints set to be the new waypoints set.
            track.waypoints = waypoints;
            
        }
        
    }
    
    // Save the managed object context.
    [managedObjectContext save:&error];
    
    // Create a Parse query.
    PFQuery *trackQuery = [PFQuery queryWithClassName:@"Track"];
    
    // Download the track object.
    [trackQuery getObjectInBackgroundWithId:_trackID block:^(PFObject *track, NSError *error){
        
        // Check that the track has downloaded successfully.
        if(track != nil){
            
            // Create a Parse waypoint object.
            PFObject *waypoint = [PFObject objectWithClassName:@"Waypoint"];
            
            // Get the waypoints track relation.
            PFRelation *trackRelation = [waypoint relationforKey:@"track"];
            
            // Add the track to the waypoints track relation.
            [trackRelation addObject:track];
            
            // Assign the properties of the waypoint object from self.
            [waypoint setObject:self.latitude forKey:@"latitude"];
            [waypoint setObject:self.longitude forKey:@"longitude"];
            [waypoint setObject:self.altitude forKey:@"altitude"];
            [waypoint setObject:self.heading forKey:@"heading"];
            [waypoint setObject:self.speed forKey:@"speed"];
            [waypoint setObject:self.timeRecorded forKey:@"timeRecorded"];
            
            // Save the waypoint object.
            [waypoint saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                
                // Check that the upload of the waypoint object succeeded.
                if(succeeded == YES){
                    
                    // Re-download the waypoint object. The reason this is done is that it is assigned an objectId when it is uploaded to Parse.com for the first time. Without this objectId, you cannot point to it. objectId properties on Parse.com function in a very similar way to pointers in Objective-C.
                    [waypoint refreshInBackgroundWithBlock:^(PFObject *refreshedWaypoint, NSError *error){
                        
                        // Check that the updated waypoint has downloaded successfully.
                        if (refreshedWaypoint != nil){
                            
                            // Create a relation to link the waypoint to the track.
                            PFRelation *trackRelation = [track relationforKey:@"waypoints"];
                            
                            // Add the waypoint to that relation.
                            [trackRelation addObject:refreshedWaypoint];
                            
                            // Re-upload the track.
                            [track saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                                if(succeeded == 1){
                                    
                                    // Log out that the waypoint and the track have been successfully uploaded.
                                    NSLog(@"Waypoint and track successfully uploaded");
                                    
                                }
                                else{
                                    
                                    // Log out that the upload of the track has failed and save it eventually.
                                    NSLog(@"Failed to upload track with waypoint relationship.");
                                    [track saveEventually];
                                    
                                }
                            }];
                            
                        }
                        
                        else {
                            
                            // Log out that the waypoint download failed.
                            NSLog(@"Failed to download waypoint with ID");
                            
                        }
                        
                    }];
                    
                }
                
                else{
                    
                    // Log out that the waypoint upload failed to upload and save it eventually.
                    NSLog(@"Failed to upload waypoint");
                    [waypoint saveEventually];
                    
                }
                
            }];
            
        }
        
        else{
            
            // Log out that the download of the track failed and try again.
            NSLog(@"Failed to download track");
            [self saveToParseAndCoreDataWithTrackID:_trackID];
            
        }
        
    }];

}

-(void)assignPropertiesFromParseWaypoint:(PFObject *)_parseWaypoint{
    
    // Set the waypoint properties from the Parse waypoint passed in.
    self.heading = [NSNumber numberWithFloat:[[_parseWaypoint valueForKey:@"heading"] floatValue]];
    self.latitude = [_parseWaypoint valueForKey:@"latitude"];
    self.longitude = [_parseWaypoint valueForKey:@"longitude"];
    self.speed = [_parseWaypoint valueForKey:@"speed"];
    self.altitude = [_parseWaypoint valueForKey:@"altitude"];
    self.timeRecorded = [_parseWaypoint valueForKey:@"timeRecorded"];
    
}
-(void)assignPropertiesFromCoreDataWaypoint:(HWKWaypointManagedObject *)_waypointManagedObject{
    
    // Set the waypoint properties from the Core Data waypoint passed in.
    self.heading = _waypointManagedObject.heading;
    self.latitude = _waypointManagedObject.latitude;
    self.longitude = _waypointManagedObject.longitude;
    self.speed = _waypointManagedObject.speed;
    self.altitude = _waypointManagedObject.altitude;
    self.timeRecorded = _waypointManagedObject.timeRecorded;
    
}
@end
