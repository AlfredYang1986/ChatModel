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

- (NSInteger)historicalChatTargetsCount {
    Owner* o = [Owner loadOwnerInContext:_doc.managedObjectContext User:_user_id];
    return [Owner loadHistoricalChatTargetInContext:_doc.managedObjectContext User:o].count;
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
@end
