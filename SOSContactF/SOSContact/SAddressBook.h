//
//  SAddressBook.h
//  SOSContacts
//
//  Created by Sarp Solakoglu on 04/11/14.
//  Copyright (c) 2014 Sarp Solakoglu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SContact.h"
@import AddressBook;

//Errors that may return
#define SOSC_ERROR_NO_PERMISSION [NSError errorWithDomain:@"SAddressBook" code:1 userInfo:@{NSLocalizedDescriptionKey : @"No permission to access contacts"}];
#define SOSC_ERROR_NEED_TO_ASK_FOR_PERMISSION [NSError errorWithDomain:@"SAddressBook" code:2 userInfo:@{ NSLocalizedDescriptionKey : @"Need to ask for permission"}];
#define SOSC_ERROR_CANNOT_CONNECT [NSError errorWithDomain:@"SAddressBook" code:3 userInfo:@{NSLocalizedDescriptionKey : @"Cannot connect to API"}];


@interface SAddressBook : NSObject

//Parameters that can be managed
@property (nonatomic, strong) NSString* api_key;
@property (nonatomic, strong) NSString* api_url;
@property (nonatomic, assign) BOOL shouldAskForPermission;
@property (nonatomic, assign) int retryLimit;

//Access to singleton
+ (instancetype)sharedInstance;

//Method to call to copy address book to server
-(void)copyAddressBook:(void (^)(NSError *error))completionBlock;

@end
