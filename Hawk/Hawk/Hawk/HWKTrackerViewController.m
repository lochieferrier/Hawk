//
//  HWKTrackerViewController.m
//  Hawk
//
//  Created by Lochie Ferrier on 8/09/12.
//  Copyright (c) 2012 Lochie Ferrier. All rights reserved.
//

#import "HWKTrackerViewController.h"

@interface HWKTrackerViewController ()

@end

@implementation HWKTrackerViewController
@synthesize onButton;
@synthesize mapView;
@synthesize locationManager;
@synthesize trackObject;
@synthesize managedObjectContext;
@synthesize isUploading;

- (void)viewDidLoad
{

    
    [super viewDidLoad];
    
    // Set the managed object context to be that of the app delegate.
    self.managedObjectContext = ((HWKAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
    
    // Set the color of the on button to be a gray - turned off.
    self.onButton.tintColor = [UIColor colorWithRed:0.62 green:0.61 blue:0.63 alpha:1.00];
    
    // Set the on button's title to be "Off".
    self.onButton.title = @"Off";
    
    // Alloc and init the track object.
    self.trackObject = [[HWKTrack alloc] init];
    
    // Alloc and init the location manager.
    self.locationManager = [[CLLocationManager alloc] init];
    
    // Set the location manager's delegate to self.
    self.locationManager.delegate = self;
    
    // Set the distance filter to none.
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    
    // Set the accuracy of the location manager to be the best possible.
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    // Set the map view's delegate to be self.
    [self.mapView setDelegate:self];

    // Set the dashboard elements view to be hidden.
    self.dashboardElementsView.hidden = YES;
    
    // Set the share view to be hidden.
    self.shareView.hidden = YES;
    
    // Set the track user location on map view BOOL to be YES. This means that by default the map view zooms and centers on the latest waypoint.
    self.trackUserLocationOnMapView = YES;
    
    // Set the current dashboard metric index to be 0.
    self.currentMetricIndex = [NSNumber numberWithInt:0];
    
    // Round the corners of the map view.
    self.mapView.layer.cornerRadius = 5;
    self.mapView.layer.masksToBounds = YES;
    
    self.progressHUD = [[MBProgressHUD alloc] init];
    [self.navigationController.view addSubview:self.progressHUD];
    self.progressHUD.delegate = self;
    self.progressHUD.dimBackground = YES;

}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    // Only return YES if the proposed interface orientation is portrait.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    
}

-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
    
    // Update the dashboard.
    [self updateDashboard];
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    //**********************************************************************************************************
    // ASTRONOMICAL CALCULATIONS. OMITTED FOR NOW. TOO COMPLICATED AND THERE IS AN ISSUE WITH THE LAUNCH SCREEN.
    //**********************************************************************************************************
    
    /*
    GeoLocation *geoLocation = [[GeoLocation alloc] initWithName:@"Location" andLatitude:newLocation.coordinate.latitude andLongitude:newLocation.coordinate.longitude andTimeZone:[NSTimeZone localTimeZone]];
    AstronomicalCalendar *astronomicalCalendar = [[AstronomicalCalendar alloc] initWithLocation:geoLocation];
    NSTimeInterval timeFromSunrise = [[astronomicalCalendar sunrise] timeIntervalSinceNow];
    NSTimeInterval timeFromSunset = [[astronomicalCalendar sunset] timeIntervalSinceNow];
    
    if (timeFromSunrise > 0 && timeFromSunrise < 3600){
        //Sunrise!
        self.backgroundImage.image = [UIImage imageNamed:@"sunriseBackground.png"];
        
    }
    if (timeFromSunrise > 0 && timeFromSunset < 3600){
        //Daytime!
        self.backgroundImage.image = [UIImage imageNamed:@"dayBackground.png"];
        
    }
    if (timeFromSunset > -3600 && timeFromSunset < 0){
        //Sunset!
        self.backgroundImage.image = [UIImage imageNamed:@"sunriseBackground.png"];
        
    }
    if (timeFromSunrise < 0 && timeFromSunset < 0){
        //Nighttime!
        self.backgroundImage.image = [UIImage imageNamed:@"nightBackground.png"];
        
    }
    */
    
    // Check to see whether we should upload, that the current track object is valid, that the new coordinate is valid and that the new coordinate is not a dodgy middle of the sea reading.
    if (self.isUploading = YES && self.trackObject.trackID != nil && CLLocationCoordinate2DIsValid(newLocation.coordinate) && newLocation.coordinate.longitude != 0.0 && oldLocation.coordinate.latitude != 0.0){
        
        // Set the navigation item's title to be the name of the track object.
        self.navigationItem.title = self.trackObject.name;
        
        // Hide the progres HUD after 2 seconds.
        [self.progressHUD hide:YES afterDelay:2.0];
        
        // Create a waypoint object.
        HWKWaypoint *waypoint = [[HWKWaypoint alloc] init];
        
        // Set the waypoint object's properties.
        waypoint.heading = [NSNumber numberWithFloat:self.locationManager.heading.trueHeading];
        waypoint.latitude = [NSNumber numberWithFloat:newLocation.coordinate.latitude];
        waypoint.longitude = [NSNumber numberWithFloat:newLocation.coordinate.longitude];
        waypoint.speed = [NSNumber numberWithFloat:newLocation.speed];
        waypoint.altitude = [NSNumber numberWithFloat:newLocation.altitude];
        waypoint.timeRecorded = [NSDate date];
        
        // Save the waypoint object to Parse and Core Data.
        [waypoint saveToParseAndCoreDataWithTrackID:trackObject.trackID];
        
        // Add the waypoint to the current track object's array.
        [self.trackObject.waypoints addObject:waypoint];
        
        // Check to see whether there are enough waypoints to draw a line and update the dashboard.
        if(self.trackObject.waypoints.count > 2){
            
            // Create a shortened array with only the waypoints we need. This speeds up drawing.
            NSMutableArray *shortenedArray = [NSMutableArray arrayWithObjects:[self.trackObject.waypoints objectAtIndex:self.trackObject.waypoints.count -2],[self.trackObject.waypoints objectAtIndex:self.trackObject.waypoints.count-1],nil];
            
            // Check to see whether we are automatically centering the map on the last waypoint.
            if(self.trackUserLocationOnMapView == YES){
                
                // Center the map view on the last location and do a "speed zoom".
                [self.mapView setRegion:MKCoordinateRegionMake(newLocation.coordinate, MKCoordinateSpanMake(newLocation.speed / 10000, newLocation.speed / 10000)) animated:YES];
                
            }
            
            // Draw the line.
            [self drawLineOnMapWithWaypoints:shortenedArray];
            
            // Update the dashboard.
            [self updateDashboard];
            
        }
        
    }
    
}

