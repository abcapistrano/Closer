//
//  NSImage+PNG.h
//  Closer
//
//  Created by Earl on 12/20/12.
//  Copyright (c) 2012 Earl. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (PNG)
- (void) saveAsPNGToURL:(NSURL*) fileURL;

@end
