//
//  DJAppDelegate.h
//  Closer
//
//  Created by Earl on 12/12/12.
//  Copyright (c) 2012 Earl. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ThingsApplication;
@class WebView;
@interface DJAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet WebView *viewer;
@property (strong) ThingsApplication *things;
@property (strong) NSString *pointsDisplay;
@property (strong) NSMutableAttributedString *report;
- (IBAction)computePoints:(id)sender;
@end
