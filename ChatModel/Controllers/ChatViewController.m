//
//  ChatViewController.m
//  ChatModel
//
//  Created by Alfred Yang on 5/05/2015.
//  Copyright (c) 2015 YY. All rights reserved.
//

#import "ChatViewController.h"
#import "MessageModel.h"
#import "Targets.h"
#import "Messages.h"
#import "EnumDefines.h"
#import "SRWebSocket.h"
#import "ModelDefines.h"
#import "Owner.h"

@interface ChatViewController () <UITableViewDataSource, UITableViewDelegate, SRWebSocketDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *queryView;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (strong, nonatomic) Targets* target;
@end

@implementation ChatViewController {
    BOOL _isLoading;
    NSArray* _chat_list;
    BOOL _isWebSocketConnecting;
    SRWebSocket* _socket;
}

@synthesize queryView = _queryView;
@synthesize mm = _mm;
@synthesize target_id = _target_id;
@synthesize target = _target;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _isLoading = NO;
    _isWebSocketConnecting = NO;
    
    _target = [_mm targetWithName:_target_id];
    _chat_list = [_mm loadMessagesWithTargetID:_target_id];
    
   
    _messageTextField.delegate = self;
    
    NSString* user_id = [@"ws://192.168.1.101:9000/registerDevice/" stringByAppendingString: _target.owner.user_id];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:user_id]];
    _socket = [[SRWebSocket alloc]initWithURLRequest:request];
    _socket.delegate = self;
    [_socket open];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadChatMessage];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_socket close];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -- table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"selet row");
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

#pragma mark -- table view datasource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger total = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    if (indexPath.row == 0) {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"default"];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"];
        }
        
        cell.textLabel.text = @"refreshing...";
        return cell;
    } else if (indexPath.row == total - 1){
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"default"];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"];
        }
        
        cell.textLabel.text = @"athena";
        return cell;
    } else {
        
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"default"];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"];
        }
     
        MessageStatus s = [self enumMessageStatusAtIndex:indexPath.row - 1];
        if (s  == MessagesStatusSended || s == MessagesStatusUnSended) {
            cell.textLabel.textAlignment = NSTextAlignmentRight;
        } else {
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
        }
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)",
                               [self enumMessageContentAtIndex:indexPath.row - 1],
                               [self enumMessageDateAtIndex:indexPath.row - 1]];
        
        return cell;
    }
}

- (NSString*)enumMessageContentAtIndex:(NSInteger)index {
    return ((Messages*)[_chat_list objectAtIndex:index]).content;
}

- (NSString*)enumMessageDateAtIndex:(NSInteger)index {
    NSDate* date = ((Messages*)[_chat_list objectAtIndex:index]).date;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    
//    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
//    [dateFormatter setLocale:usLocale];
    
    [dateFormatter setDateFormat:@"MMM dd HH:mm"];
    
    return [dateFormatter stringFromDate:date];
}

- (MessageType)enumMessageTypeAtIndex:(NSInteger)index {
    return MessageTypeTextMessage;
}

- (MessageStatus)enumMessageStatusAtIndex:(NSInteger)index {
    Messages* m = ((Messages*)[_chat_list objectAtIndex:index]);
    return (MessageStatus)m.status.intValue;
}

- (NSInteger)enumChatsCounts{
    return _chat_list.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2 + [self enumChatsCounts];
}

#pragma mark -- scroll refresh
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 假设偏移表格高度的20%进行刷新
    if (!_isLoading) { // 判断是否处于刷新状态，刷新中就不执行
        // 取内容的高度：
        // 如果内容高度大于UITableView高度，就取TableView高度
        // 如果内容高度小于UITableView高度，就取内容的实际高度
        float height = scrollView.contentSize.height > _queryView.frame.size.height ?_queryView.frame.size.height : scrollView.contentSize.height;
        if ((height - scrollView.contentSize.height + scrollView.contentOffset.y) / height > 0.2) { // 调用上拉刷新方
            
            NSLog(@"append chats");
            // append comments
            CGRect rc = _queryView.frame;
            rc.origin.y = rc.origin.y - 44;
            [_queryView setFrame:rc];
            
            sleep(2);
            _isLoading = YES;
            rc.origin.y = rc.origin.y + 44;
            [_queryView setFrame:rc];
        }
        
        if (- scrollView.contentOffset.y / _queryView.frame.size.height > 0.2) { // 调用下拉刷新方法
            
            NSLog(@"refresh chats");
            CGRect rc = _queryView.frame;
            rc.origin.y = rc.origin.y + 44;
            [_queryView setFrame:rc];
            
            _chat_list = [_mm loadMessagesWithTargetID:_target_id];
            [self reloadChatMessage];
            _isLoading = YES;
            rc.origin.y = rc.origin.y - 44;
            [_queryView setFrame:rc];
        }
    }
    _isLoading = NO;
}

