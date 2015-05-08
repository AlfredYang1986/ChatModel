//
//  MessageModel.m
//  ChatModel
//
//  Created by Alfred Yang on 3/05/2015.
//  Copyright (c) 2015 YY. All rights reserved.
//

#import "MessageModel.h"
#import "ModelDefines.h"
#import <CoreData/CoreData.h>
#import "Owner.h"
#import "Targets.h"
#import "Messages.h"
#import "Owner+ContextOpt.h"
#import "RemoteInstance.h"

@interface MessageModel ()
@property (strong, nonatomic) UIManagedDocument* doc;
@end

@implementation MessageModel

@synthesize user_id = _user_id;

- (void)reloadDataFromLocalDBAsUser:(NSString*)user_id {
    NSLog(@"load local chat history for user %@", user_id);
    _user_id = user_id;
}

- (void)enumDataFromLocalDB:(UIManagedDocument*)document {
    dispatch_queue_t aq = dispatch_queue_create("load_data", NULL);
    
    dispatch_async(aq, ^(void){
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [document.managedObjectContext performBlock:^(void){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"app ready" object:nil];
            }];
        });
    });
}

- (id)init {
    self = [super init];
    /**
     * get authorised user array in the local database
     */
    NSString* docs=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSURL* url =[NSURL fileURLWithPath:[docs stringByAppendingPathComponent:LOCALDB_CHAT]];
    _doc = (UIManagedDocument*)[[UIManagedDocument alloc]initWithFileURL:url];
    
    if (![[NSFileManager defaultManager]fileExistsAtPath:[url path] isDirectory:NO]) {
        [_doc saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){
            [self enumDataFromLocalDB:_doc];
        }];
    } else if (_doc.documentState == UIDocumentStateClosed) {
        [_doc openWithCompletionHandler:^(BOOL success){
            [self enumDataFromLocalDB:_doc];
        }];
    } else {
        
    }
    return self;
}

//- (NSInteger)historicalChatTargetsCount {
- (NSArray*)historicalChatTargets {
    Owner* o = [Owner loadOwnerInContext:_doc.managedObjectContext User:_user_id];
    return [Owner loadHistoricalChatTargetInContext:_doc.managedObjectContext User:o];
}

- (NSString*)targetsWithAlphOrdingAtIndex:(NSInteger)index {
    Owner* o = [Owner loadOwnerInContext:_doc.managedObjectContext User:_user_id];
    return [[Owner loadHistoricalChatTargetInContext:_doc.managedObjectContext User:o] objectAtIndex:index];
}

- (BOOL)addFriendWithFriendID:(NSString*)friend_id {
    
    NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
    [dic setValue:_user_id forKey:@"user_id"];
    [dic setValue:friend_id forKey:@"friend_id"];
    
    NSError * error = nil;
    NSData* jsonData =[NSJSONSerialization dataWithJSONObject:[dic copy] options:NSJSONWritingPrettyPrinted error:&error];
    
    NSDictionary* result = [RemoteInstance remoteSeverRequestData:jsonData toUrl:[NSURL URLWithString:ADDFRIEND]];
    
    if ([[result objectForKey:@"status"] isEqualToString:@"ok"]) {
        NSArray* arr = [[result objectForKey:@"result"] objectForKey:@"friends"];
        Owner* o = [Owner loadOwnerInContext:_doc.managedObjectContext User:_user_id];
        [Owner saveFriendsInContext:_doc.managedObjectContext User:o Friends:arr];
        return YES;
    } else {
        return NO;
    }
}

- (NSArray*)loadAllFriends {
//    Owner* o = [Owner loadOwnerInContext:_doc.managedObjectContext User:_user_id];
//    return [Owner loadFriendsInContext:_doc.managedObjectContext User:o];
    
    NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
    [dic setValue:_user_id forKey:@"user_id"];
    
    NSError * error = nil;
    NSData* jsonData =[NSJSONSerialization dataWithJSONObject:[dic copy] options:NSJSONWritingPrettyPrinted error:&error];
    
    NSDictionary* result = [RemoteInstance remoteSeverRequestData:jsonData toUrl:[NSURL URLWithString:QUERYFRIENDS]];
    
    if ([[result objectForKey:@"status"] isEqualToString:@"ok"]) {
        NSArray* arr = [[result objectForKey:@"result"] objectForKey:@"friends"];
        Owner* o = [Owner loadOwnerInContext:_doc.managedObjectContext User:_user_id];
        [Owner saveFriendsInContext:_doc.managedObjectContext User:o Friends:arr];
        return [Owner loadFriendsInContext:_doc.managedObjectContext User:o];
    } else {
        return nil;
    }
}

