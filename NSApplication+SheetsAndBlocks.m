//
//  NSApplication+SheetsAndBlocks.m
//  Closer
//
//  Created by Earl on 12/30/12.
//  Copyright (c) 2012 Earl. All rights reserved.
//

#import "NSApplication+SheetsAndBlocks.h"

@implementation NSApplication (SheetsAndBlocks)

- (void)beginSheet:(NSWindow *)sheet
    modalForWindow:(NSWindow *)docWindow
       didEndBlock:(void (^)(NSInteger returnCode))block
{
    [self beginSheet:sheet
      modalForWindow:docWindow
       modalDelegate:self
      didEndSelector:@selector(my_blockSheetDidEnd:returnCode:contextInfo:)
         contextInfo:Block_copy((__bridge void *)block)];
}


- (void)my_blockSheetDidEnd:(NSWindow *)sheet
                 returnCode:(NSInteger)returnCode
                contextInfo:(void *)contextInfo
{
    void (^block)(NSInteger) = (__bridge_transfer id)contextInfo;
    block(returnCode);
}

@end
