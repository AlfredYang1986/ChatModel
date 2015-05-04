//
//  Owner.h
//  ChatModel
//
//  Created by Alfred Yang on 4/05/2015.
//  Copyright (c) 2015 YY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Targets;

@interface Owner : NSManagedObject

@property (nonatomic, retain) NSString * user_id;
@property (nonatomic, retain) NSSet *targets;
@end

@interface Owner (CoreDataGeneratedAccessors)

- (void)addTargetsObject:(Targets *)value;
- (void)removeTargetsObject:(Targets *)value;
- (void)addTargets:(NSSet *)values;
- (void)removeTargets:(NSSet *)values;

@end
