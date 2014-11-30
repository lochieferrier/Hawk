//
//  HWKViewerViewController.m
//  Hawk
//
//  Created by Lochie Ferrier on 18/09/12.
//  Copyright (c) 2012 Lochie Ferrier. All rights reserved.
//

#import "HWKViewerViewController.h"

@implementation HWKViewerViewController

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    // Set the managed object context to be that of the app delegate.
    self.managedObjectContext = ((HWKAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
    
    // Alloc and init the track objects array.
    self.trackObjectsArray = [[NSMutableArray alloc] init];
    
    // Create the Core Data entity.
    NSEntityDescription *trackEntityDescription = [NSEntityDescription entityForName:@"Track" inManagedObjectContext:self.managedObjectContext];
    
    
    // Create the fetch request.
    NSFetchRequest *trackFetchRequest = [[NSFetchRequest alloc] init];
    
    // Set the entity description for the request.
    [trackFetchRequest setEntity:trackEntityDescription];
    
    // Create an error.
    NSError *error = nil;
    
    // Execute the request and store the results in an array.
    NSArray *trackObjectArray = [self.managedObjectContext executeFetchRequest:trackFetchRequest error:&error];
    
    // Create an integer to track the current index of the array.
    int i = 0;
    
    // Enumerate through the array.
    for (HWKTrackManagedObject *trackManagedObject in trackObjectArray){
        
        // Increment i.
        i++;
        
        // Check that the track is not one that the user has created themselves.
        if ([trackManagedObject.deviceID isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"deviceID"]] == NO){
            
            // Create a track.
            HWKTrack *track = [[HWKTrack alloc] init];

            // Assign it's properties from the Core Data track.
            [track assignPropertiesFromCoreDataTrack:trackManagedObject];
            
            // Draw a line on the map with the track's waypoints.
            [self drawLineOnMapWithWaypoints:track.waypoints];
            
            // Create a Parse query.
            PFQuery *query = [PFQuery queryWithClassName:@"Track"];
            
            // Add the track to the track objects array.
            [self.trackObjectsArray addObject:track];
            
            // Execute the Parse query.
            [query getObjectInBackgroundWithId:track.trackID block:^(PFObject *parseTrack, NSError *error){
                
                // Create a track.
                HWKTrack *track = [[HWKTrack alloc] init];
                
                // Assign the properties of the track from the Parse track in the foreground.
                [track assignPropertiesFromParseTrackInForeground:parseTrack];
                
                // Assign the properties of the Core Data track from the track.
                [trackManagedObject assignPropertiesFromTrack:track];
                
                // Create an error.
                NSError *coreDataError = [[NSError alloc] init];
                
                // Save the managed object context.
                [self.managedObjectContext save:&coreDataError];
                
                // Check to see whether the current track is the last track in the track object array.
                if (i == trackObjectArray.count){
                    
                    // Download the tracks and waypoints and update the map.
                    [self downloadTracksAndWaypointsAndUpdateMap];
                    
                }
                
                if (track.waypoints.count > 1){
                    
#warning THIS NEEDS FIXING NOT ZOOMING;
                    
                    // Create a waypoint from the last waypoint object in the track's waypoints array.
                    HWKWaypoint *lastWaypoint = [track.waypoints objectAtIndex:track.waypoints.count -1];
                    
                    // Set the map view's region.
                    [self.mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(lastWaypoint.latitude.doubleValue, lastWaypoint.longitude.doubleValue), MKCoordinateSpanMake(lastWaypoint.speed.intValue / 10000, lastWaypoint.speed.intValue / 10000)) animated:YES];
                    
                }
                
            }];
            
        }
    }
    
    
    [self.mapView setDelegate:self];

    self.mapView.layer.cornerRadius = 5;
    self.mapView.layer.masksToBounds = YES;

    

    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    // Return YES for portrait orientation.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    
}


