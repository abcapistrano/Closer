//
//  DJAppDelegate.m
//  Closer
//
//  Created by Earl on 12/12/12.
//  Copyright (c) 2012 Earl. All rights reserved.
//

#import "DJAppDelegate.h"
#import <ScriptingBridge/ScriptingBridge.h>
#import "GRMustache.h"
#import "DJTodo.h"
#import <WebKit/WebKit.h>
#import "Things.h"
#import "NSApplication+ESSApplicationCategory.h"
#import "NSImage+PNG.h"

NSString * const LAST_CLOSE_DATE_KEY = @"lastCloseDate";
NSString * const POINTS_CARRYOVER_KEY = @"carryOver";

@implementation DJAppDelegate


+ (void) initialize {
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{
                                       LAST_CLOSE_DATE_KEY :  [NSDate dateWithNaturalLanguageString:@"December 20, 2012 12 am"], POINTS_CARRYOVER_KEY : [NSNumber numberWithInteger:0]}];
    
    
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.things = [SBApplication applicationWithBundleIdentifier:@"com.culturedcode.Things"];
    [self refreshReport:self];
    // Insert code here to initialize your application
}

- (IBAction)closeBooks:(id)sender {
    
    ESSBeginAlertSheet(
                       @"Warning",
                       @"Proceed",
                       @"Cancel",
                       nil,
                       self.window,
                       ^(void *context, NSInteger returnCode){
                           
                           
                           if (returnCode == NSOKButton) {
                                                              
                               [self refreshReport:sender];
                               
                               Class toDoClass = [self.things classForScriptingClass:@"to do"];
                               ThingsToDo *balanceCheck = [toDoClass new];
                               ThingsList *logbook = [self.things.lists objectWithName:@"Logbook"];
                               SBElementArray *toDos = logbook.toDos;
                               [toDos addObject:balanceCheck];
                               
                               balanceCheck.name = [NSString stringWithFormat:@"Balance Check: %ld points", self.totalPoints];
                               
                               // make a todo with the balance; tag it
                               
                               NSDate *newClosingDate = [NSDate date];
                               balanceCheck.completionDate = newClosingDate;
                               balanceCheck.tagNames = @"Balance Check";
                               
                               // set the prefs to the date of closing & carryover points
                               
                               [[NSUserDefaults standardUserDefaults] setObject:newClosingDate forKey:LAST_CLOSE_DATE_KEY];
                               [[NSUserDefaults standardUserDefaults] setInteger:self.totalPoints forKey:POINTS_CARRYOVER_KEY];
                               
                               
                               // generate a screenshot of the report
                               
                               NSImage *img = [[NSImage alloc] initWithData:[self.viewer dataWithPDFInsideRect:[self.viewer bounds]]];
                              
                               NSString *path = [@"~/Desktop/points.png" stringByExpandingTildeInPath];
                               [img saveAsPNGToURL:[NSURL fileURLWithPath:path]];
                                
                               
                               
                               [self refreshReport:sender];

                               
                               
                               
                               
                           }
                               
                               

                               
                           
                                                    
                           
                       },
                       NULL,
                       NULL,
                       @"Please check the Things Inbox for completed tasks which remain unlogged.");
 
    
    
    

    
    
}

- (void)refreshReport:(id)sender {
    
    
    ThingsList *logbook = [self.things.lists objectWithName:@"Logbook"];
    SBElementArray *toDos = logbook.toDos;
    
    
    NSDate *lastCloseDate = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_CLOSE_DATE_KEY];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"completionDate > %@", lastCloseDate];
    [toDos filterUsingPredicate:pred];

    NSArray *names = [toDos arrayByApplyingSelector:@selector(name)];
    NSRegularExpression *exp = [[NSRegularExpression alloc] initWithPattern:@"[-+]?\\d+$" options:0
                                                                      error:NULL];
    
    
    NSInteger carryOver = [[NSUserDefaults standardUserDefaults] integerForKey:POINTS_CARRYOVER_KEY];
    __block NSInteger totalPoints = carryOver;
    
    NSMutableArray *toDosDisplayed = [NSMutableArray array];
    
    [names enumerateObjectsUsingBlock:^(NSString* toDo, NSUInteger idx, BOOL *stop) {
        
        NSTextCheckingResult *result = [exp firstMatchInString:toDo options:0 range:NSMakeRange(0, [toDo length])];
        
        if (result) {
            NSInteger points = [[toDo substringWithRange:result.range] integerValue];
            
            DJTodo *aTodo = [DJTodo new];
            NSRange nameRange = NSMakeRange(0, result.range.location-1);
            
            
            
            
            
            aTodo.name =   [toDo substringWithRange:nameRange];
            aTodo.points = points;
            
            [toDosDisplayed addObject:aTodo];
            
            
            totalPoints = totalPoints + points;
            
        }
        
        
        
        
        
    }];
    
    
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"points" ascending:NO];
    [toDosDisplayed sortUsingDescriptors:@[sd]];
    
    
    
    self.totalPoints = totalPoints;
    
    // Generate report
    
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterShortStyle];
    [df setTimeStyle:NSDateFormatterShortStyle];
    
    NSDictionary *data = @{
        @"pointsCarryover" : [NSNumber numberWithInteger:carryOver],
        @"date": [df stringFromDate:[NSDate date]],
        @"totalPoints" : [NSNumber numberWithInteger:totalPoints],
        @"toDosDisplayed": toDosDisplayed,
    
    };
    
    NSError *error;
    NSString *result = [GRMustacheTemplate renderObject:data fromResource:@"Format" bundle:[NSBundle mainBundle] error:&error];
    if (!result) {
        
        
        NSLog(@"error: %@", [error localizedDescription]);
    } else {
        
        [[self.viewer mainFrame] loadHTMLString:result baseURL:nil];
        
    }
    
    
    
    
    
    
}

@end
