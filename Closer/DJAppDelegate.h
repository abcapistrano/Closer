//
//  DJAppDelegate.h
//  Closer
//
//  Created by Earl on 12/12/12.
//  Copyright (c) 2012 Earl. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class ThingsApplication, ThingsProject;
@class WebView;
@interface DJAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *mainWindow;
@property (assign) IBOutlet WebView *viewer;
@property (unsafe_unretained) IBOutlet NSWindow *messageEditorWindow;


@property (strong) ThingsApplication *things;
@property (strong) NSString *pointsDisplay;
@property (strong) NSMutableAttributedString *report;
@property (assign) NSInteger totalPoints;

//@property (strong) ThingsProject *latestCompletedAccountabilityReportBuilder;
@property (strong) NSDate *lastCloseDate;

@property (assign) BOOL hasAffirmed;
- (IBAction)makeReport:(id)sender;
- (IBAction)refreshReport:(id)sender;
- (IBAction)send:(id)sender;
- (IBAction)closeEditor:(id)sender;
- (IBAction)sendReport:(id)sender;

@end
