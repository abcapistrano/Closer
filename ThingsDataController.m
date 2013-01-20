//
//  ThingsDataController.m
//  Closer
//
//  Created by Earl on 1/19/13.
//  Copyright (c) 2013 Earl. All rights reserved.
//

#import "ThingsDataController.h"
#import <ScriptingBridge/ScriptingBridge.h>
#import "Things.h"
#import "DJEntry.h"
#import "DJAppDelegate.h"
#include "Constants.h"
#import "MTRandom.h"
#import "NSString+GenericString.h"
NSString * const LAST_CLOSE_DATE_KEY = @"lastCloseDate";
@implementation ThingsDataController


+ (id)sharedDataController
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });


    
    return sharedInstance;
}



- (id) init
{
    self = [super init];
    if (self) {
        // Initialization code here.


        [[NSUserDefaults standardUserDefaults] registerDefaults:@{
                                           LAST_CLOSE_DATE_KEY :  [NSDate dateWithNaturalLanguageString:@"December 20, 2012 12 am"],
                                          POINTS_CARRYOVER_KEY : @0}];

        self.things = [SBApplication applicationWithBundleIdentifier:@"com.culturedcode.Things"];
        


    }
    
    return self;
}


- (void) processData {

    [self processLoggedToDos];
    
}


/*

processLoggedToDos:
Goes over each todo/project in the logbook which has points so that the corresponding NSManagedObject is created without saving the managedobject context.
 
*/

- (void) processLoggedToDos {

    [[[NSApp delegate] managedObjectContext] rollback];

    ThingsList *logbook = [self.things.lists objectWithName:@"Logbook"];
    SBElementArray *toDos = logbook.toDos;

    NSDate *lastCloseDate = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_CLOSE_DATE_KEY];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"completionDate > %@",  lastCloseDate];

    [toDos filterUsingPredicate:pred];
    NSArray *filteredTodos = [toDos get];

    // Iterate over the todos

    NSRegularExpression *exp = [[NSRegularExpression alloc] initWithPattern:@"[-+]?\\d+$" options:0
                                                                      error:NULL];


    MTRandom *randomizer = [[MTRandom alloc] init];
    
    [filteredTodos enumerateObjectsUsingBlock:^(ThingsToDo* toDo, NSUInteger idx, BOOL *stop) {

        if (toDo.status == ThingsStatusCompleted) {
            NSString *toDoName = toDo.name;

            NSTextCheckingResult *result = [exp firstMatchInString:toDoName options:0 range:NSMakeRange(0, [toDoName length])];

            if (result) {
                NSInteger rawPoints = [[toDoName substringWithRange:result.range] integerValue];


                DJEntry *entry = [DJEntry entryWithDefaultContext];
                
                NSRange nameRange = NSMakeRange(0, result.range.location-1);

                entry.name = [toDoName substringWithRange:nameRange];
                entry.points = @(rawPoints);
                entry.projectName = toDo.project.name;
                entry.dateCollected = [NSDate date];

                // if the entry is a routine or law school reading...it matures immediately

                if ([toDo.tagNames containsSubstring:@"routine"]) {

                    entry.maturityDate = [NSDate date];
                    entry.points = @(rawPoints);

                } else if ([toDo.area.name isEqualToString:@"Law Readings"]) {

                    //2x points for law readings


                    entry.maturityDate = [NSDate date];
                    entry.points =  @(2 * rawPoints);
                }

                else {

                // shuffle the maturity dates for other entries between 30 days from 90 days of the current date

                    NSDateComponents *dc = [[NSDateComponents alloc] init];

                    //get a random number from 
                    NSInteger randomDay = [randomizer randomUInt32From:30 to:90];
                    [dc setDay:randomDay];
                    NSDate *maturityDate = [[NSCalendar currentCalendar] dateByAddingComponents:dc toDate:[NSDate date] options:0];

                    entry.maturityDate = maturityDate;
                }
            }

                       
        }
         
    }];



}






@end
