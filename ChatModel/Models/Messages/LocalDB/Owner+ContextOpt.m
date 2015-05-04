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
        return tmp;
    }
}

#pragma mark -- historical messages
+ (NSArray*)loadHistoricalChatTargetInContext:(NSManagedObjectContext*)context User:(Owner*)user {
    NSArray* targets = user.targets.allObjects;
    NSMutableArray* result = [[NSMutableArray alloc]initWithCapacity:targets.count];
    for (Targets* iter  in targets) {
        if (iter.has_history) {
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
    tmp.toWho = target;
    [target addMessagesObject:tmp];
}

+ (void)saveAllHistoricalMessagesInContext:(NSManagedObjectContext*)context {
    [context save:nil];
}

+ (NSArray*)queryMessagesInContext:(NSManagedObjectContext*)context Target:(Targets*)target {
    return target.messages.allObjects;
}


+ (void)downloadHistoricalMessageInContext:(NSManagedObjectContext*)context User:(Owner*)user Target:(Targets*)target Contects:(NSArray*)content {
    
}

+ (Targets*)queryTargetInContext:(NSManagedObjectContext*)context User:(NSString*)user_id TargetID:(NSString*)target_id {
    
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Targets"];
    request.predicate = [NSPredicate predicateWithFormat:@"Owner.user_id=%@", user_id];
    request.predicate = [NSPredicate predicateWithFormat:@"target_id=%@", target_id];
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
        if (iter.is_friends) {
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
@end
