//
//  NSApplication+SheetsAndBlocks.h
//  Closer
//
//  Created by Earl on 12/30/12.
//  Copyright (c) 2012 Earl. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSApplication (SheetsAndBlocks)
- (void)beginSheet:(NSWindow *)sheet
    modalForWindow:(NSWindow *)docWindow
       didEndBlock:(void (^)(NSInteger returnCode))block;
- (void)my_blockSheetDidEnd:(NSWindow *)sheet
                 returnCode:(NSInteger)returnCode
                contextInfo:(void *)contextInfo;

void ESSBeginAlertSheet(NSString *title,
						NSString *defaultButton,
						NSString *alternateButton,
						NSString *otherButton,
						NSWindow *window,
						void (^didEndBlock)(void *contextInf,
											NSInteger returnCode),
						void (^didDismissBlock)(void *contextInf,
												NSInteger returnCode),
						void *contextInfo,
						NSString *formattedString);

void ESSBeginInformationalAlertSheet(NSString *title,
									 NSString *defaultButton,
									 NSString *alternateButton,
									 NSString *otherButton,
									 NSWindow *window,
									 void (^didEndBlock)(void *contextInf,
														 NSInteger returnCode),
									 void (^didDismissBlock)(void *contextInf,
															 NSInteger returnCode),
									 void *contextInfo,
									 NSString *formattedString);

void ESSBeginCriticalAlertSheet(NSString *title,
								NSString *defaultButton,
								NSString *alternateButton,
								NSString *otherButton,
								NSWindow *window,
								void (^didEndBlock)(void *contextInf,
													NSInteger returnCode),
								void (^didDismissBlock)(void *contextInf,
														NSInteger returnCode),
								void *contextInfo,
								NSString *formattedString);

@end
