//
//  DJAppDelegate.h
//  Closer
//
//  Created by Earl on 12/12/12.
//  Copyright (c) 2012 Earl. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class OverviewWindowController;
@interface DJAppDelegate : NSObject <NSApplicationDelegate>
//TODO: UNCOMMENT THIS LINES!


/*
@property (assign) IBOutlet NSWindow *mainWindow;
@property (unsafe_unretained) IBOutlet NSWindow *messageEditorWindow;


@property (strong) NSString *pointsDisplay;
@property (strong) NSMutableAttributedString *report;

@property (assign) BOOL hasAffirmed;*/


@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@property OverviewWindowController *overview;

- (IBAction)saveAction:(id)sender;



/*
- (IBAction)makeReport:(id)sender;
- (IBAction)refreshReport:(id)sender;
- (IBAction)send:(id)sender;
- (IBAction)closeEditor:(id)sender;
- (IBAction)sendReport:(id)sender;*/

@end
