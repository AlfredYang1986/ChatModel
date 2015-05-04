//
//  ChatViewController.h
//  ChatModel
//
//  Created by Alfred Yang on 5/05/2015.
//  Copyright (c) 2015 YY. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MessageModel;

@interface ChatViewController : UIViewController
@property (nonatomic, weak) NSString* target_id;
@property (nonatomic, weak) MessageModel* mm;
@end
