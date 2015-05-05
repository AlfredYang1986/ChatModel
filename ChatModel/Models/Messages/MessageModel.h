//
//  MessageModel.h
//  ChatModel
//
//  Created by Alfred Yang on 3/05/2015.
//  Copyright (c) 2015 YY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class Targets;

@interface MessageModel : NSObject
@property (nonatomic, strong) NSString* user_id;

- (id)init;
- (void)reloadDataFromLocalDBAsUser:(NSString*)user_id;

- (Targets*)targetWithName:(NSString*)target_id;

//- (NSInteger)historicalChatTargetsCount;
- (NSArray*)historicalChatTargets;
- (NSString*)targetsWithAlphOrdingAtIndex:(NSInteger)index;
- (BOOL)addFriendWithFriendID:(NSString*)friend_id;

- (NSArray*)loadAllFriends;

- (NSArray*)loadMessagesWithTargetID:(NSString*)target_id;
- (void)savaMessageWithTargetID:(NSString*)target_id Messages:(NSArray*)arr;
- (NSArray*)localMessagesWithTargetID:(NSString*)target_id;

- (void)addMessageToTarget:(NSString*)target_id Content:(NSString*)content;

- (void)addFriendToHistoryChat:(NSString*)target_id;
@end
