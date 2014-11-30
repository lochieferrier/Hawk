//
//  HWKFollowingViewController.m
//  Hawk
//
//  Created by Lochie Ferrier on 23/09/12.
//  Copyright (c) 2012 Lochie Ferrier. All rights reserved.
//

#import "HWKFollowingTableViewController.h"

@implementation HWKFollowingTableViewController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the background image.
    [self.tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"tableViewBackground.png"]]];
    
    // Set the managed object context.
    self.managedObjectContext = ((HWKAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
    
    // Alloc and init the track objects array.
    self.trackObjectsArray = [[NSMutableArray alloc] init];
    
    // Create an entity description.
    NSEntityDescription *trackEntityDescription = [NSEntityDescription entityForName:@"Track" inManagedObjectContext:self.managedObjectContext];
    
    // Create a fetch request.
    NSFetchRequest *trackFetchRequest = [[NSFetchRequest alloc] init];
    
    // Associate the entity description with the fetch request
    [trackFetchRequest setEntity:trackEntityDescription];
    
    // Create an error.
    NSError *error = nil;
    
    // Execute the fetch request and store the results in an array.
    NSArray *trackObjectArray = [self.managedObjectContext executeFetchRequest:trackFetchRequest error:&error];
    
    // Enumerate through the array of fetch request results.
    for (HWKTrackManagedObject *trackManagedObject in trackObjectArray){
        
        // Check that the track is not one the user has created.
        if ([trackManagedObject.deviceID isEqualToString: [[NSUserDefaults standardUserDefaults] stringForKey:@"deviceID"]]==NO){
            
            // Create a track.
            HWKTrack *track = [[HWKTrack alloc] init];
            
            // Assign the track's properties from the Core Data track.
            [track assignPropertiesFromCoreDataTrack:trackManagedObject];
            
            // Add the track to the track objects array.
            [self.trackObjectsArray addObject:track];
            
        }
        
    }
    
    // Set the navigation item's right bar button item to be an edit button.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    // Return 1 for the number of sections in the table view.
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    // Return the number of tracks in the array for the number of rows in the table view.
    return self.trackObjectsArray.count;
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // Create an NSString to store the cell table identifier.
    static NSString *CellTableIdentifier = @"CustomCell";
    
    // Create a track.
    HWKTrack *track = [self.trackObjectsArray objectAtIndex:indexPath.row];
    
    // Create a date formatter.
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    // Set the date formatter's date format.
    [dateFormatter setDateFormat:@"dd/MM yyyy"];
    
    // Create a cell.
    HWKCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellTableIdentifier forIndexPath:indexPath];
    
    // Set the cell's name label text to be the track's name.
    cell.nameLabel.text = track.name;
    
    // Set the cell's track ID label text to be the track's ID.
    cell.trackIDLabel.text = track.trackID;
    
    // Set the cell's date label text to be a formatted version of the track's date of creation.
    cell.dateLabel.text = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:track.dateCreated]];
    
    // Return the cell.
    return cell;
    
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // Get a reference to the viewer view controller.
    HWKViewerViewController *viewerViewController = [[self.navigationController viewControllers] objectAtIndex:1];
    
    // Enumerate through the tracks in the viewer view controller's track objects array.
    for (HWKTrack *track in viewerViewController.trackObjectsArray){
        
        // Check that the track's ID is equal to the one corresponding to the cell selected.
        if ([track.trackID isEqualToString:[[self.trackObjectsArray objectAtIndex:indexPath.row] trackID]]){
            
            // Set the viewer view controller's track object to be the track.
            viewerViewController.trackObject = track;
            
        }
        
    }
    
    // Set viewer view controller's navigation item's title to be the viewer view controller's track object name.
    viewerViewController.navigationItem.title = viewerViewController.trackObject.name;
    
    // Check that there is more than one waypoint in the viewer view controller's track object's waypoints array.
    if (viewerViewController.trackObject.waypoints.count > 1){
        
        // Get a reference to the last waypoint in the track's waypoints array.
        HWKWaypoint *lastWaypoint = [viewerViewController.trackObject.waypoints objectAtIndex:viewerViewController.trackObject.waypoints.count -1 ];
        
        // Set the viewer view controller's map view region.
        [viewerViewController.mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(lastWaypoint.latitude.doubleValue, lastWaypoint.longitude.doubleValue), MKCoordinateSpanMake(lastWaypoint.speed.intValue / 10000, lastWaypoint.speed.intValue / 10000)) animated:YES];
        
        // Update the viewer view controller's dashboard.
        [viewerViewController updateDashboard];
        
        // Enable the viewer view controller's dashboard button.
        viewerViewController.dashButton.enabled = YES;
        
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // Check that the editing style is deletion.
    if (editingStyle == UITableViewCellEditingStyleDelete){
        
        // Create a track.
        HWKTrack *track = [self.trackObjectsArray objectAtIndex:indexPath.row];
        
        // Get a reference to the viewer view controller.
        HWKViewerViewController *viewerViewController = [self.navigationController.viewControllers objectAtIndex:1];
        
        // Delete the track from Core Data. Not deleting from Parse because it is someone else's track.
        [[self.trackObjectsArray objectAtIndex:indexPath.row] deleteTrackAndWaypointsFromCoreData];
        
        // Create a track.
        HWKTrack *trackInViewerView;
        
        // Enumerate through the track's in the viewer view controller's track objects array.
        for (HWKTrack *enumeratedTrack in viewerViewController.trackObjectsArray){
            
            // Check that the enumerated track's track ID is equal to the track's ID.
            if ([enumeratedTrack.trackID isEqualToString:track.trackID]){
                
                // Set the track in the viewer view to be the enumerated track.
                trackInViewerView = enumeratedTrack;
                
                // Remove the annotations from the viewer view controller's map.
                [viewerViewController.mapView removeAnnotations:viewerViewController.mapView.annotations];
                
                // Remove the overlays from the viewer view controller's map.
                [viewerViewController.mapView removeOverlays:viewerViewController.mapView.overlays];
                
                // Check that the track's ID is equal to the viewer view controller's track object's track ID.
                if ([track.trackID isEqualToString:viewerViewController.trackObject.trackID]){
                    
                    // Set the viewer view controller's track object to be NULL.
                    viewerViewController.trackObject = NULL;
                    
                    // Set the viewer view controller's navigation item title to be "Following".
                    viewerViewController.navigationItem.title = @"Following";
                    
                    // Disable the viewer view controller's dashboard button.
                    viewerViewController.dashButton.enabled = NO;
                    
                    // Press the viewer view controller's map button.
                    [viewerViewController toolBarButtonPressed:viewerViewController.mapButton];
                    
                }
                
            }
            
        }
        
        // Remove the track from the viewer view controller's track objects array.
        [viewerViewController.trackObjectsArray removeObject:trackInViewerView];
        
        // Remove the track from the track objects array.
        [self.trackObjectsArray removeObject:[self.trackObjectsArray objectAtIndex:indexPath.row]];
        
        // Reset the number of rows in the table view.
        [self.tableView numberOfRowsInSection:self.trackObjectsArray.count];
        
        // Delete the row with an animation.
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
    
}

@end
