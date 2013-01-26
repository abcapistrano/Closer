//
//  DJAppDelegate.h
//  Closer
//
//  Created by Earl on 12/12/12.
//  Copyright (c) 2012 Earl. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class OverviewWindowController;
@class ThingsDataController;
@class Report;

@interface DJAppDelegate : NSObject <NSApplicationDelegate>



@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (assign) IBOutlet OverviewWindowController *overviewWindowController;


@property (readonly, strong, nonatomic) Report *lastReport;
@property (readonly, strong, nonatomic) Report *currentReport;




- (IBAction)saveAction:(id)sender;

@end
