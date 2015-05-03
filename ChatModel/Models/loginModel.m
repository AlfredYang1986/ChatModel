//
//  loginModel.m
//  ChatModel
//
//  Created by Alfred Yang on 3/05/2015.
//  Copyright (c) 2015 YY. All rights reserved.
//

#import "loginModel.h"
#import "RemoteInstance.h"
#import "Common/ModelDefines.h"

@implementation loginModel

@synthesize user_id = _user_id;

- (BOOL)loginWithName:(NSString*) name {

    NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
    [dic setValue:name forKey:@"user_id"];
    
    NSError * error = nil;
    NSData* jsonData =[NSJSONSerialization dataWithJSONObject:[dic copy] options:NSJSONWritingPrettyPrinted error:&error];
    
    NSDictionary* result = [RemoteInstance remoteSeverRequestData:jsonData toUrl:[NSURL URLWithString:LOGIN]];
    
    if ([[result objectForKey:@"status"] isEqualToString:@"ok"]) {
        
        NSLog(@"remote login success");
        _user_id = name;
        return YES;
    }
    
    return NO;
}

@end
