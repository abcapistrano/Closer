//
//  DJPostWindowController.m
//  Closer
//
//  Created by Earl on 1/25/13.
//  Copyright (c) 2013 Earl. All rights reserved.
//

#import "DJPostWindowController.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "Report+AdditionalMethods.h"
#import "DJAppDelegate.h"
#import "NSDate+MoreDates.h"
#import "QLPreviewPanel+Secret.h"
NSString * const API_KEY = @"412976472118083";

@interface DJPostWindowController ()

@end

@implementation DJPostWindowController

- (id)init {
    self = [super initWithWindowNibName:@"PostWindow"];
    return self;
}

- (void) showPostSheet: (NSWindow *) parentWindow  {
    
    [NSApp beginSheet:self.window
       modalForWindow:parentWindow
        modalDelegate:self
       didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
          contextInfo:nil];

 

    NSString *temporaryDirectory = NSTemporaryDirectory();
    NSString *name = [[[NSDate date] dateStringWithFormat:@"EEE, yyyy-MMM-dd"] stringByAppendingPathExtension:@"md"];
    self.reportTextFile = [NSURL fileURLWithPathComponents:@[temporaryDirectory, name ]];


    NSString *rulesPath = @"/Users/earltagra/Library/Mobile Documents/74ZAFF46HB~jp~informationarchitects~Writer/Documents/Rules/";
    NSURL *rulesURL = [NSURL fileURLWithPath:rulesPath];

    NSMutableArray *itemsToShow = [NSMutableArray array];

    NSFileManager *fm = [NSFileManager defaultManager];

    [[fm contentsOfDirectoryAtURL:rulesURL includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:nil] enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(NSURL *rule, NSUInteger idx, BOOL *stop) {


        [itemsToShow addObject:rule];



    }];


    NSURL *template =[[NSBundle mainBundle] URLForResource:@"PostTemplate" withExtension:@"md"];
    [[NSFileManager defaultManager] copyItemAtURL:template toURL:self.reportTextFile error:nil];

    [itemsToShow addObject:self.reportTextFile];

    self.quicklookItems = itemsToShow;

    self.panel = [QLPreviewPanel sharedPreviewPanel];
    self.panel.dataSource = self;
    self.panel.delegate = self;


    [self.panel updateController];
    [self.panel setAutostarts:NO];


    [self.panel makeKeyAndOrderFront:self];
    [self.panel enterFullScreenMode:[NSScreen mainScreen] withOptions:nil];
  //  [[NSWorkspace sharedWorkspace] openURL:self.reportTextFile];


    [self askForPermissions];

}



- (NSInteger)numberOfPreviewItemsInPreviewPanel:(QLPreviewPanel *)panel {


    return self.quicklookItems.count;

}


- (id <QLPreviewItem>)previewPanel:(QLPreviewPanel *)panel previewItemAtIndex:(NSInteger)index {


    return self.quicklookItems[index];

}


- (BOOL) acceptsPreviewPanelControl: (QLPreviewPanel *) p {

    return YES;
}

- (void) beginPreviewPanelControl:(QLPreviewPanel *)panel {



}

- (void) endPreviewPanelControl:(QLPreviewPanel *)panel {

    [NSApp terminate:self];


    
}

- (void) askForPermissions {

    self.accountStore = [[ACAccountStore alloc] init];
    ACAccountType * facebookAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    self.facebookAccount = [[self.accountStore accountsWithAccountType:facebookAccountType] lastObject];




    // At first, we only ask for the basic read permission
    NSArray * permissions = @[@"user_groups"];

    NSMutableDictionary * dict = [@{

                                  ACFacebookAppIdKey : API_KEY,
                                  ACFacebookPermissionsKey : permissions,
                                  ACFacebookAudienceKey : ACFacebookAudienceOnlyMe} mutableCopy];

    [self.accountStore requestAccessToAccountsWithType:facebookAccountType options:dict completion:^(BOOL granted, NSError *error) {
        if (granted && error == nil) {
            /**
             * The user granted us the basic read permission.
             * Now we can ask for more permissions
             **/
            NSArray *readPermissions = @[@"publish_stream", @"publish_actions"];
            [dict setObject:readPermissions forKey: ACFacebookPermissionsKey];

            [self.accountStore requestAccessToAccountsWithType:facebookAccountType options:dict completion:^(BOOL granted, NSError *error) {
                if(granted && error == nil) {
                    self.postingAllowed = YES;
                }  else {

                    NSAlert *a = [NSAlert alertWithError:error];
                    [a beginSheetModalForWindow:self.window
                                  modalDelegate:nil
                                 didEndSelector:NULL
                                    contextInfo:nil];

                    NSLog(@"error is: %@",[error description]);
                }
                
                
            }];
            
            
            
            
            
        } else {
            NSAlert *a = [NSAlert alertWithError:error];
            [a beginSheetModalForWindow:self.window
                          modalDelegate:nil
                         didEndSelector:NULL
                            contextInfo:nil];


        }
    }];


}




- (IBAction)closeWindow:(id)sender {

    [NSApp endSheet:self.window];
    [self.window orderOut:self];


}
- (IBAction)post:(id)sender; {

    //PHOTO UPLOADING IS DISABLED

    NSString *message = [NSString stringWithContentsOfURL:self.reportTextFile
                                                 encoding:NSUTF8StringEncoding
                                                    error:nil];
    Report *report = [[NSApp delegate] currentReport];
    report.message = message;
    [[NSFileManager defaultManager] trashItemAtURL:self.reportTextFile resultingItemURL:nil error:nil];


    NSDictionary *parameters = @{@"message": report.message};
//    NSURL *feedURL = [NSURL URLWithString:@"https://graph.facebook.com/302868049811330/photos"];

    NSURL *feedURL = [NSURL URLWithString:@"https://graph.facebook.com/302868049811330/feed"];
    SLRequest *feedRequest = [SLRequest
                              requestForServiceType:SLServiceTypeFacebook
                              requestMethod:SLRequestMethodPOST
                              URL:feedURL
                              parameters:parameters];
    feedRequest.account = self.facebookAccount;

//    NSString *fileName = [[[NSUUID UUID] UUIDString] stringByAppendingPathExtension:@"png"];


    
//
//    
//    [feedRequest addMultipartData: report.pointsReport
//                         withName:@"source"
//                             type:@"multipart/form-data"
//                         filename:fileName];
    self.postingAllowed = NO;

    [feedRequest performRequestWithHandler:^(NSData *responseData,
                                             NSHTTPURLResponse *urlResponse, NSError *error)
     {
         NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];

         if (responseDictionary[@"id"] != nil) {


             
             [NSApp endSheet:self.window returnCode:NSOKButton];
             [self.window orderOut:self];

             
         } else {

            self.postingAllowed = YES;

         }

     }];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"Report Posted"
                                                        object:report
                                                      userInfo:nil];

    



}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void * )contextInfo {

    if (returnCode == NSOKButton) {

        DJAppDelegate *delegate = (DJAppDelegate *) [NSApp delegate];
        [delegate saveAction:self];

        NSURL *group = [NSURL URLWithString:@"http://facebook.com/groups/accountabilitybuddies7/"];
        [[NSWorkspace sharedWorkspace] openURL:group];
        
    }
}

@end