- (Targets*)targetWithName:(NSString*)target_id {
//    Owner* o = [Owner loadOwnerInContext:_doc.managedObjectContext User:_user_id];
    return [Owner queryTargetInContext:_doc.managedObjectContext UserID:_user_id TargetID:target_id];
}

- (NSArray*)loadMessagesWithTargetID:(NSString*)target_id {

    
    NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
    [dic setValue:_user_id forKey:@"user_id"];
    [dic setValue:target_id forKey:@"target_id"];
    
    NSError * error = nil;
    NSData* jsonData =[NSJSONSerialization dataWithJSONObject:[dic copy] options:NSJSONWritingPrettyPrinted error:&error];
    
    NSDictionary* result = [RemoteInstance remoteSeverRequestData:jsonData toUrl:[NSURL URLWithString:QUERYMESSAGES]];
    
    if ([[result objectForKey:@"status"] isEqualToString:@"ok"]) {
        NSArray* arr = [[result objectForKey:@"result"] objectForKey:target_id];
        Targets* t = [Owner queryTargetInContext:_doc.managedObjectContext UserID:_user_id TargetID:target_id];
        [Owner saveMessagesInContext:_doc.managedObjectContext Target:t Messages:arr];
        return [Owner queryMessagesInContext:_doc.managedObjectContext Target:t];
    } else {
        return nil;
    }
}

- (void)addMessageToTarget:(NSString*)target_id Content:(NSString*)content {
    Targets* t = [Owner queryTargetInContext:_doc.managedObjectContext UserID:_user_id TargetID:target_id];
    [Owner addOneMessageInContext:_doc.managedObjectContext Target:t type:MessageTypeTextMessage content:content];
    
//    NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
//    [dic setValue:_user_id forKey:@"user_id"];
//    [dic setValue:target_id forKey:@"receiver"];
//    [dic setValue:[NSNumber numberWithInt: MessageTypeTextMessage] forKey:@"message_type"];
//    [dic setValue:content forKey:@"message_content"];
//    
//    NSError * error = nil;
//    NSData* jsonData =[NSJSONSerialization dataWithJSONObject:[dic copy] options:NSJSONWritingPrettyPrinted error:&error];
//    
//    NSDictionary* result = [RemoteInstance remoteSeverRequestData:jsonData toUrl:[NSURL URLWithString:SENDMESSAGE]];
//    
//    if ([[result objectForKey:@"status"] isEqualToString:@"ok"]) {
//        NSLog(@"Send message success");
//    } else {
//        NSLog(@"Send message failed");
//    }
}

- (void)addMessageFromTarget:(NSString*)target_id Content:(NSString*)content {
    Targets* t = [Owner queryTargetInContext:_doc.managedObjectContext UserID:_user_id TargetID:target_id];
    [Owner receiveOneMessageInContext:_doc.managedObjectContext FromTarget:t type:MessageTypeTextMessage content: content];
}
 

- (void)savaMessageWithTargetID:(NSString*)target_id Messages:(NSArray*)arr {
    
}

- (NSArray*)localMessagesWithTargetID:(NSString*)target_id {
//    Owner* o = [Owner loadOwnerInContext:_doc.managedObjectContext User:_user_id];
    Targets* t = [Owner queryTargetInContext:_doc.managedObjectContext UserID:_user_id TargetID:target_id];
    return [Owner queryMessagesInContext:_doc.managedObjectContext Target:t];
}

- (void)addFriendToHistoryChat:(NSString*)target_id {
    Owner* o = [Owner loadOwnerInContext:_doc.managedObjectContext User:_user_id];
    [Owner addFriendToHistoricalChat:_doc.managedObjectContext User:o TargetID:target_id];
}
@end
