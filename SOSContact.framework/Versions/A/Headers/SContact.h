//
//  SContact.h
//  SOSContacts
//
//  Created by Sarp Solakoglu on 04/11/14.
//  Copyright (c) 2014 Sarp Solakoglu. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AddressBook;

@interface SContact : NSObject

//Fields that are pulled from address book
@property (nonatomic, readonly) NSString *firstName;
@property (nonatomic, readonly) NSString *middleName;
@property (nonatomic, readonly) NSString *lastName;
@property (nonatomic, readonly) NSString *company;
@property (nonatomic, readonly) NSArray *phones;
@property (nonatomic, readonly) NSArray *emails;
@property (nonatomic, readonly) NSArray *addresses;

//init self from ABRecordRef
- (id)initWithRecordRef:(ABRecordRef)recordRef;
//Return NSDictionary of self
- (NSDictionary*)convertToDict;

@end
