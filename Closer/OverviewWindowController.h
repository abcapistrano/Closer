//
//  OverviewController.h
//  Closer
//
//  Created by Earl on 1/19/13.
//  Copyright (c) 2013 Earl. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class ThingsApplication, ThingsProject;
@class WebView;

@interface OverviewWindowController : NSWindowController
@property (assign) IBOutlet WebView *viewer;
@property (strong) ThingsApplication *things;

@end
