//
//  SignupViewController.m
//  Chatter
//
//  Created by Josh Pearlstein on 11/3/15.
//  Copyright © 2015 SEAS. All rights reserved.
//

#import "SignupViewController.h"
#import "ParseDataManager.h"
#import <Parse/Parse.h>


@interface SignupViewController ()
@property(nonatomic) ParseDataManager *dataManager;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;


@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dataManager = [ParseDataManager sharedManager];
}

- (void) signupUser{
    [_dataManager signupUser: _usernameTextField.text :_passwordTextField.text : _emailTextField.text];
   }

- (IBAction)signUpButtonPressed:(id)sender {
    
    UIButton *button = sender;
    [self signupUser];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
