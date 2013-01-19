//
//  ComposeWindowController.m
//  Closer
//
//  Created by Earl on 1/19/13.
//  Copyright (c) 2013 Earl. All rights reserved.
//

#import "ComposeWindowController.h"

//
//
//
//
//NSString * const RULE_NUMBER_KEY = @"ruleNumber";
//NSString * const RULE_TITLE_KEY = @"ruleTitle";
//NSString * const RULE_TODOS_KEY = @"ruleToDos";
//NSString * const TODO_COMPLETED_FLAG = @"✓";
//NSString * const TODO_CANCELLED_FLAG = @"╳";
//
//// Below are the keys used by the shared defaults controller which are used to store report information
//
//NSString * const DAY_COUNT_KEY= @"dayCount";
//NSString * const MESSAGE_BODY_KEY = @"messageBody";
//NSString * const POINTS_SCREENSHOT_DATA_KEY = @"pointsScreenshotData";
//NSString * const STANDARD_OATH = @"I solemnly swear under the pains and penalties of death that this report is the truth, the whole truth, and nothing but the truth.";
//

@interface ComposeWindowController ()

@end

@implementation ComposeWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}
//
//
//
//- (void) showIrreversibleActionWarningWithCompletionHandler:(void (^)(void))action{
//
//    ESSBeginAlertSheet(
//                       @"Irreversible Action Warning",
//                       @"Proceed",
//                       @"Cancel",
//                       nil,
//                       self.messageEditorWindow,
//                       nil,
//
//                       ^(void *context, NSInteger returnCode){
//                           //invoke action when the user preses "Proceed"
//
//                           if (returnCode == NSOKButton) {
//
//                               action();
//
//
//                           }
//                       },
//                       nil,
//                       @"Please check the Things.app for completed todos which remain unlogged before proceeding.");
//
//
//
//
//
//}

