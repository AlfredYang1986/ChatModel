//
//  Owner.h
//  ChatModel
//
//  Created by Alfred Yang on 3/05/2015.
//  Copyright (c) 2015 YY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Friend, Tatgets;

@interface Owner : NSManagedObject

@property (nonatomic, retain) NSString * user_id;
@property (nonatomic, retain) NSSet *history_chats;
@property (nonatomic, retain) NSSet *friends;
@end

@interface Owner (CoreDataGeneratedAccessors)

- (void)addHistory_chatsObject:(Tatgets *)value;
- (void)removeHistory_chatsObject:(Tatgets *)value;
- (void)addHistory_chats:(NSSet *)values;
- (void)removeHistory_chats:(NSSet *)values;

- (void)addFriendsObject:(Friend *)value;
- (void)removeFriendsObject:(Friend *)value;
- (void)addFriends:(NSSet *)values;
- (void)removeFriends:(NSSet *)values;

@end
