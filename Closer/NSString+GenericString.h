//
//  NSString+GenericString.h
//  DemonJelly
//
//  Created by Earl on 12/11/09.
//  Copyright 2009 DemonJelly. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSString (GenericString)
- (NSString *) find:(NSString *)find replaceWith:(NSString *)replace;
- (NSString *) quotedString;
- (BOOL) containsSubstring: (NSString *) substring;

@end