- (IBAction)trackerButtonPressed:(id)sender {
    
    // Pop the view controller off the stack.
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)addButtonPressed:(id)sender {
    
    // Create an alert view.
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Follow a new track" message:@"Please enter the ID of the track" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Follow", nil];
    
    // Set the alert view style to be a single text field input.
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    // Show the alert view.
    [alertView show];
    
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    // Check that the alert view's title is "Follow a new track".
    if ([alertView.title isEqualToString:@"Follow a new track"]){
        
        // Check that the "Follow" button was pressed.
        if (buttonIndex == 1){
            
            // Create a Parse query.
            PFQuery *query = [PFQuery queryWithClassName:@"Track"];
            
            // Create a progress HUD.
            MBProgressHUD *progressHUD = [[MBProgressHUD alloc] init];
            
            // Add the progress HUD to the navigation controller's view.
            [self.navigationController.view addSubview:progressHUD];
            
            // Set the progress HUD's delegate to be self.
            progressHUD.delegate = self;
            
            // Set the progress HUD's dim background to YES.
            progressHUD.dimBackground = YES;
            
            // Set the progress HUD's label text to be "Downloading".
            progressHUD.labelText = @"Finding";
            
            // Show the progress HUD.
            [progressHUD show:YES];
            
            // Execute the query.
            [query getObjectInBackgroundWithId:[[alertView textFieldAtIndex:0] text] block:^(PFObject *parseTrack, NSError *error){
                
                // Check that the track returned is not nil.
                if (parseTrack != nil){
                    
                    // Create a track.
                    HWKTrack *track = [[HWKTrack alloc] init];
                    
                    progressHUD.labelText = @"Downloading";
                    // Assign properties to the track from the parse track.
                    [track assignPropertiesFromParseTrackInForeground:parseTrack];
                    
                    // Check that the track's device ID is not the same as the one in the standard user defaults.
                    if ([track.deviceID isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"deviceID"] ] == NO){
                        
                        // Create a bool to track whether the track is already being followed.
                        BOOL alreadyFollowing = NO;
                        
                        // Loop through the track objects currently being followed.
                        for (HWKTrack *existingTrack in self.trackObjectsArray){
                            
                            // Check that the existing track's ID is not equal to the track's ID.
                            if ([existingTrack.trackID isEqualToString:track.trackID]){
                                
                                // Set already following to YES.
                                alreadyFollowing = YES;
                                
                            }
                            
                        }
                        
                        // Check that we're not already following the track.
                        if (alreadyFollowing == NO){
                            
                            // Create a managed track object and insert it into the managed object context.
                            HWKTrackManagedObject *trackManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Track" inManagedObjectContext:self.managedObjectContext];
                            
                            // Assign the track managed object's properties from the track.
                            [trackManagedObject assignPropertiesFromTrack:track];
                            
                            // Create an error.
                            NSError *coreDataError = [[NSError alloc] init];
                            
                            // Save the managed object context.
                            [self.managedObjectContext save:&coreDataError];
                            
                            // Draw a line on the map with the track's waypoints.
                            [self drawLineOnMapWithWaypoints:track.waypoints];
                            
                            // Add the track to the track objects array.
                            [self.trackObjectsArray addObject:track];
                            
                            // Set the current track object to be the new track.
                            self.trackObject = track;
                            
                            // Set the navigation item's title to be the track's name.
                            self.navigationItem.title = track.name;
                            
                            // Create a waypoint object from the last object in the track's waypoints array.
                            HWKWaypoint *lastWaypoint = [track.waypoints objectAtIndex:track.waypoints.count -1];
                            
                            // Hide the progress HUD after 2 seconds.
                            [progressHUD hide:YES afterDelay:2.0];
                            
                            // Set the map view's region with the last waypoint's latitude and longitude and zoom based on speed.
                            [self.mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(lastWaypoint.latitude.doubleValue, lastWaypoint.longitude.doubleValue), MKCoordinateSpanMake(lastWaypoint.speed.intValue / 10000, lastWaypoint.speed.intValue / 10000)) animated:YES];
                            
                            // Download the tracks and waypoints and update the map.
                            [self downloadTracksAndWaypointsAndUpdateMap];
                            
                            // Update the dashboard.
                            [self updateDashboard];
                            if (self.trackObject.waypoints.count > 2){
                                self.dashButton.enabled = YES;
                            }
                        }
                        else{
                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Not allowed" message:@"You're already following this track!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                            [progressHUD hide:YES];
                            [alertView show];
                        }
                    }
                    else{
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Not allowed" message:@"Sorry, you can't follow your own tracks" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                        [progressHUD hide:YES];
                        [alertView show];
                    }
                }
                else{
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Sorry, it appears that track doesn't exist or you don't have an internet connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                    [progressHUD hide:YES];
                    [alertView show];
                }
            }];
            
            
            
            
            
        }
    }
}

