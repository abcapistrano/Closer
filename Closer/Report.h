//
//  Report.h
//  Closer
//
//  Created by Earl on 1/26/13.
//  Copyright (c) 2013 Earl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DJEntry;

@interface Report : NSManagedObject

@property (nonatomic, retain) NSDate * closingDate;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSData * pointsReport;
@property (nonatomic, retain) NSNumber * totalPoints;
@property (nonatomic, retain) NSNumber * deductions;
@property (nonatomic, retain) NSSet *entries;
@end

@interface Report (CoreDataGeneratedAccessors)

- (void)addEntriesObject:(DJEntry *)value;
- (void)removeEntriesObject:(DJEntry *)value;
- (void)addEntries:(NSSet *)values;
- (void)removeEntries:(NSSet *)values;

@end
