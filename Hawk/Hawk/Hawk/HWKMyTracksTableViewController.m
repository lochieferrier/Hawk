//
//  HWKMyTracksTableViewController.m
//  Hawk
//
//  Created by Lochie Ferrier on 19/09/12.
//  Copyright (c) 2012 Lochie Ferrier. All rights reserved.
//

#import "HWKMyTracksTableViewController.h"

@implementation HWKMyTracksTableViewController

@synthesize trackObjectsArray;
- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    // Set the background image.
    [self.tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"tableViewBackground.png"]]];
    
	// Set the managed object context to be that of the app delegate.
    self.managedObjectContext = ((HWKAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
    
    // Create an entity description.
    NSEntityDescription *trackEntityDescription = [NSEntityDescription entityForName:@"Track" inManagedObjectContext:self.managedObjectContext];
    
    // Create a fetch request.
    NSFetchRequest *trackFetchRequest = [[NSFetchRequest alloc] init];
    
    // Alloc and init the track objects array.
    self.trackObjectsArray = [[NSMutableArray alloc] init];
    
    // Set the fetch request's entity.
    [trackFetchRequest setEntity:trackEntityDescription];
    
    // Create an error.
    NSError *error = nil;
    
    // Execute the fetch request and store the results in an array.
    NSArray *theTrackObjectArray = [self.managedObjectContext executeFetchRequest:trackFetchRequest error:&error];
    
    // Create a sort descriptor.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:NO];
    
    // Put that sort descriptor into an array.
    NSArray *sortDescriptors =  [NSArray arrayWithObject:sortDescriptor];
    
    // Sort the array using the descriptor.
    theTrackObjectArray = [theTrackObjectArray sortedArrayUsingDescriptors:sortDescriptors];
    
    // Enumerate through the tracks in the sorted fetch request results.
    for (HWKTrackManagedObject *trackManagedObject in theTrackObjectArray){
        
        // Check that the track is one the user has created.
        if ([trackManagedObject.deviceID isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"deviceID"]]){
            
            // Create a track.
            HWKTrack *track = [[HWKTrack alloc] init];
            
            // Assign the track's properties from the core data track.
            [track assignPropertiesFromCoreDataTrack:trackManagedObject];
            
            // Add the track to the track objects array.
            [self.trackObjectsArray addObject:track];
            
        }
        
    }
    
    // Set the navigation bar's right bar button item to be an edit button.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    // Return YES if the proposed interface orientation is portrait.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return 1 for the number of sections in the table view.
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return how many objects there are in the track objects array for the number of rows in the table view.
    return self.trackObjectsArray.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Create a NSString to store the cell table identifier.
    static NSString *CellTableIdentifier = @"CustomCell";
    
    // Create a track.
    HWKTrack *track = [self.trackObjectsArray objectAtIndex:indexPath.row];
    
    // Create a cell.
    HWKCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellTableIdentifier forIndexPath:indexPath];
    
    // Set the cell's name label's text to be the track's name.
    cell.nameLabel.text = track.name;
    
    // Set the cell's track ID label's text to be the track's ID.
    cell.trackIDLabel.text = track.trackID;
    
    // Create a date formatter.
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    // Set the date format.
    [dateFormatter setDateFormat:@"dd/MM yyyy"];
    
    // Set the cell's date label text to be a formatted version of the track's date of creation.
    cell.dateLabel.text = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:track.dateCreated]];
    
    // Get a reference to the tracker view controller.
    HWKTrackerViewController *viewerViewController = [self.navigationController.viewControllers objectAtIndex:0];
    
    // Hide the cell's currently tracking image. Otherwise it will show up on re-use.
    cell.isCurrentlyTrackingImage.hidden = YES;
    
    // Check that the viewer view controller's track ID is equal to the current track.
    if ([viewerViewController.trackObject.trackID isEqualToString:track.trackID]){
        
        // Show the currently tracking image.
        cell.isCurrentlyTrackingImage.hidden = NO;
        
    }
    
    // Return the cell.
    return cell;
    
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Get a reference to the tracker view controller.
    HWKTrackerViewController *trackerViewController = [self.navigationController.viewControllers objectAtIndex:0];
    
    // Create a track managed object from the object in the array
    HWKTrack *track = [self.trackObjectsArray objectAtIndex:indexPath.row];
    
    // Set the tracker view controller's track object to be the track.
    trackerViewController.trackObject = track;
    
    // Set the tracker view controller's share button.
    trackerViewController.shareButton.enabled = YES;
    
    // Set the tracker view controller's dashboard button to be enabled.
    trackerViewController.dashButton.enabled = YES;
    
    // Set the tracker view controller's map button to be enabled.
    trackerViewController.mapButton.enabled = YES;
    
    // Draw a line on the tracker view controller's map using the waypoints of the track.
    [trackerViewController drawLineOnMapWithWaypoints:trackerViewController.trackObject.waypoints];
    
    // Get a reference to the last waypoint in the track's waypoints array for easy access.
    HWKWaypoint *lastWaypoint = [trackerViewController.trackObject.waypoints objectAtIndex:trackerViewController.trackObject.waypoints.count-1];
    
    // Create a coordinate from that waypoint.
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(lastWaypoint.latitude.doubleValue, lastWaypoint.longitude.doubleValue);
    
    // Set the tracker view controller's region to be centered on that region.
    [trackerViewController.mapView setRegion:MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0.001, 0.001)) animated:YES];
    
    // Set the tracker view controller's navigation item's title to be the track's name.
    trackerViewController.navigationItem.title = track.name;
    
    // Update the tracker view controller's dashboard.
    [trackerViewController updateDashboard];
    
    // Pop self of the view controller stack.
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // Check that the editing style is deletion.
    if (editingStyle == UITableViewCellEditingStyleDelete){
        
        // Get a reference to the tracker view controller.
        HWKTrackerViewController *trackerViewController = [self.navigationController.viewControllers objectAtIndex:0];
        
        // Check that the tracker view controller's track ID is equal to the one corresponding to the cell deleted.
        if ([trackerViewController.trackObject.trackID isEqualToString:[[self.trackObjectsArray objectAtIndex:indexPath.row] trackID]]){
            
            // Set the tracker view controller's navigation item title to be "Me".
            trackerViewController.navigationItem.title = @"Me";
            
            // Remove the annotations from the tracker view controller's map view.
            [trackerViewController.mapView removeAnnotations:trackerViewController.mapView.annotations];
            
            // Remove the overlays from the tracker view controller's map view.
            [trackerViewController.mapView removeOverlays:trackerViewController.mapView.overlays];
            
            // Turn off uploading on the tracker view controller's.
            [trackerViewController turnOffUploading];
            
            // Set the tracker view controller's track object to be NULL.
            trackerViewController.trackObject = NULL;
            
            // Diasble the tracker view controller's share button.
            trackerViewController.shareButton.enabled = NO;
            
            // Disable the tracker view controller's dash button.
            trackerViewController.dashButton.enabled = NO;
            
            // Press the tracker view controller's map button.
            [trackerViewController toolbarButtonPressed:trackerViewController.mapButton];
            
        }
        
        // Delete the track and waypoints from Core Data and Parse.
        [[self.trackObjectsArray objectAtIndex:indexPath.row] deleteTrackAndWaypointsFromCoreDataAndParse];
        
        // Remove the track from the track objects array.
        [trackObjectsArray removeObject:[trackObjectsArray objectAtIndex:indexPath.row]];
        
        // Delete the row from the table view with an animation.
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
    
}

@end
