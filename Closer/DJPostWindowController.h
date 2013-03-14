//
//  DJPostWindowController.h
//  Closer
//
//  Created by Earl on 1/25/13.
//  Copyright (c) 2013 Earl. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@class ACAccountStore;
@class ACAccount;
@class Report;
@interface DJPostWindowController : NSWindowController <QLPreviewPanelDataSource, QLPreviewPanelDelegate>
@property (strong) ACAccountStore *accountStore;
@property (strong) ACAccount *facebookAccount;
@property (assign) BOOL postingAllowed;
@property (strong) NSURL *reportTextFile;
@property (strong) QLPreviewPanel* panel;
@property (strong) NSArray *quicklookItems;

- (IBAction)closeWindow:(id)sender;
- (IBAction)post:(id)sender;
- (void) showPostSheet: (NSWindow *) parentWindow;

@end
