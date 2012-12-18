//
//  DJAppDelegate.m
//  Closer
//
//  Created by Earl on 12/12/12.
//  Copyright (c) 2012 Earl. All rights reserved.
//

#import "DJAppDelegate.h"
#import <ScriptingBridge/ScriptingBridge.h>
#import "Things.h"
#import "GRMustache.h"
#import "DJTodo.h"
#import <WebKit/WebKit.h>
@implementation DJAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.things = [SBApplication applicationWithBundleIdentifier:@"com.culturedcode.Things"];
    [self computePoints:self];

    // Insert code here to initialize your application
}

- (void)computePoints:(id)sender {
    
    
    ThingsList *logbook = [self.things.lists objectWithName:@"Logbook"];
    SBElementArray *toDos = logbook.toDos;

    NSDate *date = [NSDate dateWithNaturalLanguageString:@"December 18, 2012 12 am"];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"completionDate > %@", date];
    [toDos filterUsingPredicate:pred];

    NSArray *names = [toDos arrayByApplyingSelector:@selector(name)];
    
    
    NSRegularExpression *exp = [[NSRegularExpression alloc] initWithPattern:@"[-+]?\\d+$" options:0
                                                                      error:NULL];
    
    
    __block NSInteger totalPoints = 0;
    
    NSMutableArray *additions, *deductions;
    additions = [NSMutableArray array];
    deductions = [NSMutableArray array];
    
    [names enumerateObjectsUsingBlock:^(NSString* toDo, NSUInteger idx, BOOL *stop) {
        
        NSTextCheckingResult *result = [exp firstMatchInString:toDo options:0 range:NSMakeRange(0, [toDo length])];
        
        if (result) {
            NSInteger points = [[toDo substringWithRange:result.range] integerValue];
            
            DJTodo *aTodo = [DJTodo new];
            NSRange nameRange = NSMakeRange(0, result.range.location-1);
            aTodo.name = [toDo substringWithRange:nameRange];
            aTodo.points = points;
            
            if (points < 0) {
                
                [deductions addObject:aTodo];
                
            } else {
                
                [additions addObject:aTodo];
            }
            totalPoints = totalPoints + points;
            
            NSLog(@"%@ %ld points: %ld", aTodo.name, aTodo.points, totalPoints);
            
            

            
        }
        
        
        
        
        
    }];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterMediumStyle];
    [df setTimeStyle:NSDateFormatterNoStyle];
    
    
    
    NSDictionary *data = @{@"additions" : additions, @"deductions" : deductions, @"date": [df stringFromDate:[NSDate date]], @"totalPoints" : [NSString stringWithFormat:@"%ld", totalPoints]};
    
    NSError *error;
    NSString *result = [GRMustacheTemplate renderObject:data fromResource:@"Format" bundle:[NSBundle mainBundle] error:&error];
    if (!result) {
        
        
        NSLog(@"error: %@", [error localizedDescription]);
    } else {
        
        [[self.viewer mainFrame] loadHTMLString:result baseURL:nil];
        
    }
    
    
    // limit to logbook entries only
    // filter them with the date since last close
    // optimize with nsoperation or nsoperation queue
    
    
    
    
    
    
}

@end