- (void)reloadChatMessage {
    NSIndexPath* p = [NSIndexPath indexPathForRow:[self enumChatsCounts] inSection:0];
    [_queryView scrollToRowAtIndexPath:p atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

- (IBAction)didSelectSendBtn {
//    [_mm addMessageToTarget:_target_id Content:txt];
//    _chat_list = [_mm localMessagesWithTargetID:_target_id];
//    [_queryView reloadData];
//    
//    // add this to historical chat
//    [_mm addFriendToHistoryChat:_target_id];
    
//    NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
//    [dic setValue:_target.owner.user_id forKey:@"user_id"];
//    [dic setValue:_target_id forKey:@"receiver"];
//    [dic setValue:[NSNumber numberWithInt: MessageTypeTextMessage] forKey:@"message_type"];
//    [dic setValue:txt forKey:@"message_content"];
    
//    [dic setValue:@"123" forKey:@"text"];
    
    
//    NSError * error = nil;
//    NSData* jsonData =[NSJSONSerialization dataWithJSONObject:[dic copy] options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString* txt = _messageTextField.text;
    
    if (txt.length != 0) {
        NSString* jsonData = [NSString stringWithFormat: @"{\"user_id\":\"%@\", \"receiver\":\"%@\", \"message_type\":%d, \"message_content\":\"%@\"}", _target.owner.user_id, _target_id, 0, txt];
    
        [_socket send:jsonData];
    
        [_mm addMessageToTarget:_target_id Content:txt];
        _chat_list = [_mm localMessagesWithTargetID:_target_id];
        [_queryView reloadData];
    
        // add this to historical chat
        [_mm addFriendToHistoryChat:_target_id];
    }
}

#pragma mark -- SRWebSocketDelegate
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    NSString *receiveData = message;
    NSData *utf8Data = [receiveData dataUsingEncoding:NSUTF8StringEncoding];
//    NSData* data = (NSData*)message;
    NSLog(@"%@", utf8Data);
   
    NSError * error = nil;
    NSDictionary * apperals = [NSJSONSerialization JSONObjectWithData:utf8Data options:NSJSONReadingMutableLeaves | NSJSONReadingMutableContainers error:&error];
    NSLog(@"%@", apperals);

    NSString* from_tagget_id = [apperals objectForKey:@"sender"];
    NSString* from_message_content = [apperals objectForKey:@"message_content"];
    [_mm addMessageFromTarget:from_tagget_id Content:from_message_content];
    
    _chat_list = [_mm localMessagesWithTargetID:from_tagget_id];
    [_queryView reloadData];
    
    // add this to historical chat
    [_mm addFriendToHistoryChat:from_tagget_id];

}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"Opened success");
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"Web Socket error: %@", error.description);
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"Close web socket");
}

#pragma mark -- UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *) textField
{
//    currentTextField = _messageTextField;
    if (textField.tag==0) {
        [self moveView:-250];
    }
    if (textField.tag==1) {
        [self moveView:-600];
    }
}

- (void)textFieldDidEndEditing:(UITextField *) textField
{
//    currentTextField = nil;
    if (textField.tag==0) {
        [self moveView:250];
    }
    if (textField.tag==1) {
        [self moveView:600];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *) textFiel
{
    [self respondsToSelector:nil];
    [_messageTextField endEditing:YES];
    return TRUE;
}

- (void)moveView:(float)move
{
    NSTimeInterval animationDuration = 0.30f;
    CGRect frame = self.view.frame;
    frame.origin.y +=move;
    self.view.frame = frame;
    [UIView beginAnimations:@"ResizeView" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.view.frame = frame;
    [UIView commitAnimations];
}

@end
