//
//  DJAppDelegate.m
//  Closer
//
//  Created by Earl on 12/12/12.
//  Copyright (c) 2012 Earl. All rights reserved.
//

#import "DJAppDelegate.h"

#import "NSApplication+ESSApplicationCategory.h"
#import "NSApplication+SheetsAndBlocks.h"
#import "OverviewWindowController.h"
#import "Report+AdditionalMethods.h"
#import "NSDate+MoreDates.h"
#import "DJEntry+AdditionalMethods.h"
@implementation DJAppDelegate

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize lastReport = _lastReport;
@synthesize currentReport = _currentReport;

// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "com.demonjelly.A" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"com.demonjelly.Closer"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }

    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)




- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }

    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;

    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];

    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];

            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];

            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }

    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"Closer.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];

    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption : @YES, NSInferMappingModelAutomaticallyOption: @YES};
    


    if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:options error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;

    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];

    return _managedObjectContext;
}

// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;

    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }

    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (void) applicationDidFinishLaunching:(NSNotification *)notification {

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSString *transitionKey = @"transitionJanuary2013";
    BOOL hasTransitioned  = [defaults boolForKey:transitionKey];
    if (hasTransitioned == NO) {


        Report *initial = [NSEntityDescription insertNewObjectForEntityForName:@"Report"
                                                        inManagedObjectContext:self.managedObjectContext];

        NSDate *transitionDate =[NSDate dateWithNaturalLanguageString:@"January 25, 2013 23:59:59 GMT+8"];
        initial.closingDate = transitionDate ;
        initial.totalPoints = @58;

        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Entry"];
        NSPredicate *date = [NSPredicate predicateWithFormat:@"maturityDate < %@", transitionDate];
        request.predicate = date;

        NSArray *results = [self.managedObjectContext executeFetchRequest:request error:nil];


        [results makeObjectsPerformSelector:@selector(setCompletionDate:) withObject:transitionDate];

        [initial addEntries:[NSSet setWithArray:results]];




        [self saveAction:self];
        [defaults setBool:YES forKey:transitionKey];
    }



    //delete our report

/* DO NOT DELETE:

 USe the procedure below so that you can delete spurious entries
 

    NSFetchRequest *r = [[NSFetchRequest alloc] initWithEntityName:@"Report"];
    [r setPredicate:[NSPredicate predicateWithFormat:@"closingDate == %@", [[NSDate date] dateJustBeforeMidnight]]];

    NSArray *results = [self.managedObjectContext executeFetchRequest:r error:nil];

    for (Report *result in results) {

        [self.managedObjectContext deleteObject:result];
        [result.entries enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
            [self.managedObjectContext deleteObject:obj];
        }];
    }

    NSFetchRequest *e = [[NSFetchRequest alloc] initWithEntityName:@"Entries"];
    NSDate *date = [[[NSDate date] yesterday] dateJustBeforeMidnight];
    [e setPredicate:
     [NSPredicate predicateWithFormat:@"completionDate > %@",date]];

    results = [self.managedObjectContext executeFetchRequest:r error:nil];

    for (DJEntry *result in results) {
        NSLog(@"%@", result.name);

        [self.managedObjectContext deleteObject:result];
    }
    [self saveAction:self];
 */

    [self.overviewWindowController refreshReport:self];



}

- (NSManagedObject *)objectWithURI:(NSURL *)uri
{
    NSManagedObjectID *objectID =
    [[self persistentStoreCoordinator]
     managedObjectIDForURIRepresentation:uri];

    if (!objectID)
    {
        return nil;
    }

    NSManagedObject *objectForID = [self.managedObjectContext objectWithID:objectID];
    if (![objectForID isFault])
    {
        return objectForID;
    }

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[objectID entity]];

    // Equivalent to
    // predicate = [NSPredicate predicateWithFormat:@"SELF = %@", objectForID];
    NSPredicate *predicate =
    [NSComparisonPredicate
     predicateWithLeftExpression:
     [NSExpression expressionForEvaluatedObject]
     rightExpression:
     [NSExpression expressionForConstantValue:objectForID]
     modifier:NSDirectPredicateModifier
     type:NSEqualToPredicateOperatorType
     options:0];
    [request setPredicate:predicate];

    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:nil];
    if ([results count] > 0 )
    {
        return [results objectAtIndex:0];
    }

    return nil;
}



- (Report *) lastReport {

    if (_lastReport) {

        return _lastReport;


    }

    //TODO: GET THE LAST REPORT BY URI AS PERFORMANCE OPTIMIZATION

    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Report"];
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"closingDate" ascending:YES];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self != %@", self.currentReport];
    [request setPredicate:predicate];


    [request setSortDescriptors:@[sd]];

    

    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:nil];
    return [results lastObject];




}

- (Report *) currentReport {

    if (_currentReport) {

        return _currentReport;
    }

    _currentReport = [NSEntityDescription insertNewObjectForEntityForName:@"Report" inManagedObjectContext:self.managedObjectContext];
return _currentReport;


}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

@end

