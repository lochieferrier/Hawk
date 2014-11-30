//
//  HWKTrack.m
//  Hawk
//
//  Created by Lochie Ferrier on 13/09/12.
//  Copyright (c) 2012 Lochie Ferrier. All rights reserved.
//

#import "HWKTrack.h"
#import "HWKTrackerViewController.h"
@implementation HWKTrack


-(void)saveToParseAndCoreDataWithTrackerViewController:(HWKTrackerViewController *)_trackerViewController{
    
    // Create a managed object context.
    NSManagedObjectContext *managedObjectContext = ((HWKAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
    
    // Create a track managed object.
    HWKTrackManagedObject *trackManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Track" inManagedObjectContext:managedObjectContext];
    
    // Set the track managed object's device ID.
    trackManagedObject.deviceID = [[NSUserDefaults standardUserDefaults] stringForKey:@"deviceID"];
    
    // Create a Parse track.
    PFObject *parseTrack = [PFObject objectWithClassName:@"Track"];
    
    // Set the Parse track's values.
    [parseTrack setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"deviceID"] forKey:@"deviceID"];
    [parseTrack setValue:self.name forKey:@"name"];
    
    // Save the Parse track in the background.
    [parseTrack saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        
        // Check whether the upload has succeeded.
        if (succeeded == YES){
            
            // Refresh the Parse track in the background.
            [parseTrack refreshInBackgroundWithBlock:^(PFObject *refreshedTrack, NSError *error) {
                
                // Check whether the refresh has succeeded.
                if (refreshedTrack != nil){
                    
                    // Set the track managed object's properties.
                    trackManagedObject.deviceID = [[NSUserDefaults standardUserDefaults] stringForKey:@"deviceID"];
                    trackManagedObject.trackID = refreshedTrack.objectId;
                    trackManagedObject.name = self.name;
                    trackManagedObject.dateCreated = self.dateCreated;
                    
                    // Enumerate through the track managed object's waypoints.
                    for (HWKWaypointManagedObject *managedWaypoint in [trackManagedObject.waypoints allObjects]){
                        
                        // Create a waypoint.
                        HWKWaypoint *waypoint = [[HWKWaypoint alloc] init];
                        
                        // Assign it's properties from the parse waypoint.
                        [waypoint assignPropertiesFromCoreDataWaypoint:managedWaypoint];
                        
                        // Add the waypoints to the waypoints array.
                        [self.waypoints addObject:waypoint];
                        
                    }
                    
                    // Create an error.
                    NSError *error = nil;
                    
                    // Save the managed object context.
                    [managedObjectContext save:&error];
                    
                    // Set the device ID.
                    self.deviceID = [[NSUserDefaults standardUserDefaults] stringForKey:@"deviceID"];
                    
                    // Set the track ID.
                    self.trackID = refreshedTrack.objectId;
                    
                    // Start updating location.
                    [_trackerViewController.locationManager startUpdatingLocation];
                    
                    // Start updating heading.
                    [_trackerViewController.locationManager startUpdatingHeading];
                    
                    // Set the progress HUD's text to "Waiting for movement".
                    [_trackerViewController.progressHUD setLabelText:@"Waiting for movement"];
                    
                }
                
                else {
                    
                    // Show the no Internet connection alert view.
                    [_trackerViewController showNoInternetConnectionAlertView];
                    
                }
                
            }];
            
        }
        
        else{
            
            // Show the no Internet connection alert view.
            [_trackerViewController showNoInternetConnectionAlertView];
            
        }
        
    }];
    
}


