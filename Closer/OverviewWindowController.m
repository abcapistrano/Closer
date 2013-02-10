//
//  OverviewController.m
//  Closer
//
//  Created by Earl on 1/19/13.
//  Copyright (c) 2013 Earl. All rights reserved.
//

#import "OverviewWindowController.h"
#import "GRMustache.h"
#import "DJAppDelegate.h"
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
    [self.viewer setFrameLoadDelegate:self];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshReport:) name:@"Facebook Post" object:nil];

}

- (void)windowDidLoad
{
    [super windowDidLoad];


}



- (void)refreshReport:(id)sender {

 
    [[ThingsDataController sharedDataController] importToDos];
//    [[ThingsDataController sharedDataController] processData];



    Report *lastReport = [[NSApp delegate] lastReport];
    Report *currentReport = [[NSApp delegate] currentReport];

    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Entry"];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"maturityDate >%@ AND maturityDate < %@", lastReport.lastEntryDate, currentReport.closingDate];
    [request setPredicate:pred];

    NSArray *results = [[[NSApp delegate] managedObjectContext] executeFetchRequest:request error:nil];
    [currentReport addEntries:[NSSet setWithArray:results]];


    NSInteger carryOver = lastReport.totalPoints.integerValue;
    NSInteger daysDifference = [currentReport.closingDate daysSinceDate:lastReport.closingDate];
    NSInteger deductions = daysDifference * -10;     // deduct only if the time difference is at least a day

    currentReport.totalPoints = @(currentReport.subtotal + carryOver + deductions);
    currentReport.deductions = @(deductions);


    //TODO: UPDATE GR MUSTACHE TO REFER TO THE CURRENT REPORT OBJECT
    NSDictionary *data = @{
    @"pointsCarryover" : @(carryOver),
    @"pointsDeduction" : @(deductions),
    @"totalPoints" : currentReport.totalPoints,
    @"entries": results,

    };


    NSError *error;
    NSString *result = [GRMustacheTemplate renderObject:data fromResource:@"Points Format" bundle:[NSBundle mainBundle] error:&error];
    if (!result) {


        NSLog(@"error: %@", [error localizedDescription]);
    } else {

      
        [[self.viewer mainFrame]  loadHTMLString:result baseURL:nil];
   

        
    }

 

 
    
    
    
    
}



- (void) postReport:(id)sender {

    [self refreshReport:self];
    if (!self.postWindowController ) {
        self.postWindowController = [DJPostWindowController new];
    }

    [self.postWindowController showPostSheet:self.window];


    
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {

    WebFrameView *frameView = self.viewer.mainFrame.frameView;
    [frameView setAllowsScrolling:NO];
    NSView <WebDocumentView> *docView = frameView.documentView;
    NSData *imgData = [docView dataWithPDFInsideRect:docView.bounds];
    [frameView setAllowsScrolling:YES];

    NSImage *image = [[NSImage alloc] initWithData:imgData];


    [image lockFocus];

    NSBitmapImageRep* bitmapRep = [[NSBitmapImageRep alloc]
                                   initWithFocusedViewRect:NSMakeRect(0, 0, image.size.width, image.size.height)];

    [image unlockFocus];

    Report *currentReport = [[NSApp delegate] currentReport];

    currentReport.pointsReport = [bitmapRep representationUsingType:NSPNGFileType properties:nil];

};

- (void) dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self];

    
}





@end
