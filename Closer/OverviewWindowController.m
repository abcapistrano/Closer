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
#import "DJPostWindowController.h"
#import "Report+AdditionalMethods.h"


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


}



- (void)refreshReport:(id)sender {

    [[ThingsDataController sharedDataController] processData];


    Report *lastReport = [[NSApp delegate] lastReport];
    Report *currentReport = [[NSApp delegate] currentReport];

    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Entry"];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"maturityDate >%@ AND maturityDate < %@", lastReport.closingDate, currentReport.closingDate];
    [request setPredicate:pred];

    NSArray *results = [[[NSApp delegate] managedObjectContext] executeFetchRequest:request error:nil];
    [currentReport addEntries:[NSSet setWithArray:results]];


    NSInteger carryOver = lastReport.totalPoints.integerValue;
    NSInteger daysDifference = [currentReport.closingDate daysSinceDate:lastReport.closingDate];
    NSInteger deductions = daysDifference * -10;     // deduct only if the time difference is at least a day

    currentReport.totalPoints = @(currentReport.subtotal + carryOver + deductions);
    currentReport.deductions = @(deductions);

    // Save screenshot;

    WebFrameView *frameView = self.viewer.mainFrame.frameView;
    [frameView setAllowsScrolling:NO];
    NSView <WebDocumentView> *docView = frameView.documentView;
    NSData *imgData = [docView dataWithPDFInsideRect:docView.bounds];
    [frameView setAllowsScrolling:YES];

    NSImage *image = [[NSImage alloc] initWithData:imgData];


    [image lockFocus];

    NSBitmapImageRep* bitmapRep = [[NSBitmapImageRep alloc]
                                   initWithFocusedViewRect:NSMakeRect(0, 0, image.size.width, image.size.height)]
    ;

    [image unlockFocus];
    currentReport.pointsReport = [bitmapRep representationUsingType:NSPNGFileType properties:nil];

    //TODO: CHANGE DATE STyLE

    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterShortStyle];
    [df setTimeStyle:NSDateFormatterShortStyle];



    //TODO: UPDATE GR MUSTACHE TO REFER TO THE CURRENT REPORT OBJECT
    NSDictionary *data = @{
    @"pointsCarryover" : @(carryOver),
    @"pointsDeduction" : @(deductions),
    @"date": [df stringFromDate:[NSDate date]],
    @"totalPoints" : currentReport.totalPoints,
    @"entries": currentReport.entries.allObjects,

    };


    NSError *error;
    NSString *result = [GRMustacheTemplate renderObject:data fromResource:@"Points Format" bundle:[NSBundle mainBundle] error:&error];
    if (!result) {


        NSLog(@"error: %@", [error localizedDescription]);
    } else {

        [[self.viewer mainFrame] loadHTMLString:result baseURL:nil];
        
    }
    
    
    
    
}



- (void) postReport:(id)sender {

    [self refreshReport:self];
    if (!self.postWindowController ) {
        self.postWindowController = [DJPostWindowController new];
    }
    [self.postWindowController showPostWindowSheetWithModalDelegate:self];





//    
//
//    void (^action) (void *, NSInteger) = ^(void *context, NSInteger returnCode){
//
//            if (returnCode == NSOKButton) {
//
//                [self refreshReport:self];
//
////#ifdef RELEASE
//                [self closeBooks]; //WARNING: CLOSING IS IRREVERSIBLE..
////#endif
//
//
//                NSSharingService *email = [NSSharingService sharingServiceNamed:NSSharingServiceNameComposeEmail];
//
//                NSString *format = [NSString stringWithContentsOfURL:[
//                                                                      [NSBundle mainBundle] URLForResource:@"PostFormat" withExtension:@"txt"]
//                                                            encoding:NSUTF8StringEncoding
//                                                               error:nil];
//                [email performWithItems:@[format, self.pointsReport]];
//
//                [self refreshReport:self];
//
//            }
//};
//
//    
//
//    ESSBeginAlertSheet(
//                       @"Irreversible Action Warning",
//                       @"Proceed",
//                       @"Cancel",
//                       nil,
//                       self.window,
//                       nil,
//                       action,
//                       nil,
//                       @"Please check the Things.app for completed todos which remain unlogged before proceeding.");

    
}



- (void) closeBooks {


    //be sure to refresh!
    [[NSApp delegate] saveAction:self];



}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void * )contextInfo {

    NSLog(@"sheet ends");
}


@end
