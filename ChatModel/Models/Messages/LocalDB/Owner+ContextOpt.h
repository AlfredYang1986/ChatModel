//
//  Owner+Operator.h
//  ChatModel
//
//  Created by Alfred Yang on 3/05/2015.
//  Copyright (c) 2015 YY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Owner.h"

typedef NS_ENUM(NSInteger, MessageType) {
    MessageTypeTextMessage,
    MessageTypeImageMessage,
    MessageTypeMovieMessage,
};

@interface Owner (ContextOpt)

#pragma mark -- get owner
+ (Owner*)loadOwnerInContext:(NSManagedObjectContext*)context User:(NSString*)user_id;

#pragma mark -- historical messages
+ (NSArray*)loadHistoricalChatTargetInContext:(NSManagedObjectContext*)context User:(Owner*)user;
+ (void)downloadHistoricalMessageInContext:(NSManagedObjectContext*)context Target:(Tatgets*)target Contects:(NSArray*)content;
+ (void)addOneMessageInContext:(NSManagedObjectContext*)context Target:(Tatgets*)target type:(MessageType)message_type content:(NSString*)message_content;
+ (void)saveAllHistoricalMessagesInContext:(NSManagedObjectContext*)context;
+ (Tatgets*)queryTargetInContext:(NSManagedObjectContext*)context User:(Owner*)user TargetID:(NSString*)target_id;

+ (NSArray*)queryMessagesInContext:(NSManagedObjectContext*)context Target:(Tatgets*)target;

#pragma mark -- friends
@end
