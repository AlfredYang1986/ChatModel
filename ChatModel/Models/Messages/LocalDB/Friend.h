//
//  Friend.h
//  ChatModel
//
//  Created by Alfred Yang on 3/05/2015.
//  Copyright (c) 2015 YY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Owner;

@interface Friend : NSManagedObject

@property (nonatomic, retain) NSString * friend_id;
@property (nonatomic, retain) Owner *owner;

@end
