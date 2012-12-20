//
//  NSImage+PNG.m
//  Closer
//
//  Created by Earl on 12/20/12.
//  Copyright (c) 2012 Earl. All rights reserved.
//

#import "NSImage+PNG.h"

@implementation NSImage (PNG)
- (void) saveAsPNGToURL:(NSURL*) fileURL {
    
    // Cache the reduced image
    NSData *imageData = [self TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
    imageData = [imageRep representationUsingType:NSPNGFileType properties:imageProps];
    [imageData writeToURL:fileURL atomically:NO];
    //[imageData writeToFile:fileName atomically:NO];
    
    
    
}
@end
