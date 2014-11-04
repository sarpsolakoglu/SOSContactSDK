//
//  ViewController.m
//  SOSContactTest
//
//  Created by Sarp Solakoglu on 04/11/14.
//  Copyright (c) 2014 Sarp Solakoglu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)testAction:(id)sender{
 
    
    [SAddressBook sharedInstance].api_key = @"lsajf9493aghaaas29";
    [SAddressBook sharedInstance].api_url = @"api.soscontact.com/uploadContacts";
    [SAddressBook sharedInstance].retryLimit = 4;
    [SAddressBook sharedInstance].shouldAskForPermission = YES;
    
    [_activity startAnimating];
    
    [[SAddressBook sharedInstance] copyAddressBook:^(NSError *error)
     {
         [_activity stopAnimating];
         if (!error)
         {
             NSLog(@"success");
         }
         else
         {
             NSLog(@"%@",[error localizedDescription]);
         }
     }];
    
}

@end