-(void)deleteTrackAndWaypointsFromCoreDataAndParse{
    
    // Create a managed object context.
    NSManagedObjectContext *managedObjectContext = ((HWKAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
    
    // Create an entity description.
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Track" inManagedObjectContext:managedObjectContext];
    
    // Create a fetch request.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Set the fetch request's entity description
    [fetchRequest setEntity:entityDescription];
    
    // Create an error.
    NSError *error = nil;
    
    // Execute the fetch request and store the results in an array.
    NSArray *fetchResults = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    // Enumerate through the fetch request results.
    for (HWKTrackManagedObject *trackManagedObject in fetchResults){
        
        // Check that the track managed object's track ID is the same as the track ID.
        if([trackManagedObject.trackID isEqualToString:self.trackID]){
            
            // Delete the object from the managed object context.
            [managedObjectContext deleteObject:trackManagedObject];
        }
        
    }
    
    // Save the managed object context.
    [managedObjectContext save:&error];
    
    // Create a Parse query.
    PFQuery *trackQuery = [PFQuery queryWithClassName:@"Track"];
    
    // Execute the Parse query in the background.
    [trackQuery getObjectInBackgroundWithId:self.trackID block:^(PFObject *track, NSError *error){
        
        //Check that the Parse request has successfully downloaded a track.
        if (track != nil){
            
            // Get the track's waypoints relation.
            PFRelation *waypointsRelation = [track relationforKey:@"waypoints"];
            
            // Find the track's waypoints in the background.
            [[waypointsRelation query] findObjectsInBackgroundWithBlock:^(NSArray *waypointsArray, NSError *error){
                
                // Check that the download was successful.
                if(waypointsArray != nil){
                    
                    // Enumerate through the waypoints in the array.
                    for (PFObject *waypoint in waypointsArray){
                        
                        // Delete the waypoint from Parse.
                        [waypoint deleteEventually];
                        
                    }
                    
                }
                
            }];
            
            // Delete the track from Parse.
            [track deleteEventually];
            
        }
        
    }];
    
}

-(void)deleteTrackAndWaypointsFromCoreData{
    
    
    // Create a managed object context.
    NSManagedObjectContext *managedObjectContext = ((HWKAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
    
    // Create an entity description.
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Track" inManagedObjectContext:managedObjectContext];
    
    // Create a fetch request.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Set the fetch request's entity description
    [fetchRequest setEntity:entityDescription];
    
    // Create an error.
    NSError *error = nil;
    
    // Execute the fetch request and store the results in an array.
    NSArray *fetchResults = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    // Enumerate through the fetch request results.
    for (HWKTrackManagedObject *trackManagedObject in fetchResults){
        
        // Check that the track managed object's track ID is the same as the track ID.
        if([trackManagedObject.trackID isEqualToString:self.trackID]){
            
            // Delete the object from the managed object context.
            [managedObjectContext deleteObject:trackManagedObject];
        }
        
    }
    
    // Save the managed object context.
    [managedObjectContext save:&error];
    
}
-(void)assignPropertiesFromParseTrackInBackground:(PFObject *)_parseTrack{
    
    // Alloc and init the waypoints array.
    self.waypoints = [[NSMutableArray alloc] init];
    
    // Assign properties from the Parse track.
    self.trackID = _parseTrack.objectId;
    self.deviceID = [_parseTrack valueForKey:@"deviceID"];
    self.name = [_parseTrack valueForKey:@"name"];
    self.dateCreated = _parseTrack.createdAt;
    
    // Get the waypoints relation for the Parse track passed in.
    PFRelation *relation = [_parseTrack relationforKey:@"waypoints"];
    
    // Download the waypoints in the background.
    [[relation query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        
        // Check that the waypoints were downloaded successfully.
        if (error == NULL){
            
            // Enumerate throught the waypoints.
            for(PFObject *parseWaypoint in objects){
                
                // Create a waypoint.
                HWKWaypoint *waypoint = [[HWKWaypoint alloc] init];
                
                // Assign the waypoint's properties from a Parse waypoint.
                [waypoint assignPropertiesFromParseWaypoint:parseWaypoint];
                
                // Add the waypoint to the waypoints array.
                [self.waypoints addObject:waypoint];
            }
            
            // Create a sort descriptor.
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeRecorded" ascending:YES];
            
            // Put that sort descriptor in an array.
            NSArray *sortDescriptors =  [NSArray arrayWithObject:sortDescriptor];
            
            // Sort the waypoints array.
            self.waypoints = [NSMutableArray arrayWithArray:[self.waypoints sortedArrayUsingDescriptors:sortDescriptors]];
            
        }

    }];

}

-(void)assignPropertiesFromParseTrackInForeground:(PFObject *)_parseTrack{
    
    // Alloc and init the waypoints array.
    self.waypoints = [[NSMutableArray alloc] init];
    
    // Assign properties from the Parse track.
    self.trackID = _parseTrack.objectId;
    self.deviceID = [_parseTrack valueForKey:@"deviceID"];
    self.name = [_parseTrack valueForKey:@"name"];
    self.dateCreated = _parseTrack.createdAt;
    
    // Get the waypoints relation for the track passed in.
    PFRelation *relation = [_parseTrack relationforKey:@"waypoints"];
    
    // Download the waypoints and enumerate through them.
    for(PFObject *parseWaypoint in [[relation query] findObjects]){
        
        // Create a waypoint.
        HWKWaypoint *waypoint = [[HWKWaypoint alloc] init];
        
        // Assign the waypoint's properties from the Parse waypoint.
        [waypoint assignPropertiesFromParseWaypoint:parseWaypoint];
        
        // Add the waypoint to the waypoints array.
        [self.waypoints addObject:waypoint];
    }
    
    // Create a sort descriptor.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeRecorded" ascending:YES];
    
    // Put that sort descriptor in an array.
    NSArray *sortDescriptors =  [NSArray arrayWithObject:sortDescriptor];
    
    // Sort the waypoints array.
    self.waypoints = [NSMutableArray arrayWithArray:[self.waypoints sortedArrayUsingDescriptors:sortDescriptors]];

}
-(void)assignPropertiesFromCoreDataTrack:(HWKTrackManagedObject *)_trackManagedObject{
    
    self.trackID = _trackManagedObject.trackID;
    self.deviceID = _trackManagedObject.deviceID;
    self.name = _trackManagedObject.name;
    self.dateCreated = _trackManagedObject.dateCreated;
    self.waypoints = [[NSMutableArray alloc] init];
    for (HWKWaypointManagedObject *waypointManagedObject in [_trackManagedObject.waypoints allObjects]){
        HWKWaypoint *waypoint = [[HWKWaypoint alloc] init];
        [waypoint assignPropertiesFromCoreDataWaypoint:waypointManagedObject];
        
        [self.waypoints addObject:waypoint];
        
    }
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeRecorded" ascending:YES];
    NSArray *sortDescriptors =  [NSArray arrayWithObject:sortDescriptor];
    
    self.waypoints =
    [NSMutableArray arrayWithArray:[self.waypoints
                                    sortedArrayUsingDescriptors:sortDescriptors]];
    
    
}

@end
