//
//  loginModel.h
//  ChatModel
//
//  Created by Alfred Yang on 3/05/2015.
//  Copyright (c) 2015 YY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface loginModel : UIViewController
@property (nonatomic, strong) NSString* user_id;

- (BOOL)loginWithName:(NSString*) name;
@end
