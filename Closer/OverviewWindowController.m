//
//  OverviewController.m
//  Closer
//
//  Created by Earl on 1/19/13.
//  Copyright (c) 2013 Earl. All rights reserved.
//

#import "OverviewWindowController.h"
#import <ScriptingBridge/ScriptingBridge.h>
#import <WebKit/WebKit.h>
#import "Things.h"
#import "GRMustache.h"
#import "DJTodo.h"
NSString * const LAST_CLOSE_DATE_KEY = @"lastCloseDate";
NSString * const POINTS_CARRYOVER_KEY = @"carryOver";


@interface OverviewWindowController ()

@end

@implementation OverviewWindowController



- (id) init
{
    self = [super initWithWindowNibName:@"OverviewWindowController" owner:self];
    if (self) {
        // Initialization code here.
        
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{
                                           LAST_CLOSE_DATE_KEY :  [NSDate dateWithNaturalLanguageString:@"December 20, 2012 12 am"],
                                          POINTS_CARRYOVER_KEY : @0}];


        self.things = [SBApplication applicationWithBundleIdentifier:@"com.culturedcode.Things"];

        
    }
    
    return self;
}



- (void)windowDidLoad
{
    [super windowDidLoad];

       

    
    [self refreshReport:self];


}



- (void)refreshReport:(id)sender {


    ThingsList *logbook = [self.things.lists objectWithName:@"Logbook"];
    SBElementArray *toDos = logbook.toDos;




    NSDate *lastCloseDate = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_CLOSE_DATE_KEY];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"completionDate > %@",  lastCloseDate];

    [toDos filterUsingPredicate:pred];



    NSArray *filteredTodos = [toDos get];

    // Iterate over the todos

    NSRegularExpression *exp = [[NSRegularExpression alloc] initWithPattern:@"[-+]?\\d+$" options:0
                                                                      error:NULL];


    NSInteger carryOver = [[NSUserDefaults standardUserDefaults] integerForKey:POINTS_CARRYOVER_KEY];
    __block NSInteger totalPoints = carryOver;

    NSMutableArray *toDosDisplayed = [NSMutableArray array];

  //  __block BOOL foundTheLatestAccountabilityReportBuilder = NO;

    [filteredTodos enumerateObjectsUsingBlock:^(ThingsToDo* toDo, NSUInteger idx, BOOL *stop) {

        if (toDo.status == ThingsStatusCompleted) {
            NSString *toDoName = toDo.name;

            NSTextCheckingResult *result = [exp firstMatchInString:toDoName options:0 range:NSMakeRange(0, [toDoName length])];

            if (result) {
                NSInteger points = [[toDoName substringWithRange:result.range] integerValue];

                DJTodo *aTodo = [DJTodo new];
                NSRange nameRange = NSMakeRange(0, result.range.location-1);
                aTodo.name =   [toDoName substringWithRange:nameRange];
                aTodo.points = points;
                aTodo.projectName = toDo.project.name;




                [toDosDisplayed addObject:aTodo];



                totalPoints = totalPoints + points;

            }

            // Find the latest copy of the "Accountability Report Builder" project in the logbook
            // What are we looking for:
            // It is a project
            // It has a name "Accountability Report Builder"
            // It is the latest

//TODO: REIMPLEMENT RULES REPORTING

            /*

            if (!foundTheLatestAccountabilityReportBuilder &&
                [toDoName isEqualToString:@"Accountability Report Builder"] &&
                [[toDo className] isEqualToString:@"ThingsProject"] ) {

                self.latestCompletedAccountabilityReportBuilder = (ThingsProject *)toDo;

                foundTheLatestAccountabilityReportBuilder = YES;
            }*/


        }









    }];


    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"points" ascending:NO];
    [toDosDisplayed sortUsingDescriptors:@[sd]];


    // Generate report


    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterShortStyle];
    [df setTimeStyle:NSDateFormatterShortStyle];

    NSDictionary *data = @{
    @"pointsCarryover" : @(carryOver),
    @"date": [df stringFromDate:[NSDate date]],
    @"totalPoints" : @(totalPoints),
    @"toDosDisplayed": toDosDisplayed,

    };

    NSError *error;
    NSString *result = [GRMustacheTemplate renderObject:data fromResource:@"Points Format" bundle:[NSBundle mainBundle] error:&error];
    if (!result) {
        
        
        NSLog(@"error: %@", [error localizedDescription]);
    } else {
        
        [[self.viewer mainFrame] loadHTMLString:result baseURL:nil];
        
    }
    
    
    
    
    
    
}


@end
