//
//  DJEntry.m
//  Closer
//
//  Created by Earl on 1/19/13.
//  Copyright (c) 2013 Earl. All rights reserved.
//

#import "DJEntry.h"


@implementation DJEntry

@dynamic name;
@dynamic points;
@dynamic projectName;
@dynamic dateCollected;
@dynamic maturityDate;

+ (DJEntry *) entryWithDefaultContext {

    return [NSEntityDescription insertNewObjectForEntityForName:@"Entry"
                                         inManagedObjectContext:[[NSApp delegate] managedObjectContext]];

    
}



@end