-(void)drawLineOnMapWithWaypoints:(NSMutableArray *)_waypoints{
    
    // Create a C based array to store the CLLocationCoordinate2D objects.
    CLLocationCoordinate2D waypointCoordinatesArray[_waypoints.count];
    
    // Create an integer to track the current array index.
    int i = 0;
    
    //Enumerate throught the waypoints in the array.
    for (HWKWaypoint *waypoint in _waypoints){
        
        // Set the part of the array at i to be a CLLocationCoordinate2D object made from the current waypoint object.  
        waypointCoordinatesArray[i] = CLLocationCoordinate2DMake(waypoint.latitude.doubleValue,waypoint.longitude.doubleValue);
        
        // Create a custom annotation set it's coordinate to be that of the current waypoint.
        HWKMapAnnotation *mapAnnotation = [[HWKMapAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake(waypoint.latitude.doubleValue,waypoint.longitude.doubleValue )];
        
        // Add the annotation to the map view.
        [self.mapView addAnnotation:mapAnnotation];
        
        // Increment i.
        i++;
        
    }
    
    // Create a polyline from the array of coordinates.
    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:waypointCoordinatesArray count:([_waypoints count])];
    
    // Add the polyline to the map view.
    [self.mapView addOverlay:polyline];
    
}
- (MKAnnotationView *)mapView:(MKMapView *)lmapView
            viewForAnnotation:(id <MKAnnotation>)annotation {
    
    // Create a HWKMapAnnotationView
    HWKMapAnnotationView *mapAnnotationView = (HWKMapAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"mapAnnotation"];
    
    // Check to see whether the map annotation view is nil.
    if(mapAnnotationView == nil) {
        
        // Alloc and init the map annotation view.
        mapAnnotationView = [[HWKMapAnnotationView alloc] initWithAnnotation:annotation
                                                             reuseIdentifier:@"mapAnnotation"];
    }
    
    // Set the map annotation view's annotation to be the passed in annotation.
    mapAnnotationView.annotation = annotation;
    
    // Return the annotation view.
    return mapAnnotationView;
    
}
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay{
	
    // Check to see whether the overlay is a polyline.
	if ([overlay isKindOfClass:[MKPolyline class]]) {
		
        // Create a polyline view.
		MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
        
        // Set the polyline view's stroke to be a half opacity red.
		polylineView.strokeColor = [UIColor colorWithRed:0.93 green:0.36 blue:0.30 alpha:0.50];

        // Set the polyline view's width to be 5 pixels.
		polylineView.lineWidth = 5;
        
        // Set the polyline view's line cap to be round.
        polylineView.lineCap = kCGLineCapRound;

        // Return the polyline view.
		return polylineView;
        
	}
	
    // Return an overlay.
	return [[MKOverlayView alloc] initWithOverlay:overlay];
	
}
 
