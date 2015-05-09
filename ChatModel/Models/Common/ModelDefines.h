//
//  ModelDefines.h
//  YYBabyAndMother
//
//  Created by Alfred Yang on 10/01/2015.
//  Copyright (c) 2015 YY. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ModelAttchmentType) {
    ModelAttchmentTypeImage,
    ModelAttchmentTypeMovie,
};

#pragma mark -- HOST DOMAIN
//#define HOST_DOMAIN                     @"http://www.altlys.com:9000/"
#define HOST_DOMAIN                     @"http://192.168.1.101:9000/"

#pragma mark -- MESSAGE
#define LOGIN                           [HOST_DOMAIN stringByAppendingString:@"loginWithName"]
#define SENDMESSAGE                     [HOST_DOMAIN stringByAppendingString:@"sendMessage"]
#define QUERYMESSAGES                   [HOST_DOMAIN stringByAppendingString:@"queryMessages"]
#define QUERYMESSAGESWITHFRIEND         [HOST_DOMAIN stringByAppendingString:@"queryMessagesWithFriend"]
#define REGISTERDEVICE                  [HOST_DOMAIN stringByAppendingString:@"registerDevice"]
#define ADDFRIEND                       [HOST_DOMAIN stringByAppendingString:@"addOneFriend"]
#define QUERYFRIENDS                    [HOST_DOMAIN stringByAppendingString:@"queryAllFriend"]


#pragma mark -- database
#define LOCALDB_CHAT                    @"ChatData03.sqlite"
