//
//  NSString+GenericString.m
//  DemonJelly
//
//  Created by Earl on 12/11/09.
//  Copyright 2009 DemonJelly. All rights reserved.
//

#import "NSString+GenericString.h"

@implementation NSString (GenericString)
- (NSString *) find:(NSString *)find replaceWith:(NSString *)replace {
    return [self stringByReplacingOccurrencesOfString:find withString:(NSString *)replace];
}

- (NSString *) quotedString {
    return [NSString stringWithFormat:@"\"%@\"", self];
}

- (BOOL) containsSubstring: (NSString *) substring {
    
    if ([self rangeOfString:substring].location != NSNotFound) {
        return YES;
    } else {
        return NO;
    }
}

@end
