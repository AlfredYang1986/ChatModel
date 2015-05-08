//
//  Owner+Operator.m
//  ChatModel
//
//  Created by Alfred Yang on 3/05/2015.
//  Copyright (c) 2015 YY. All rights reserved.
//

#import "Owner+ContextOpt.h"
#import "Targets.h"
#import "Messages.h"

@implementation Owner (ContextOpt)

#pragma mark -- get owner
+ (Owner*)loadOwnerInContext:(NSManagedObjectContext*)context User:(NSString*)user_id {
    
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Owner"];
    request.predicate = [NSPredicate predicateWithFormat:@"user_id = %@", user_id];
    NSSortDescriptor* des = [NSSortDescriptor sortDescriptorWithKey:@"user_id" ascending:YES];
    
    request.sortDescriptors = [NSArray arrayWithObjects: des, nil];
    
    NSError* error = nil;
    NSArray* matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || matches.count > 1) {
        NSLog(@"error with primary key");
        return nil;
    } else if (matches.count == 1) {
        Owner* tmp = [matches lastObject];
        return tmp;
    } else {
        Owner* tmp = [NSEntityDescription insertNewObjectForEntityForName:@"Owner" inManagedObjectContext:context];
        tmp.user_id = user_id;
        return tmp;
    }
}

#pragma mark -- historical messages
+ (NSArray*)loadHistoricalChatTargetInContext:(NSManagedObjectContext*)context User:(Owner*)user {
    NSArray* targets = user.targets.allObjects;
    NSMutableArray* result = [[NSMutableArray alloc]initWithCapacity:targets.count];
    for (Targets* iter  in targets) {
        if (iter.has_history.boolValue) {
            [result addObject:iter.target_id];
        }
    }

    [result sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString* left  = (NSString*)obj1;
        NSString* right = (NSString*)obj2;
        if (strcmp(left.cString, right.cString) < 0) {
            return NSOrderedAscending;
        } else if (strcmp(left.cString, right.cString) > 0) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
    return [result copy];
}

+ (void)downloadHistoricalMessageInContext:(NSManagedObjectContext*)context Target:(Targets*)target Contects:(NSArray*)content {
    for (Messages* iter in content) {
        [target addMessagesObject:iter];
        iter.toWho = target;
    }
}

+ (void)addOneMessageInContext:(NSManagedObjectContext*)context Target:(Targets*)target type:(MessageType)message_type content:(NSString*)message_content {

    Messages* tmp = [NSEntityDescription insertNewObjectForEntityForName:@"Messages" inManagedObjectContext:context];
    tmp.type = [NSNumber numberWithInteger:message_type];
    tmp.content = message_content;
    tmp.date = [NSDate date];
    tmp.type = [NSNumber numberWithInt:message_type];
    tmp.status = [NSNumber numberWithInt:MessagesStatusSended];
    tmp.toWho = target;
    [target addMessagesObject:tmp];
}

+ (void)receiveOneMessageInContext:(NSManagedObjectContext*)context FromTarget:(Targets*)target type:(MessageType)message_type content:(NSString*)message_content {
    Messages* tmp = [NSEntityDescription insertNewObjectForEntityForName:@"Messages" inManagedObjectContext:context];
    tmp.type = [NSNumber numberWithInteger:message_type];
    tmp.content = message_content;
    tmp.date = [NSDate date];
    tmp.type = [NSNumber numberWithInt:message_type];
    tmp.status = [NSNumber numberWithInt:MessagesStatusReaded];
    tmp.toWho = target;
    [target addMessagesObject:tmp];
}

+ (void)saveAllHistoricalMessagesInContext:(NSManagedObjectContext*)context {
    [context save:nil];
}

+ (NSArray*)queryMessagesInContext:(NSManagedObjectContext*)context Target:(Targets*)target {
    return [target.messages.allObjects sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        long long left_date  = [((Messages*)obj1).date timeIntervalSince1970];
        long long right_date = [((Messages*)obj2).date timeIntervalSince1970];
        if (left_date > right_date) {
            return NSOrderedDescending;
        } else {
            return NSOrderedAscending;
        }
    }];
}


