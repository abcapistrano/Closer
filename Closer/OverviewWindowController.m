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

    [[ThingsDataController sharedDataController] processData];
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

- (void) postReport:(id)sender {


    void (^action) (void *, NSInteger) = ^(void *context, NSInteger returnCode){

            if (returnCode == NSOKButton) {

#ifdef RELEASE
                [self closeBooks]; //WARNING: CLOSING IS IRREVERSIBLE..
#endif

                [self screenshotPointsReport];

                NSSharingService *email = [NSSharingService sharingServiceNamed:NSSharingServiceNameComposeEmail];




                NSString *format = [NSString stringWithContentsOfURL:[
                                                                      [NSBundle mainBundle] URLForResource:@"PostFormat" withExtension:@"txt"]
                                                            encoding:NSUTF8StringEncoding
                                                               error:nil];
                [email performWithItems:@[format]];

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

- (void) screenshotPointsReport {

    WebFrameView *frameView = self.viewer.mainFrame.frameView;

    [frameView setAllowsScrolling:NO];

    NSView <WebDocumentView> *docView = frameView.documentView;

    NSData *imgData = [docView dataWithPDFInsideRect:docView.bounds];


    NSDateFormatter *df = [NSDateFormatter new];
    df.dateFormat = @"yyyy-MM-dd HHmm";

    NSString *name = [[df stringFromDate:[NSDate date]] stringByAppendingPathExtension:@"pdf"];

    //TODO: USE THE DROPBOX API DIRECTLY TO UPLOAD THE FILE


    NSURL *url = [NSURL fileURLWithPathComponents:@[@"/Users/earltagra/Dropbox/Goal Card/Points Log", name]];

    [imgData writeToURL:url atomically:NO];
    [frameView setAllowsScrolling:YES];


    //    [[NSUserDefaults standardUserDefaults] setObject:imgData forKey:POINTS_SCREENSHOT_DATA_KEY];
    
    
    
    
}


- (void) closeBooks {

    // set the prefs to the date of closing & carryover points

 //   [[NSUserDefaults standardUserDefaults] setObject:newClosingDate forKey:LAST_CLOSE_DATE_KEY];
 //   [[NSUserDefaults standardUserDefaults] setInteger:self.totalPoints forKey:POINTS_CARRYOVER_KEY];
//TODO: Save new objects from core data..
}




@end
