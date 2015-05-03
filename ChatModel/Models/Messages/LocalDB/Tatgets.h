//
//  Tatgets.h
//  ChatModel
//
//  Created by Alfred Yang on 3/05/2015.
//  Copyright (c) 2015 YY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Messages, Owner;

@interface Tatgets : NSManagedObject

@property (nonatomic, retain) NSString * target_id;
@property (nonatomic, retain) NSNumber * target_type;
@property (nonatomic, retain) NSSet *messages;
@property (nonatomic, retain) Owner *owner;
@end

@interface Tatgets (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(Messages *)value;
- (void)removeMessagesObject:(Messages *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

@end