-(void)downloadTracksAndWaypointsAndUpdateMap{
    int i = 0;
    for (HWKTrack *track in self.trackObjectsArray){
        i++;
        PFQuery *query = [PFQuery queryWithClassName:@"Track"];
        [query getObjectInBackgroundWithId:track.trackID block:^(PFObject *object, NSError *error){
            
            
            HWKTrack *tempTrack = [[HWKTrack alloc] init];
            [tempTrack assignPropertiesFromParseTrackInBackground:object];
            
            if (tempTrack.waypoints.count > track.waypoints.count){
                NSMutableArray *shortenedWaypointsArray = [NSMutableArray arrayWithObjects:[track.waypoints objectAtIndex:track.waypoints.count -1],[track.waypoints objectAtIndex:track.waypoints.count -2], nil];
                [track assignPropertiesFromParseTrackInBackground:object];
                [self drawLineOnMapWithWaypoints:shortenedWaypointsArray];
                [self updateDashboard];
            }
            
            if (i == self.trackObjectsArray.count){
                [self downloadTracksAndWaypointsAndUpdateMap];
            }
            
            
        }];
        
    }
    
}



-(void)drawLineOnMapWithWaypoints:(NSMutableArray *)_waypoints{
    
    CLLocationCoordinate2D waypointCoordinatesArray[_waypoints.count];
    int i = 0;
    for (HWKWaypoint *waypoint in _waypoints){
        waypointCoordinatesArray[i] = CLLocationCoordinate2DMake(waypoint.latitude.doubleValue,waypoint.longitude.doubleValue);
        
        HWKMapAnnotation *mapAnnotation = [[HWKMapAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake(waypoint.latitude.doubleValue,waypoint.longitude.doubleValue )];
        [self.mapView addAnnotation:mapAnnotation];
        i++;
    }
    NSLog(@"Drew a line");
    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:waypointCoordinatesArray count:([_waypoints count])];
    
    [self.mapView addOverlay:polyline];
}
- (MKAnnotationView *)mapView:(MKMapView *)lmapView
            viewForAnnotation:(id <MKAnnotation>)annotation {
    
    HWKMapAnnotationView *mapAnnotationView = (HWKMapAnnotationView *)[self.mapView
                                                                       dequeueReusableAnnotationViewWithIdentifier:
                                                                       @"mapAnnotation"];
    if(mapAnnotationView == nil) {
        mapAnnotationView = [[HWKMapAnnotationView alloc] initWithAnnotation:annotation
                                                             reuseIdentifier:@"mapAnnotation"];
    }
    mapAnnotationView.annotation = annotation;
    return mapAnnotationView;
}
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay{
	
	if ([overlay isKindOfClass:[MKPolyline class]]) {
		
		MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
		polylineView.strokeColor = [UIColor colorWithRed:0.93 green:0.36 blue:0.30 alpha:0.50];
        
		polylineView.lineWidth = 10;
        polylineView.lineCap = kCGLineCapRound;
        
        
		return polylineView;
	}
	
	return [[MKOverlayView alloc] initWithOverlay:overlay];
	
}
- (IBAction)previousMetricButtonPressed:(id)sender {
    if (self.currentMetricIndex.intValue >= 1){
        self.currentMetricIndex = [NSNumber numberWithInt:self.currentMetricIndex.intValue - 1];
        
    }
    if (self.currentMetricIndex.intValue == 0){
        self.currentMetricIndex = [NSNumber numberWithInt:3];
    }
    [self updateDashboard];
}

