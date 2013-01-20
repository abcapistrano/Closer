//
//  OverviewController.h
//  Closer
//
//  Created by Earl on 1/19/13.
//  Copyright (c) 2013 Earl. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class WebView;

@interface OverviewWindowController : NSWindowController
@property (assign) IBOutlet WebView *viewer;
- (IBAction) refreshReport :(id)sender;
- (IBAction) postReport:(id)sender;
@end
