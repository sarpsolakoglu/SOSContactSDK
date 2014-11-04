//
//  ViewController.h
//  SOSContactTest
//
//  Created by Sarp Solakoglu on 04/11/14.
//  Copyright (c) 2014 Sarp Solakoglu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SOSContact/SAddressBook.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
-(IBAction)testAction:(id)sender;

@end

