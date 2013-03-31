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
#import "MTRandom.h"
#import "NSString+GenericString.h"
#import "Report+AdditionalMethods.h"
#import "NSDate+MoreDates.h"
#import <YACYAML/YACYAML.h>
#import "NSArray+ConvenienceMethods.h"



NSString * const ADDED_ENTRIES_KEY = @"addedEntries";


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
        self.cache = [NSCache new];
        self.cache.name = @"Cache";

        void (^makePrizes)(NSNotification *) = ^(NSNotification *note) {

            

            Report *report = [note object];

            ThingsArea *prizesArea = [self.things.areas objectWithName:@"Prizes"];


            NSPredicate *pred = [NSPredicate predicateWithFormat:@"status == %@", [NSAppleEventDescriptor descriptorWithEnumCode:ThingsStatusOpen]];

            NSUInteger existingPrizesCount = [[prizesArea.toDos filteredArrayUsingPredicate:pred] count];
            NSUInteger maxPrizesCount = 10;
            if (existingPrizesCount > maxPrizesCount) {
                return; // don't make prizes if there is more than 10
            }

            NSUInteger prizeCost = 3; //1 prize for every three points
            NSUInteger numberOfPrizesToMake = MIN(maxPrizesCount - existingPrizesCount, report.totalPoints.integerValue/prizeCost);

            

            //check if goal card has a prize
            NSURL* prizesURL = [NSURL fileURLWithPath:@"/Users/earltagra/Dropbox/Goal Card/Prizes.yaml"];

            if (![prizesURL checkResourceIsReachableAndReturnError:nil]) {

                prizesURL = [[NSBundle mainBundle] URLForResource:@"Prizes" withExtension:@"yaml"];

            }

            
            NSArray *availablePrizes = [YACYAMLKeyedUnarchiver unarchiveObjectWithFile:[prizesURL path]];
            NSMutableArray *prizesWithBias = [NSMutableArray array];

            [availablePrizes enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(NSDictionary* prize, NSUInteger idx, BOOL *stop) {

                NSString *bias = prize[@"bias"];
                NSUInteger iteration = 0;
                
                if ([bias isEqualToString:@"high"]) {

                    iteration = 3;


                } else if ([bias isEqualToString:@"normal"]) {

                    iteration = 2;

                } else if ([bias isEqualToString:@"low"]) {

                    iteration = 1;

                    
                }

                dispatch_apply(iteration, dispatch_get_current_queue(), ^(size_t BLAh) {

                    
                    [prizesWithBias addObject:prize];

                });

            }];


            Class todoClass = [self.things classForScriptingClass:@"to do"];
            SBElementArray *toDos = prizesArea.toDos;            


            for (NSInteger i = 0; i < numberOfPrizesToMake; i++) {

                ThingsToDo *toDo = [todoClass new];
                [toDos addObject:toDo];


                NSDictionary *prize = [[prizesWithBias sample:1] lastObject];

                toDo.name = prize[@"activityName"];
                toDo.tagNames = prize[@"tag"];
                
                toDo.dueDate = [[[NSDate date] dateByOffsettingDays:30] dateJustBeforeMidnight]; //prizes expire in 30 days.
                
                


            };

            // add the prize deduction

            if (numberOfPrizesToMake > 0) {


                ThingsList *logbook = [self.things.lists objectWithName:@"Logbook"];
                SBElementArray *loggedToDos = logbook.toDos;


                ThingsToDo *toDo = [todoClass new];
                [loggedToDos addObject:toDo];

                NSUInteger pointsUsed = prizeCost * numberOfPrizesToMake;
                toDo.name = [NSString stringWithFormat:@"Prize. -%lu", pointsUsed];

                
            }



        };

        self.reportsPostedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"Report Posted"
                                                                                       object:nil
                                                                                        queue:[NSOperationQueue mainQueue]
                                                                                   usingBlock:makePrizes];


        

    }

    
    return self;
}


- (void) discardEntries {

    NSMutableSet *entriesAdded = [self.cache objectForKey:ADDED_ENTRIES_KEY];
    NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];

    [entriesAdded enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [moc deleteObject:obj];
    }];


    [self.cache removeAllObjects];

}


- (void) importToDos {
    [self discardEntries];
    NSMutableSet *addedEntries = [NSMutableSet set];


    ThingsList *logbook = [self.things.lists objectWithName:@"Logbook"];
    SBElementArray *toDos = logbook.toDos;

    Report *lastReport = [[NSApp delegate] lastReport];
    NSPredicate *completionDatePredicate = [NSPredicate predicateWithFormat:@"completionDate > %@",  lastReport.lastEntryDate];
    [toDos filterUsingPredicate:completionDatePredicate];
    NSArray *filteredTodos = [[toDos get] mutableCopy];

    // Iterate over the todos

    NSRegularExpression *exp = [[NSRegularExpression alloc] initWithPattern:@"^.+\\. ([-+]?\\d+)$" options:0
                                                                      error:NULL];

    MTRandom *randomizer = [[MTRandom alloc] init];

    void (^inspectToDos)(ThingsToDo *, NSUInteger, BOOL *) = ^(ThingsToDo* toDo, NSUInteger idx, BOOL *stop) {

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


                //bonuses and routines are realized immediately
                if ([toDo.tagNames containsSubstring:@"routine"] || [toDo.tagNames containsSubstring:@"bonus"]) {

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
                
                
                [addedEntries addObject:entry];



                
                
            }
            
            
        }
        
    };

    [filteredTodos enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:inspectToDos];
    
    // if the entry is a project we should inspect the todos inside
    NSMutableArray *todosHidingInsideProjects = [NSMutableArray array];

    NSArray *completedProjects = [self.things.projects filteredArrayUsingPredicate:completionDatePredicate];
    [completedProjects enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(ThingsProject* project, NSUInteger idx, BOOL *stop) {
        SBElementArray *todos = [project toDos];
        [todos filterUsingPredicate:completionDatePredicate];
        NSArray *local = [todos get];
        [todosHidingInsideProjects addObjectsFromArray:local];
      //  NSLog(@"%@",project.name);

    }];
    [todosHidingInsideProjects enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:inspectToDos];

    [self.cache setObject:addedEntries forKey:ADDED_ENTRIES_KEY];

}

- (void) dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self.applicationQuitObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self.reportsPostedObserver];
}



@end