- (IBAction)newTrackButtonPressed:(id)sender {
    
    // Create an alert view.
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"New Track" message:@"Please enter a track name." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create",nil];
    
    // Set the alert view's style to be a single text field input style.
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    // Show the alert view.
    [alertView show];
    
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    // Check that the alert view is the new track alert view.
    if ([actionSheet.title isEqualToString:@"New Track"]){
        
        // Check that the "Create!" button was pressed
        if (buttonIndex == 1){
            
            // Create a track object.
            HWKTrack *track = [[HWKTrack alloc] init];
            
            // Set the track's name to be what was entered in the text field.
            track.name = [actionSheet textFieldAtIndex:0].text;
            
            // Set the track's date of creation to be the current date.
            track.dateCreated = [NSDate date];
            
            // Alloc and init the track's waypoints array.
            track.waypoints = [[NSMutableArray alloc] init];
            
            // Set the progress HUD's text to be "Uploading".
            self.progressHUD.labelText = @"Uploading";
            
            // Show the progress HUD.
            [self.progressHUD show:YES];
            
            // Press the map button.
            [self toolbarButtonPressed:self.mapButton];
            
            // Disable the dashboard button.
            self.dashButton.enabled = NO;
            
            // Disable the share button.
            self.shareButton.enabled = NO;
            
            // Save the track to Parse and Core Data with the current location manager.
            [track saveToParseAndCoreDataWithTrackerViewController:self];
            
            // Set the current track object to be the newly created track.
            self.trackObject = track;
            
            // Remove existing map overlays.
            [self.mapView removeOverlays:self.mapView.overlays];
            
            // Remove existing map annotations.
            [self.mapView removeAnnotations:self.mapView.annotations];
            
            // Turn on uploading.
            [self turnOnUploading];
            
            
            
            
        }
        
    }
    
}
-(void)showNoInternetConnectionAlertView{
    
    // Hide the progress HUD.
    [self.progressHUD hide:YES];
    
    // Create an alert view.
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Failed" message:@"Sorry, you need an Internet connection to create a track." delegate:self cancelButtonTitle:NULL otherButtonTitles:@"Okay", nil];
    
    // Show the alert view.
    [alertView show];
    
}
- (IBAction)followLocationSegmentedControlValueChanged:(id)sender {
    
    // Create a segmented control from the sender.
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    
    // Check to see which button was pressed.
    if (segmentedControl.selectedSegmentIndex == 0){
        
        // Turn off map centering / zooming.
        self.trackUserLocationOnMapView = NO;
        
    }
    else{
        
        // Turn on map centering / zooming.
        self.trackUserLocationOnMapView = YES;
        
    }
}



