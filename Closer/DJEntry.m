//
//  DJEntry.m
//  Closer
//
//  Created by Earl on 1/20/13.
//  Copyright (c) 2013 Earl. All rights reserved.
//

#import "DJEntry.h"


@implementation DJEntry

@dynamic dateCollected;
@dynamic maturityDate;
@dynamic name;
@dynamic points;
@dynamic projectName;

+ (DJEntry *) entryWithDefaultContext {

    return [NSEntityDescription insertNewObjectForEntityForName:@"Entry"
                                         inManagedObjectContext:[[NSApp delegate] managedObjectContext]];

    
}


@end
