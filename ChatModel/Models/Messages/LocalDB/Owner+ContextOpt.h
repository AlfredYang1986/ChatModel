//
//  Owner+Operator.h
//  ChatModel
//
//  Created by Alfred Yang on 3/05/2015.
//  Copyright (c) 2015 YY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Owner.h"
#import "EnumDefines.h"


@interface Owner (ContextOpt)

#pragma mark -- get owner
+ (Owner*)loadOwnerInContext:(NSManagedObjectContext*)context User:(NSString*)user_id;

#pragma mark -- historical messages
+ (NSArray*)loadHistoricalChatTargetInContext:(NSManagedObjectContext*)context User:(Owner*)user;
+ (void)downloadHistoricalMessageInContext:(NSManagedObjectContext*)context Target:(Targets*)target Contects:(NSArray*)content;
+ (void)addOneMessageInContext:(NSManagedObjectContext*)context Target:(Targets*)target type:(MessageType)message_type content:(NSString*)message_content;
+ (void)saveMessagesInContext:(NSManagedObjectContext*)context Target:(Targets*)target Messages:(NSArray*)arr;
+ (void)saveAllHistoricalMessagesInContext:(NSManagedObjectContext*)context;
+ (Targets*)queryTargetInContext:(NSManagedObjectContext*)context UserID:(NSString*)user_id TargetID:(NSString*)target_id;
+ (NSArray*)queryMessagesInContext:(NSManagedObjectContext*)context Target:(Targets*)target;

#pragma mark -- friends
+ (void)saveFriendsInContext:(NSManagedObjectContext*)context User:(Owner*)user Friends:(NSArray*)array;
+ (NSArray*)loadFriendsInContext:(NSManagedObjectContext*)context User:(Owner*)user;
+ (void)addFriendToHistoricalChat:(NSManagedObjectContext*)context User:(Owner*)user TargetID:(NSString*)target_id;
+ (void)deleteFriendToHistoricalChat:(NSManagedObjectContext*)context User:(Owner*)user TargetID:(NSString*)target_id;
@end
