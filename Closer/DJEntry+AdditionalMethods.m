//
//  DJEntry+AdditionalMethods.m
//  Closer
//
//  Created by Earl on 1/26/13.
//  Copyright (c) 2013 Earl. All rights reserved.
//

#import "DJEntry+AdditionalMethods.h"

@implementation DJEntry (AdditionalMethods)
+ (DJEntry *) entryWithDefaultContext {

    return [NSEntityDescription insertNewObjectForEntityForName:@"Entry"
                                         inManagedObjectContext:[[NSApp delegate] managedObjectContext]];

    
}



@end