- (IBAction)onButtonPressed:(id)sender {
    
    // Check to see whether we are currently uploading.
    if (self.isUploading == YES){
        
        // Turn on uploading.
        [self turnOffUploading];
        
    }
    
    else{
        
        // Turn off uploading.
        [self turnOnUploading];
        
    }

}

-(void)turnOnUploading{
    
    // Turn uploading on.
    self.isUploading = YES;
    
    // Check to see whether the track object has a name.
    if(self.trackObject.name == nil){
        
        // Press the new track button.
        [self newTrackButtonPressed:self.navigationController.navigationItem.rightBarButtonItem];
        
    }
    else{
        
        // Start updating location.
        [self.locationManager startUpdatingLocation];
        
        // Start updating heading.
        [self.locationManager startUpdatingHeading];
        
        //Set the on button's title to be "On".
        self.onButton.title = @"On";
        
        // Set the on button's tint color to be a green color.
        self.onButton.tintColor = [UIColor colorWithRed:0.06 green:0.73 blue:0.07 alpha:1.00];
        
        // Show the follow location on map view segmented control.
        self.followLocationOnMapViewSegmentedControl.hidden = NO;
        
    }
    
    
    
    
}

-(void)turnOffUploading{
    
    // Turn off uploading.
    self.isUploading = NO;
    
    // Set the on button's title to be "Off".
    self.onButton.title = @"Off";
    
    // Set the on button's tint color to be gray.
    self.onButton.tintColor = [UIColor colorWithRed:0.62 green:0.61 blue:0.63 alpha:1.00];
    
    // Hide the follow location on map view segmented control.
    self.followLocationOnMapViewSegmentedControl.hidden = YES;
    
    // Stop updating location.
    [self.locationManager stopUpdatingLocation];
    
    // Stop updating heading.
    [self.locationManager stopUpdatingHeading];
    
}

- (IBAction)toolbarButtonPressed:(id)sender {
    
    // Create a UIBarButtonItem object from the sender object
    UIBarButtonItem *barButtonItem = (UIBarButtonItem *)sender;
    
    // Hide the share view.
    self.shareView.hidden = YES;
    
    // Hide the map elements view.
    self.mapElementsView.hidden = YES;
    
    // Hide the dashboard element's view.
    self.dashboardElementsView.hidden = YES;
    
    // Check to see which bar button item was pressed and show views accordingly.
    if (barButtonItem.tag == 0){
        
        self.shareView.hidden = NO;
        
    }
    
    if (barButtonItem.tag == 1) {
        
        self.dashboardElementsView.hidden = NO;
        
    }
    
    if (barButtonItem.tag == 3) {
        
        self.mapElementsView.hidden = NO;
        
    }
    
}

- (IBAction)facebookButtonPressed:(id)sender {
    
    // Create a facebook compose view controller.
    SLComposeViewController *fbViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    
    // Set the facebook compose view controller's text.
    [fbViewController setInitialText:[NSString stringWithFormat:@"Check out my Hawk track at this track ID: %@",self.trackObject.trackID]];
    
    // Present the facebook compose view controlller's.
    [self presentViewController:fbViewController animated:YES completion:NULL];
     
}

