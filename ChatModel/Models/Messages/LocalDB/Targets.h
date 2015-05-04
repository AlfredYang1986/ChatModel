//
//  Targets.h
//  ChatModel
//
//  Created by Alfred Yang on 4/05/2015.
//  Copyright (c) 2015 YY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Messages, Owner;

@interface Targets : NSManagedObject

@property (nonatomic, retain) NSString * target_id;
@property (nonatomic, retain) NSNumber * target_type;
@property (nonatomic, retain) NSNumber * is_friends;
@property (nonatomic, retain) NSNumber * has_history;
@property (nonatomic, retain) NSSet *messages;
@property (nonatomic, retain) Owner *owner;
@end

@interface Targets (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(Messages *)value;
- (void)removeMessagesObject:(Messages *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

@end
