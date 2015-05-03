//
//  Messages.h
//  ChatModel
//
//  Created by Alfred Yang on 3/05/2015.
//  Copyright (c) 2015 YY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Tatgets;

@interface Messages : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) Tatgets *toWho;

@end