- (IBAction)twitterButtonPressed:(id)sender {
    
    // Create a twitter compose view controller.
    SLComposeViewController *twitterViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    
    // Set the twitter compose view controller's text.
    [twitterViewController setInitialText:[NSString stringWithFormat:@"Check out my Hawk track at this track ID: %@",self.trackObject.trackID]];
    
    // Present the twitter compose view controller.
    [self presentViewController:twitterViewController animated:YES completion:NULL];
    
}

- (IBAction)emailButtonPressed:(id)sender {
    
    // Create a mail compose view controller
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    // Set the mail compose view controller's subject.
    [picker setSubject:self.navigationItem.title];
 
    // Set the compose view controller's body.
    [picker setMessageBody:[NSString stringWithFormat:@"Check out my Hawk track at this ID:%@",self.trackObject.trackID] isHTML:YES];
    
    // Set the mail compose view's navigation bar style.
    picker.navigationBar.barStyle = UIBarStyleBlack;
    
    // Present the mail compose view controller.
    [self presentModalViewController:picker animated:YES];

}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    
    // Check for errors and if one occurs show an alert view.
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            break;
            
        default:
        {
            
            // Create an alert view.
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email" message:@"Sending Failed - Unknown Error"
                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            
            // Show the alert view.
            [alert show];

        }
            
            break;
            
    }
    
    // Dismiss the mail compose view controller.
    [self dismissModalViewControllerAnimated:YES];
    
}
- (IBAction)previousMetricButtonPressed:(id)sender {
    
    // Check to see whether the current metric index is greater than 0.
    if (self.currentMetricIndex.intValue > 0){
        
        // Decrement the current metric index.
        self.currentMetricIndex = [NSNumber numberWithInt:self.currentMetricIndex.intValue - 1];
        
    }
    
    
    else{
        
        // Set the current metric index to be 3.
        self.currentMetricIndex = [NSNumber numberWithInt:3];
        
    }
    
    // Update the dashboard.
    [self updateDashboard];
    
}

- (IBAction)nextMetricButtonPressed:(id)sender {
    
    // Check to see whether the current metric index is less than 3.
    if (self.currentMetricIndex.intValue < 3){
        
        // Increment the current metric index.
        self.currentMetricIndex = [NSNumber numberWithInt:self.currentMetricIndex.intValue + 1];
        
    }
    else{
        
        // Set the current metric index to be 0.
        self.currentMetricIndex = [NSNumber numberWithInt:0];
        
    }
    
    // Update the dashboard.
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
            self.mainDataLabel.text = [NSString stringWithFormat:@"%1.0f",self.locationManager.location.speed * 3.6];
            
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
            
            // Set the main data label's text to be the altitude in m.
            self.mainDataLabel.text = [NSString stringWithFormat:@"%1.0f",self.locationManager.location.altitude];
            
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
            
            // Create a float which is an average of both the magnetic and true heading.
            float averageHeading = (self.locationManager.heading.trueHeading + self.locationManager.heading.magneticHeading) / 2;
            
            // Set the main data label's text to be the average heading.
            self.mainDataLabel.text = [NSString stringWithFormat:@"%1.0f",averageHeading];
            
            // Set the main metric label's text to be "degreees".
            self.mainMetricLabel.text = @"degrees";
            
            // Set data label one's text to be the true heading.
            self.dataLabelOne.text = [NSString stringWithFormat:@"%1.0f°",self.locationManager.heading.trueHeading];
            
            // Set metric label one's text to be "true".
            self.metricLabelOne.text = @"true";
            
            // Set data label two's text to be the magnetic heading.
            self.dataLabelTwo.text = [NSString stringWithFormat:@"%1.0f°",self.locationManager.heading.magneticHeading];
            
            // Set metric label two's text to be "magnetic".
            self.metricLabelTwo.text = @"magnetic";
            
            // Set the labels below text to be "".
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
        
        // Enable the share button.
        self.shareButton.enabled = YES;
        
    }
    
}
@end
