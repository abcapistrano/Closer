//
//  OverviewController.m
//  Closer
//
//  Created by Earl on 1/19/13.
//  Copyright (c) 2013 Earl. All rights reserved.
//

#import "OverviewWindowController.h"
#import <WebKit/WebKit.h>
#import "GRMustache.h"
#import "DJAppDelegate.h"
#include "Constants.h"

NSString * const POINTS_CARRYOVER_KEY = @"carryOver";


@interface OverviewWindowController ()

@end

@implementation OverviewWindowController



- (id) init
{
    self = [super initWithWindowNibName:@"OverviewWindowController" owner:self];
    if (self) {
        // Initialization code here.




        
    }
    
    return self;
}



- (void)windowDidLoad
{
    [super windowDidLoad];
    [self refreshReport:self];


}







- (void)refreshReport:(id)sender {


    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Entry"];
//    request.predicate = [NSPredicate predicateWithFormat:@"dateCollected "]

    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"points" ascending:NO];
    request.sortDescriptors = @[sd];

    NSError *error;
    NSArray *entries = [[(DJAppDelegate *)[[NSApplication sharedApplication] delegate] managedObjectContext] executeFetchRequest:request error:&error];

    // Generate report


    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterShortStyle];
    [df setTimeStyle:NSDateFormatterShortStyle];


    NSInteger carryOver = [[NSUserDefaults standardUserDefaults] integerForKey:POINTS_CARRYOVER_KEY];
    NSInteger totalPoints = [[entries valueForKeyPath:@"@sum.points"] integerValue] + carryOver;


    NSDictionary *data = @{
    @"pointsCarryover" : @(carryOver),
    @"date": [df stringFromDate:[NSDate date]],
    @"totalPoints" : @(totalPoints),
    @"entries": entries,

    };

    NSString *result = [GRMustacheTemplate renderObject:data fromResource:@"Points Format" bundle:[NSBundle mainBundle] error:&error];
    if (!result) {
        
        
        NSLog(@"error: %@", [error localizedDescription]);
    } else {
        
        [[self.viewer mainFrame] loadHTMLString:result baseURL:nil];
        
    }
    
    
    
    
    
    



}


@end