- (IBAction)nextMetricButtonPressed:(id)sender {
    if (self.currentMetricIndex.intValue < 3){
        self.currentMetricIndex = [NSNumber numberWithInt:self.currentMetricIndex.intValue + 1];
        
    }
    else{
        self.currentMetricIndex = [NSNumber numberWithInt:0];
    }
    [self updateDashboard];
}

-(void)updateDashboard{
    
    // Check to see whether the current track object has more than 2 waypoints. This is to prevent array crashes.
    if (self.trackObject.waypoints.count > 2){
        
        // Get the last waypoint object and store it in an object for easy access.
        HWKWaypoint *lastWaypoint = [self.trackObject.waypoints objectAtIndex:self.trackObject.waypoints.count -1];
        
        // Each metric index is a different set of data. In this way, we simulate different screens (sorta).
        
        //***********************
        // SPEED, DISTANCE, TIME.
        //***********************
        
        if (self.currentMetricIndex.intValue == 0){
            
            // Set the main data label's text to be a simple km/h speed reading.
            self.mainDataLabel.text = [NSString stringWithFormat:@"%1.0f",lastWaypoint.speed.floatValue * 3.6];
            
            // Set the main metric label text to be "km/h".
            self.mainMetricLabel.text = @"km/h";
            
            // Create floats to store distance, average speed and max speed.
            float distance = 0;
            float averageSpeed = 0;
            float maxSpeed = 0;
            
            // Get the first waypoint object and store it in an object for easy access.
            HWKWaypoint *firstWaypoint = [self.trackObject.waypoints objectAtIndex:0];
            
            // Create a location object from the first waypoint's coordinates. It is named "lastLocation" because of the way it is used in the fast enumeration loop.
            CLLocation *lastLocation = [[CLLocation alloc] initWithLatitude:firstWaypoint.latitude.floatValue longitude:firstWaypoint.longitude.floatValue];
            
            // Loop through the track object's waypoints.
            for (HWKWaypoint *waypoint in self.trackObject.waypoints){
                
                // Create a location object from the current waypoint's coordinates.
                CLLocation *location = [[CLLocation alloc] initWithLatitude:waypoint.latitude.floatValue longitude:waypoint.longitude.floatValue];
                
                // Add the distance from the current location to the last to the distance variable.
                distance = distance + [location distanceFromLocation:lastLocation];
                
                // Set the last location to be the current location.
                lastLocation = location;
                
                // Add the waypoint's speed to the average speed.
                averageSpeed = averageSpeed + waypoint.speed.floatValue;
                
                // Check to see whether the waypoint's speed is faster than the max speed.
                if (waypoint.speed.floatValue > maxSpeed){
                    
                    // Set the max speed to be the waypoint's speed.
                    maxSpeed = waypoint.speed.floatValue;
                    
                }
                
            }
            
            // Check to see if the distance is less than 1000m.
            if (distance < 1000){
                
                // Set data label one's text to be the distance in meters.
                self.dataLabelOne.text = [NSString stringWithFormat:@"%1.0f m",distance];
                
            }
            
            else{
                
                // Divide the distance by 1000.
                distance = distance /1000;
                
                // Set data label one's text to be the distance in km.
                self.dataLabelOne.text = [NSString stringWithFormat:@"%.1f km",distance];
                
            }
            
            // Set metric label one's text to be "distance".
            self.metricLabelOne.text = @"distance";
            
            // Divide averageSpeed by the number of waypoints.
            averageSpeed = averageSpeed / self.trackObject.waypoints.count;
            
            // Set data label two's text to be the average speed in km/h.
            self.dataLabelTwo.text = [NSString stringWithFormat:@"%1.0f km/h",averageSpeed * 3.6];
            
            // Set metric label two's text to be "average speed".
            self.metricLabelTwo.text = @"average speed";
            
            // Set data label three's text to be the max speed in km/h.
            self.dataLabelThree.text = [NSString stringWithFormat:@"%1.0f km/h",maxSpeed * 3.6];
            
            // Set metric label three's text to be "max speed".
            self.metricLabelThree.text = @"max speed";
            
            // Calculate the seconds in between the last waypoint and the first waypoint.
            int secondsBetween = [lastWaypoint.timeRecorded timeIntervalSinceDate:firstWaypoint.timeRecorded];
            
            // Calculate the minutes.
            int minutes = floor(secondsBetween/60);
            
            // Calculate the seconds.
            int seconds = round(secondsBetween - minutes * 60);
            
            // Set data label four's text to be the time elapsed.
            self.dataLabelFour.text = [NSString stringWithFormat:@"%i:%i:%i",secondsBetween / 3600,minutes,seconds];
            
            // Set metric label four's text to be time elapsed.
            self.metricLabelFour.text = @"time elapsed";
            
        }
        
        //*********
        // ALTITUDE
        //*********
        
        if (self.currentMetricIndex.intValue == 1){
            
            // Set the main data label's text to be the last waypoint's altitude in m.
            self.mainDataLabel.text = [NSString stringWithFormat:@"%1.0f",lastWaypoint.altitude.floatValue];
            
            // Set the main metric label's text to be "m".
            self.mainMetricLabel.text = @"m";
            
            // Create floats to store climbed, descended
            float climbed = 0;
            float descended = 0;
            float average = 0;
            
            // Create an integer to track the index of the array.
            int i;
            
            for (i = 0; i < self.trackObject.waypoints.count; i++){
                
                // Check that i > 1.
                if (i > 1){
                    
                    // Create a waypoint object from the array at the current index.
                    HWKWaypoint *waypoint = [self.trackObject.waypoints objectAtIndex:i];
                    
                    // Create a waypoint object from the waypoint recorded before the one above.
                    HWKWaypoint *lastWaypoint = [self.trackObject.waypoints objectAtIndex:i-1];
                    
                    // Check that the last waypoint's altitude was higher than the one before.
                    if (waypoint.altitude.floatValue > lastWaypoint.altitude.floatValue){
                        
                        // Add the difference in meters to the climbed float.
                        climbed = climbed + (waypoint.altitude.floatValue - lastWaypoint.altitude.floatValue);
                        
                    }
                    
                    // Check that the last waypoint's altitude was lower than the one before.
                    if (waypoint.altitude.floatValue < lastWaypoint.altitude.floatValue){
                        
                        // Add the difference in meters to the descended float.
                        descended = descended + (lastWaypoint.altitude.floatValue - waypoint.altitude.floatValue);
                        
                    }
                    
                    // Add the altitude of the last waypoint to the average float.
                    average = average + waypoint.altitude.floatValue;
                    
                }
                
            }
            
            // Create floats to store seconds between, meters between and rate.
            float secondsBetween = 0;
            float metersBetween = 0;
            float rate = 0;
            
            // Create a waypoint from the second last waypoint in the track's waypoints array.
            HWKWaypoint *secondLastWaypoint = [self.trackObject.waypoints objectAtIndex:self.trackObject.waypoints.count -2];
            
            // Set the seconds between to be the interval between the last and the second last waypoint's time recorded.
            secondsBetween = [lastWaypoint.timeRecorded timeIntervalSinceDate:secondLastWaypoint.timeRecorded];
            
            // Set the meters between to be the difference in altitude between the two.
            metersBetween = lastWaypoint.altitude.floatValue -  secondLastWaypoint.altitude.floatValue;
            
            // Set the rate to be metersBetween divided by seconds between.
            rate = metersBetween / secondsBetween;
            
            // Set data label one's text to be the rate in m/s.
            self.dataLabelOne.text = [NSString stringWithFormat:@"%1.0f m/s",rate];
            
            // Set metric label one's text to be "rate".
            self.metricLabelOne.text = @"rate";
            
            // Set average to be average divided by the number of waypoints in the track object's waypoints array.
            average = average / self.trackObject.waypoints.count;
            
            // Set data label two's text to be the average altitude in meters.
            self.dataLabelTwo.text = [NSString stringWithFormat:@"%1.0f m",average];
            
            // Set metric label two text to be "average".
            self.metricLabelTwo.text = @"average";
            
            // Set data label three's text to be the meters climbed.
            self.dataLabelThree.text = [NSString stringWithFormat:@"%1.0f m",climbed];
            
            // Set metric label three's text to be "climbed".
            self.metricLabelThree.text = @"climbed";
            
            // Set data label four's text to be the meters descended.
            self.dataLabelFour.text = [NSString stringWithFormat:@"%1.0f m",descended];
            
            // Set metric label four's text to be "descended".
            self.metricLabelFour.text = @"descended";
            
        }
        
        //********
        // COMPASS
        //********
        
        if (self.currentMetricIndex.intValue == 2){
            
            // Set the main data label's text to be the heading of the last waypoint.
            self.mainDataLabel.text = [NSString stringWithFormat:@"%1.0f",lastWaypoint.heading.floatValue];
            
            // Set the main metric label's text to be "degreees".
            self.mainMetricLabel.text = @"degrees";
            
            // Set the labels below text to be "".
            self.dataLabelOne.text = @"";
            self.metricLabelOne.text = @"";
            self.dataLabelTwo.text = @"";
            self.metricLabelTwo.text = @"";
            self.dataLabelThree.text = @"";
            self.metricLabelThree.text = @"";
            self.dataLabelFour.text = @"";
            self.metricLabelFour.text = @"";
            
        }
        
        //**********
        // WAYPOINTS
        //**********
        
        if (self.currentMetricIndex.intValue == 3){
            
            // Set the main data label's text to be the number of waypoints.
            self.mainDataLabel.text = [NSString stringWithFormat:@"%i",self.trackObject.waypoints.count];
            
            // Set the main metric label's text to be "waypoints".
            self.mainMetricLabel.text = @"waypoints";
            
            // Set the labels below text to be "".
            self.dataLabelOne.text = @"";
            self.metricLabelOne.text = @"";
            self.dataLabelTwo.text = @"";
            self.metricLabelTwo.text = @"";
            self.dataLabelThree.text = @"";
            self.metricLabelThree.text = @"";
            self.dataLabelFour.text = @"";
            self.metricLabelFour.text = @"";
            
        }
        
        // Create a date formatter object.
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        // Set the date formatter's format.
        [dateFormatter setDateFormat:@"h:mm a"];
        
        // Set the date updated label's text to be a formatted version of the current date.
        self.dateUpdatedLabel.text = [NSString stringWithFormat:@"Updated at %@ ", [dateFormatter stringFromDate:[NSDate date]]];
        
        // Enable the dash button.
        self.dashButton.enabled = YES;
        
    }
    
}
- (IBAction)toolBarButtonPressed:(id)sender {
    //Create a UIBarButtonItem object from the sender object
    
    UIBarButtonItem *barButtonItem = (UIBarButtonItem *)sender;
    
    //Hide all the UI
    self.mapElementsView.hidden = YES;
    self.dashboardElementsView.hidden = YES;
    
    //Each if statement checks to see what button was pressed and shows elements accordingly
    
    if (barButtonItem.tag == 1){
        self.mapElementsView.hidden = NO;
    }
    
    if (barButtonItem.tag == 2) {
        self.dashboardElementsView.hidden = NO;
    }
    
}


@end
