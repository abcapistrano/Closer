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
#import "DJEntry+AdditionalMethods.h"
#import "DJAppDelegate.h"
#include "Constants.h"
#import "MTRandom.h"
#import "NSString+GenericString.h"
#import "Report+AdditionalMethods.h"

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



        self.things = [SBApplication applicationWithBundleIdentifier:@"com.culturedcode.Things"];
        


    }
    
    return self;
}

// contains a single method for now. in the future may be expanded.
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

    Report *lastReport = [[NSApp delegate] lastReport];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"completionDate > %@",  lastReport.lastEntryDate];
    [toDos filterUsingPredicate:pred];
    NSArray *filteredTodos = [toDos get];

    // Iterate over the todos

    NSRegularExpression *exp = [[NSRegularExpression alloc] initWithPattern:@"^.+\\. ([-+]?\\d+)$" options:0
                                                                      error:NULL];


    MTRandom *randomizer = [[MTRandom alloc] init];

    


    [filteredTodos enumerateObjectsUsingBlock:^(ThingsToDo* toDo, NSUInteger idx, BOOL *stop) {

        if (toDo.status == ThingsStatusCompleted) {
            NSString *toDoName = toDo.name;

            NSTextCheckingResult *result = [exp firstMatchInString:toDoName options:0 range:NSMakeRange(0, [toDoName length])];

            if (result) {
                NSRange pointRange = [result rangeAtIndex:1];
                NSInteger rawPoints = [[toDoName substringWithRange:pointRange] integerValue];


                DJEntry *entry = [DJEntry entryWithDefaultContext];
                NSRange nameRange = NSMakeRange(0, pointRange.location-1);

                entry.name = [toDoName substringWithRange:nameRange];
                entry.points = @(rawPoints);
                entry.projectName = toDo.project.name;
                entry.completionDate = toDo.completionDate;


                
                // if the entry is a routine or school work..it matures immediately
                NSString *area = toDo.area.name;
                if (!area) area = toDo.project.area.name;
                


                if ([toDo.tagNames containsSubstring:@"routine"]) {

                    entry.maturityDate = toDo.completionDate;
                    entry.points = @(rawPoints);

                } else if ([area isEqualToString:@"School Work"]) {

                    //2x points for school work.


                    entry.maturityDate = toDo.completionDate;
                    entry.points =  @(2 * rawPoints);
                }

                else if (rawPoints < 0){

                    // we're dealing with timewasters here

                    entry.points = @(rawPoints);
                    entry.maturityDate = toDo.completionDate;


              
                } else {


                    // shuffle the maturity dates for other entries between 30 days from 90 days of the current date


                    NSDateComponents *dc = [[NSDateComponents alloc] init];

                    //get a random number from
                    NSInteger randomDay = [randomizer randomUInt32From:30 to:90];
                    [dc setDay:randomDay];
                    NSDate *maturityDate = [[NSCalendar currentCalendar] dateByAddingComponents:dc toDate:toDo.completionDate options:0];
                    
                    entry.maturityDate = maturityDate;
                    
                }
            }

                       
        }
         
    }];



}






@end
