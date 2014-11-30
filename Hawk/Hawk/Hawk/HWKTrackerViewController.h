//
//  HWKTrackerViewController.h
//  Hawk
//
//  Created by Lochie Ferrier on 8/09/12.
//  Copyright (c) 2012 Lochie Ferrier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HWKTrack.h"
#import "HWKWaypoint.h"
#import "HWKMapAnnotation.h"
#import "HWKMapAnnotationView.h"
#import "HWKAppDelegate.h"
#import "HWKTrackManagedObject.h"
#import "HWKWaypointManagedObject.h"
#import "MBProgressHUD.h"
#import <Social/Social.h>
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>

@class HWKTrackerViewController;

@interface HWKTrackerViewController
: UIViewController <CLLocationManagerDelegate ,UIAlertViewDelegate, MKMapViewDelegate, MFMailComposeViewControllerDelegate, MBProgressHUDDelegate>

//*********************************
// Map view properties and methods.
//*********************************

// The superview of the map elements.
@property (weak, nonatomic) IBOutlet UIView *mapElementsView;

// The map view.
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

// A bool to track whether to zoom and center on the user location on the map view.
@property BOOL trackUserLocationOnMapView;

// The segmented control which controls the bool above.
@property (weak, nonatomic) IBOutlet UISegmentedControl *followLocationOnMapViewSegmentedControl;

// The IBAction triggered by the segmented control above when it's value changes.
- (IBAction)followLocationSegmentedControlValueChanged:(id)sender;

//***************************************
// Dashboard view properties and methods.
//***************************************

// The superview of the dashboard elements.
@property (weak, nonatomic) IBOutlet UIView *dashboardElementsView;

// An NSNumber to track the current metric index of the dashboard.
@property (weak, nonatomic) NSNumber *currentMetricIndex;

// The 4 main data labels and their metric labels.
@property (weak, nonatomic) IBOutlet UILabel *mainDataLabel;
@property (weak, nonatomic) IBOutlet UILabel *mainMetricLabel;
@property (weak, nonatomic) IBOutlet UILabel *dataLabelOne;
@property (weak, nonatomic) IBOutlet UILabel *metricLabelOne;
@property (weak, nonatomic) IBOutlet UILabel *dataLabelTwo;
@property (weak, nonatomic) IBOutlet UILabel *metricLabelTwo;
@property (weak, nonatomic) IBOutlet UILabel *dataLabelThree;
@property (weak, nonatomic) IBOutlet UILabel *metricLabelThree;
@property (weak, nonatomic) IBOutlet UILabel *dataLabelFour;
@property (weak, nonatomic) IBOutlet UILabel *metricLabelFour;

// The label which shows when the dashboard was most recently updated.
@property (weak, nonatomic) IBOutlet UILabel *dateUpdatedLabel;

// The action triggered when the previous button is pressed.
- (IBAction)previousMetricButtonPressed:(id)sender;

// The action triggered when the next button is pressed.
- (IBAction)nextMetricButtonPressed:(id)sender;

//*************************************
// Sharing view properties and methods.
//*************************************

// The superview of the sharing elements.
@property (weak, nonatomic) IBOutlet UIView *shareView;

// The action triggered when the facebook button is pressed.
- (IBAction)facebookButtonPressed:(id)sender;

// The action triggered when the twitter button is pressed.
- (IBAction)twitterButtonPressed:(id)sender;

// The action triggered when the email button is pressed.
- (IBAction)emailButtonPressed:(id)sender;

//********************************
// Toolbar properties and methods.
//********************************

// The UIBarButtonItems which allow the user to navigate between the map, sharing screen and dashboard as well as turn tracking on or off.
@property (weak, nonatomic) IBOutlet UIBarButtonItem *onButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *dashButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mapButton;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

// The action triggered when a tool bar button is pressed.
- (IBAction)toolbarButtonPressed:(id)sender;

//*********************************************
// Saving and uploading properties and methods.
//*********************************************

// The current track object.
@property (nonatomic, retain) HWKTrack *trackObject;

// The managed object context.
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

// The location manager.
@property (nonatomic, retain) CLLocationManager *locationManager;

//***********************************************************************
// The methods and properties associated with turning tracking on or off.
//***********************************************************************

// A bool to track whether to upload a new location.
@property BOOL isUploading;

// The action triggered when the on button is pressed. Of course this may be triggered when the button is showing "off". But there was no real clean way around this naming issue.
- (IBAction)onButtonPressed:(id)sender;

// The action triggered when the "+" button in the top right corner of the screen is pressed.
- (IBAction)newTrackButtonPressed:(id)sender;

// The method which turns off uploading.
-(void)turnOffUploading;

// The method which turns on uploading.
-(void)turnOnUploading;

//***********************************************
// The properties and methods associated with UI.
//***********************************************

// A progress HUD for showing the progress of processes during the creation of a new track.
@property (nonatomic,retain) MBProgressHUD *progressHUD;

// The method which draws a line on the map with a given array of waypoints.
-(void)drawLineOnMapWithWaypoints:(NSMutableArray *)_waypoints;

// The method which updates the dashboard.
-(void)updateDashboard;

// The method which shows an alert view telling the user they don't have an Internet connection.
-(void)showNoInternetConnectionAlertView;

@end
