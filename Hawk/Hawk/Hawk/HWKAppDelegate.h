//
//  HWKAppDelegate.h
//  Hawk
//
//  Created by Lochie Ferrier on 8/09/12.
//  Copyright (c) 2012 Lochie Ferrier. All rights reserved.
//
//
// This program is submitted as part of the assessment for IT1001.
// This is all my own work. I have referenced any work used from
// other sources and have not plagiarised the work of others.
// (signed) Lochie Ferrier

#import <UIKit/UIKit.h>

#warning 161-calculator error!!! terminal! can't find!

@interface HWKAppDelegate : UIResponder <UIApplicationDelegate>

// The application's window.
@property (strong, nonatomic) UIWindow *window;

// The managed object context.
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

// The managed object model.
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;

// The persistent store coordinator.
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

// This method saves the context.
- (void)saveContext;

// The URL of the application's documents directory.
- (NSURL *)applicationDocumentsDirectory;


@end
