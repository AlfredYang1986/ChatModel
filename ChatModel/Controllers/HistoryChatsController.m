//
//  HistoryChatsController.m
//  ChatModel
//
//  Created by Alfred Yang on 4/05/2015.
//  Copyright (c) 2015 YY. All rights reserved.
//

#import "HistoryChatsController.h"

@interface HistoryChatsController ()
@property (weak, nonatomic) IBOutlet UITableView *queryView;

@end

@implementation HistoryChatsController {
    BOOL _isLoading;
}

@synthesize queryView = _queryView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _isLoading = NO;
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
        
        cell.textLabel.text = @"alfred";
        return cell;
    }
}

- (NSInteger)enumResentCommentsCount {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2 + [self enumResentCommentsCount];
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
          
            _isLoading = YES;
            sleep(2);
            rc.origin.y = rc.origin.y - 44;
            [_queryView setFrame:rc];
        }
    }
    _isLoading = NO;
}
@end
