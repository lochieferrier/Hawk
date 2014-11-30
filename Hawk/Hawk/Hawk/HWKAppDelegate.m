//
//  HWKAppDelegate.m
//  Hawk
//
//  Created by Lochie Ferrier on 8/09/12.
//  Copyright (c) 2012 Lochie Ferrier. All rights reserved.
//

#import "HWKAppDelegate.h"

@implementation HWKAppDelegate
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Set the Parse applicationID and clientKey.
    
    [Parse setApplicationId:@"CLASSIFIED" clientKey:@"CLASSIFIED"];
    
    // This loop checks whether the device has been assigned an ID yet and if not, will continue to create random alphanumeric strings until it finds a unique ID. It then saves that ID to the NSUserDefaults.
    
    while ([[NSUserDefaults standardUserDefaults]
             stringForKey:@"deviceID"] == nil){
        
        // Create an NSString with all the letters and numbers
        
        NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        
        // Set the length of the random string
        
        int length = 10;
        
        // Create a mutable string to store the result of the random string creation
        
        NSMutableString *randomString = [NSMutableString stringWithCapacity: length];
        
        // This loop will add characters to the randomString until it reaches length
        
        for (int i=0; i<length; i++) {
            
            [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
            
        }
        
        // Create a PFQuery to download all the Track objects
        
        PFQuery *query = [PFQuery queryWithClassName:@"Track"];
        [query setClassName:@"Track"];
        
        // Create an NSArray to store the downloaded objects and download the objects. The objects are not downloaded in the background because at this point in the application's execution it is still displaying a launch screen. Therefore there is no point downloading in the background.
        
        NSArray *objects = [query findObjects];
        
        // Create a BOOL to detect whether there is a match with an existing deviceID
        
        BOOL triggered = NO;
        
        // This loop goes through all the PFObjects in the array and checks that none of them match the randomString
        
        for (PFObject *trackObject in objects){
            
            if([[trackObject objectForKey:@"deviceID"]isEqualToString:randomString]){
                
                NSLog(@"%@",trackObject);
                triggered = YES;
                
            }
            
        }
        
        // If the randomString has not already been used, set the deviceID in the NSUserDefaults
        if(triggered == NO){
            
            [[NSUserDefaults standardUserDefaults]
             setValue:randomString forKey:@"deviceID"];
            NSLog(@"device id generated");
            
        }
        
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    

    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"HawkCoreDataModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    

    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"HawkCoreDataModel.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
