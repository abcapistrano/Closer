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
#import "ThingsDataController.h"
#import "NSApplication+ESSApplicationCategory.h"
#import "NSDate+MoreDates.h"
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

- (void) awakeFromNib {

    [self showWindow:self];

}

- (void)windowDidLoad
{
    [super windowDidLoad];

    [self refreshReport:self];


}



- (void)refreshReport:(id)sender {

    [[ThingsDataController sharedDataController] processData];


    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Entry"];

    NSDate *startDate = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_CLOSE_DATE_KEY];
    NSDate *endDate = [NSDate date];

    request.predicate = [NSPredicate predicateWithFormat:@"maturityDate > %@ AND maturityDate < %@", startDate, endDate ];

    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"points" ascending:NO];
    request.sortDescriptors = @[sd];

    NSError *error;
    NSArray *entries = [[(DJAppDelegate *)[[NSApplication sharedApplication] delegate] managedObjectContext] executeFetchRequest:request error:&error];

    // Generate report


    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterShortStyle];
    [df setTimeStyle:NSDateFormatterShortStyle];



    NSInteger carryOver = [[NSUserDefaults standardUserDefaults] integerForKey:POINTS_CARRYOVER_KEY];

    NSDate *lastDeductionDate =[[NSUserDefaults standardUserDefaults] objectForKey:LAST_DEDUCTION_DATE_KEY];



    NSInteger daysDifference = [endDate daysSinceDate:lastDeductionDate];
    self.deductions = daysDifference * -10;     // deduct only if the time difference is at least a day



    
    self.totalPoints = [[entries valueForKeyPath:@"@sum.points"] integerValue] + carryOver + self.deductions;


    NSDictionary *data = @{
    @"pointsCarryover" : @(carryOver),
    @"pointsDeduction" : @(self.deductions),
    @"date": [df stringFromDate:[NSDate date]],
    @"totalPoints" : @(self.totalPoints),
    @"entries": entries,

    };

    NSString *result = [GRMustacheTemplate renderObject:data fromResource:@"Points Format" bundle:[NSBundle mainBundle] error:&error];
    if (!result) {
        
        
        NSLog(@"error: %@", [error localizedDescription]);
    } else {
        
        [[self.viewer mainFrame] loadHTMLString:result baseURL:nil];
        
    }
    
    


}

- (void) postReport:(id)sender {

    void (^action) (void *, NSInteger) = ^(void *context, NSInteger returnCode){

            if (returnCode == NSOKButton) {

                [self refreshReport:self];

//#ifdef RELEASE
                [self closeBooks]; //WARNING: CLOSING IS IRREVERSIBLE..
//#endif


                NSSharingService *email = [NSSharingService sharingServiceNamed:NSSharingServiceNameComposeEmail];

                NSString *format = [NSString stringWithContentsOfURL:[
                                                                      [NSBundle mainBundle] URLForResource:@"PostFormat" withExtension:@"txt"]
                                                            encoding:NSUTF8StringEncoding
                                                               error:nil];
                [email performWithItems:@[format, self.pointsReport]];

                [self refreshReport:self];

            }
};

    

    ESSBeginAlertSheet(
                       @"Irreversible Action Warning",
                       @"Proceed",
                       @"Cancel",
                       nil,
                       self.window,
                       nil,
                       action,
                       nil,
                       @"Please check the Things.app for completed todos which remain unlogged before proceeding.");

    
}

- (NSImage *) pointsReport {

    WebFrameView *frameView = self.viewer.mainFrame.frameView;
    [frameView setAllowsScrolling:NO];
    NSView <WebDocumentView> *docView = frameView.documentView;
    NSData *imgData = [docView dataWithPDFInsideRect:docView.bounds];
    [frameView setAllowsScrolling:YES];


    
    return [[NSImage alloc] initWithData:imgData];
    
    
}


- (void) closeBooks {



    // set the prefs to the date of closing & carryover points
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:LAST_CLOSE_DATE_KEY];
    [[NSUserDefaults standardUserDefaults] setInteger:self.totalPoints forKey:POINTS_CARRYOVER_KEY];
    if (self.deductions < 0) {

        [[NSUserDefaults standardUserDefaults] setObject:[[NSDate date] dateAtDawn] forKey:LAST_DEDUCTION_DATE_KEY];



    }

    [[NSApp delegate] saveAction:self];



}




@end