// ARB stands for the "Accountability Report Builder" project
//- (void) processARB {
//
//    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"^Rule (\\d{1,}) - (.+)$"
//                                                                      options:NSRegularExpressionAnchorsMatchLines error:nil];
//    NSString *note =self.latestCompletedAccountabilityReportBuilder.notes;
//    NSMutableDictionary *rulesDisplayed = [NSMutableDictionary dictionary];
//
//
//    [regex enumerateMatchesInString:note options:0 range:NSMakeRange(0, note.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
//
//
//        NSNumber *ruleNumber = @([[note substringWithRange:[result rangeAtIndex:1]] integerValue]);
//
//        NSMutableDictionary *ruleInfo = [NSMutableDictionary dictionary];
//        ruleInfo[RULE_TITLE_KEY] = [note substringWithRange:[result rangeAtIndex:2]];
//
//        ruleInfo[RULE_NUMBER_KEY] = ruleNumber;
//        rulesDisplayed[ruleNumber] = ruleInfo;
//
//
//
//        ;
//    }];
//
//
//
//    regex = [[NSRegularExpression alloc] initWithPattern:@"^(\\d{1,}): (.+)$" options:NSRegularExpressionAnchorsMatchLines error:nil];
//
//    NSArray *projectToDos = [self.latestCompletedAccountabilityReportBuilder.toDos get];
//
//    // Go over each todo in the project so that we can stash them into the appropriate rule dictionary
//    [projectToDos enumerateObjectsUsingBlock:^(ThingsToDo* toDo, NSUInteger idx, BOOL *stop) {
//
//        NSString *longToDoName = toDo.name; //longToDoName includes the Rule Number
//
//        __block NSInteger ruleNumber;
//        __block NSString *shortToDoName;
//
//        [regex enumerateMatchesInString:longToDoName options:0 range:NSMakeRange(0,longToDoName.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
//
//            ruleNumber = [[longToDoName substringWithRange:[result rangeAtIndex:1]] integerValue];
//            shortToDoName = [longToDoName substringWithRange:[result rangeAtIndex:2]];
//
//
//        }];
//
//
//        NSMutableDictionary *ruleInfo = rulesDisplayed[@(ruleNumber)];
//
//        NSMutableArray * ruleToDos = ruleInfo[RULE_TODOS_KEY];
//        if (ruleToDos == nil) {
//
//            ruleToDos = [NSMutableArray array];
//            ruleInfo[RULE_TODOS_KEY] = ruleToDos;
//        }
//
//        //Re-create the ToDo
//
//        DJTodo *toDoDisplayed = [DJTodo new];
//        toDoDisplayed.name = shortToDoName;
//        toDoDisplayed.notes = toDo.notes;
//
//
//        if (toDo.status == ThingsStatusCompleted) {
//            toDoDisplayed.flag = TODO_COMPLETED_FLAG;
//        }
//
//
//        if (toDo.status == ThingsStatusCanceled) {
//
//            toDoDisplayed.flag = TODO_CANCELLED_FLAG;
//
//        }
//        [ruleToDos addObject:toDoDisplayed];
//
//
//
//
//
//    }];
//
//
//
//    NSError *error;
//
//    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:RULE_NUMBER_KEY ascending:NO];
//    NSArray *values = [[rulesDisplayed allValues] sortedArrayUsingDescriptors:@[sd]];
//
//    NSString *rulesDisplayedResult = [GRMustacheTemplate renderObject:@{ @"rulesDisplayed": values}
//                                                         fromResource:@"Rules Format"
//                                                               bundle:[NSBundle mainBundle]
//                                                                error:&error];
//    if (!rulesDisplayedResult) {
//
//        NSString *errorMessage = [NSString stringWithFormat:@"error in processing ARB:%@", [error localizedDescription]];
//        [[NSUserDefaults standardUserDefaults] setObject:errorMessage forKey:MESSAGE_BODY_KEY];
//
//
//    } else {
//
//        [[NSUserDefaults standardUserDefaults] setObject:rulesDisplayedResult forKey:MESSAGE_BODY_KEY];
//
//    }
//
//
//
//
//}
//
//- (void) closeBooks {
//    // make a todo with the balance; tag it
//
//    Class toDoClass = [self.things classForScriptingClass:@"to do"];
//    ThingsToDo *balanceCheck = [toDoClass new];
//    ThingsList *logbook = [self.things.lists objectWithName:@"Logbook"];
//    SBElementArray *toDos = logbook.toDos;
//    [toDos addObject:balanceCheck];
//
//    balanceCheck.name = [NSString stringWithFormat:@"Balance Check: %ld points", self.totalPoints];
//
//    NSDate *newClosingDate = [NSDate date];
//    balanceCheck.completionDate = newClosingDate;
//    balanceCheck.tagNames = @"Balance Check";
//
//    // set the prefs to the date of closing & carryover points
//
//    [[NSUserDefaults standardUserDefaults] setObject:newClosingDate forKey:LAST_CLOSE_DATE_KEY];
//    [[NSUserDefaults standardUserDefaults] setInteger:self.totalPoints forKey:POINTS_CARRYOVER_KEY];
//
//}
//
//- (void) screenshotPointsReport {
//
//    WebFrameView *frameView = self.viewer.mainFrame.frameView;
//
//    [frameView setAllowsScrolling:NO];
//
//    NSView <WebDocumentView> *docView = frameView.documentView;
//
//    NSData *imgData = [docView dataWithPDFInsideRect:docView.bounds];
//
//
//    NSDateFormatter *df = [NSDateFormatter new];
//    df.dateFormat = @"yyyy-MM-dd HHmm";
//
//    NSString *name = [[df stringFromDate:[NSDate date]] stringByAppendingPathExtension:@"pdf"];
//    NSURL *url = [NSURL fileURLWithPathComponents:@[@"/Users/earltagra/Dropbox/Goal Card/Points Log", name]];
//
//    [imgData writeToURL:url atomically:NO];
//
//    [frameView setAllowsScrolling:YES];
//    //    [[NSUserDefaults standardUserDefaults] setObject:imgData forKey:POINTS_SCREENSHOT_DATA_KEY];
//
//
//
//
//}
//
//
//
//- (IBAction)sendReport:(id) sender {
//
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    NSSharingService *email = [NSSharingService sharingServiceNamed:NSSharingServiceNameComposeEmail];
//    NSString *messageBody = [userDefaults objectForKey:MESSAGE_BODY_KEY];
//
//    //TODO: USE THE DROPBOX API DIRECTLY TO UPLOAD THE FILE
//    NSInteger days = [userDefaults integerForKey:DAY_COUNT_KEY];
//    NSString *dayCount = [NSString stringWithFormat:@"Day %ld.\n", days];
//    NSString *pointsImgMsg = @"See points in detail: https://www.dropbox.com/sh/ek4f0fibrcoq920/dXz-kapTbp\n";
//
//    [email performWithItems:@[messageBody, pointsImgMsg, dayCount, STANDARD_OATH]];
//
//}
//
//
//
//- (IBAction)makeReport:(id)sender {
//
//
//    // Do not proceed if the project named "Accountability Report Builder" is not complete.
//    [self refreshReport:sender];
//    [self showMissingARBWarning];
//    [self processARB];
//
//    [NSApp beginSheet:self.messageEditorWindow
//       modalForWindow:self.mainWindow
//          didEndBlock:^(NSInteger returnCode) {
//
//              if (returnCode == NSOKButton) {
//
//#ifdef RELEASE
//                  [self closeBooks]; //WARNING: CLOSING IS IRREVERSIBLE..
//#endif
//
//                  [self screenshotPointsReport];
//                  [self sendReport:self];
//                  [self refreshReport:self];
//                  
//                  
//                  
//                  
//                  
//                  
//              }
//              
//              
//          }
//     ];
//    
//    
//};
//
//
//- (IBAction)send:(id)sender {
//    
//    [self showIrreversibleActionWarningWithCompletionHandler:^{
//        
//        [NSApp endSheet:self.messageEditorWindow returnCode:NSOKButton];
//        [self.messageEditorWindow orderOut:self];
//        
//        
//    }];
//    
//    
//    
//    
//}
//
//- (IBAction)closeEditor:(id)sender {
//    
//    [NSApp endSheet:self.messageEditorWindow returnCode:NSCancelButton];
//    [self.messageEditorWindow orderOut:self];
//    
//}


@end