+ (void)downloadHistoricalMessageInContext:(NSManagedObjectContext*)context User:(Owner*)user Target:(Targets*)target Contects:(NSArray*)content {
    
}

+ (Targets*)queryTargetInContext:(NSManagedObjectContext*)context UserID:(NSString*)user_id TargetID:(NSString*)target_id {
    
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Targets"];
    request.predicate = [NSPredicate predicateWithFormat:@"(target_id=%@) AND (owner.user_id=%@)", target_id, user_id];
//    NSSortDescriptor* des = [NSSortDescriptor sortDescriptorWithKey:@"user_id" ascending:YES];
//    request.sortDescriptors = [NSArray arrayWithObjects: des, nil];
    
    NSError* error = nil;
    NSArray* matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || matches.count > 1) {
        NSLog(@"error with primary key");
        return nil;
    } else if (matches.count == 1) {
        Targets* tmp = [matches lastObject];
        return tmp;
    } else {
//        Owner* o = [Owner loadOwnerInContext:context User:user_id];
//        Targets* tmp = [NSEntityDescription insertNewObjectForEntityForName:@"Tatgets" inManagedObjectContext:context];
//        tmp.target_id = target_id;
//        tmp.is_friends = YES;
//        tmp.has_history = NO;
//        tmp.owner = o;
//        [o addTargetsObject:tmp];
        
//        return tmp;
        NSLog(@"no such target in friend and history");
        return nil;
    }
}

+ (void)saveMessagesInContext:(NSManagedObjectContext*)context Target:(Targets*)target Messages:(NSArray*)arr {
    for (Messages* iter in target.messages.allObjects) {
        [target removeMessagesObject:iter];
        [context deleteObject:iter];
    }
    
    for (NSDictionary* iter in arr) {
        Messages* tmp = [NSEntityDescription insertNewObjectForEntityForName:@"Messages" inManagedObjectContext:context];
        tmp.content = [iter objectForKey:@"message_content"];
        tmp.type = [iter objectForKey:@"message_type"];
        tmp.toWho = target;
        tmp.type = MessageTypeTextMessage;
        if ([[iter objectForKey:@"sender"] isEqualToString:target.target_id]) {
            tmp.status = [NSNumber numberWithInt:MessagesStatusReaded];
        } else {
            tmp.status = [NSNumber numberWithInt:MessagesStatusSended];
        }

        NSNumber* mills = [iter objectForKey:@"date"];
        NSTimeInterval seconds = mills.longLongValue / 1000.0;
        tmp.date = [NSDate dateWithTimeIntervalSince1970:seconds];
    }
}

#pragma mark -- friends
+ (NSArray*)loadFriendsInContext:(NSManagedObjectContext*)context User:(Owner*)user {
   
    NSMutableArray* ma = [[NSMutableArray alloc] init];
    for (Targets* iter in user.targets.allObjects) {
        if (iter.is_friends) {
            [ma addObject:iter.target_id];
        }
    }
    return [ma copy];
}

+ (void)saveFriendsInContext:(NSManagedObjectContext*)context User:(Owner*)user Friends:(NSArray*)array {

    for (Targets* iter in user.targets.allObjects) {
        if (iter.is_friends.boolValue) {
            [user removeTargetsObject:iter];
            [context deleteObject:iter];
        }
    }
    
    for (NSString* iter in array) {
        Targets* tmp = [NSEntityDescription insertNewObjectForEntityForName:@"Targets" inManagedObjectContext:context];
        tmp.target_id = iter;
        tmp.is_friends = [NSNumber numberWithInt:1];
        tmp.has_history = [NSNumber numberWithInt:0];
        tmp.owner = user;
        [user addTargetsObject:tmp];
    }
}

+ (void)addFriendToHistoricalChat:(NSManagedObjectContext*)context User:(Owner*)user TargetID:(NSString*)target_id {
   
    Targets* t = [[user.targets.allObjects filteredArrayUsingPredicate: [NSPredicate predicateWithFormat:@"target_id = %@", target_id]] lastObject];
    
    t.has_history = [NSNumber numberWithInt:1];
}

+ (void)deleteFriendToHistoricalChat:(NSManagedObjectContext*)context User:(Owner*)user TargetID:(NSString*)target_id {
    
}
@end
