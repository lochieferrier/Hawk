//
//  HWKViewerViewController.h
//  Hawk
//
//  Created by Lochie Ferrier on 18/09/12.
//  Copyright (c) 2012 Lochie Ferrier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HWKTrackManagedObject.h"
#import "HWKWaypointManagedObject.h"
#import "HWKWaypoint.h"
#import "HWKTrack.h"
#import "HWKAppDelegate.h"
#import "HWKMapAnnotation.h"
#import "HWKMapAnnotationView.h"
#import "MBProgressHUD.h"
#import <QuartzCore/QuartzCore.h>
@interface HWKViewerViewController : UIViewController < UIAlertViewDelegate, MKMapViewDelegate, MBProgressHUDDelegate >

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

// The method used to update the dashboard.
-(void)updateDashboard;

//************************
// Map related properties.
//************************

// The superview for the map elements.
@property (weak, nonatomic) IBOutlet UIView *mapElementsView;

// The map view.
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

//****************************************
// Toolbar related properties and methods.
//****************************************

// The dashboard button.
@property (weak, nonatomic) IBOutlet UIBarButtonItem *dashButton;

// The map button.
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mapButton;

// The action triggered when a toolbar button is pressed.
- (IBAction)toolBarButtonPressed:(id)sender;

//*******************
// Saving properties.
//*******************

// The current track object.
@property (weak, nonatomic) HWKTrack *trackObject;

// The track object array.
@property (nonatomic,retain) NSMutableArray *trackObjectsArray;

// The managed object context.
@property (nonatomic,retain) NSManagedObjectContext *managedObjectContext;

//**********************
// Transitioning action.
//**********************

// This action is fired when the user touches the tracker button.
- (IBAction)trackerButtonPressed:(id)sender;

//*****************
// Creation action.
//*****************

// This action is fired when the add button is pressed.
- (IBAction)addButtonPressed:(id)sender;

@end
