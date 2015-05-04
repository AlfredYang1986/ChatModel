//
//  ViewController.m
//  ChatModel
//
//  Created by Alfred Yang on 3/05/2015.
//  Copyright (c) 2015 YY. All rights reserved.
//

#import "ViewController.h"
#import "loginModel.h"
#import "AppDelegate.h"
#import "MessageModel.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIButton *startBtn;
@property (weak, nonatomic) loginModel* lm;
@property (weak, nonatomic) MessageModel* mm;
@end

@implementation ViewController

@synthesize nameTextField = _nameTextField;
@synthesize lm = _lm;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
   
    AppDelegate* app = [[UIApplication sharedApplication] delegate];
    _lm = app.lm;
    _mm = app.mm;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appIsReady:) name:@"app ready" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess:) name:@"login success" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didSelectLoginBtn {
    NSString* name = _nameTextField.text;
    if (name.length == 0) {
        NSLog(@"no valid inputing your name");
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"please input your name" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    if ([_lm loginWithName:name]) {
        [_mm reloadDataFromLocalDBAsUser:_lm.user_id];
        
        [self performSegueWithIdentifier:@"chat" sender:nil];
        
    } else {
        NSLog(@"login faild");
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"please reinput your name" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        [alert show];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"chat"]) {
        NSLog(@"login success");
    }
}

- (void)appIsReady:(id)sender {
    _nameTextField.enabled = YES;
    _startBtn.enabled = YES;
}
@end
