//
//  DJPostWindowController.h
//  Closer
//
//  Created by Earl on 1/25/13.
//  Copyright (c) 2013 Earl. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ACAccountStore;
@class ACAccount;
@class OverviewWindowController;
@interface DJPostWindowController : NSWindowController
@property (strong) ACAccountStore *accountStore;
@property (strong) ACAccount *facebookAccount;
@property (assign) BOOL permissionGranted;

@property (weak) OverviewWindowController *overviewWindowController;

- (IBAction)closeWindow:(id)sender;
- (IBAction)post:(id)sender;
- (void) showPostWindowSheetWithModalDelegate: (id) delegate;
@end
