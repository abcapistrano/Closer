//
//  ThingsDataController.h
//  Closer
//
//  Created by Earl on 1/19/13.
//  Copyright (c) 2013 Earl. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ThingsApplication, ThingsProject;

// Purpose of this class: convert data from Things.app to Core Data NSManagedObjects which other classes can use.

@interface ThingsDataController : NSObject
@property (strong) ThingsApplication *things;
@property (strong) NSMutableSet *addedEntries;
@property (strong) NSCache *cache;
@property (strong) id applicationQuitObserver;
@property (strong) id reportsPostedObserver;
+ (id)sharedDataController;
- (void) importToDos;
@end
