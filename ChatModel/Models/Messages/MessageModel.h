//
//  MessageModel.h
//  ChatModel
//
//  Created by Alfred Yang on 3/05/2015.
//  Copyright (c) 2015 YY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MessageModel : NSObject
@property (nonatomic, strong) NSString* user_id;

- (id)init;
- (void)reloadDataFromLocalDBAsUser:(NSString*)user_id;

- (NSInteger)historicalChatTargetsCount;
- (NSString*)targetsWithAlphOrdingAtIndex:(NSInteger)index;
- (BOOL)addFriendWithFriendID:(NSString*)friend_id;
- (void)reloadFriends
@end
