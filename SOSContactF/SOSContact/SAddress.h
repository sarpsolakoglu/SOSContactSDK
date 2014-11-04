//
//  SAddress.h
//  SOSContacts
//
//  Created by Sarp Solakoglu on 04/11/14.
//  Copyright (c) 2014 Sarp Solakoglu. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AddressBook;

@interface SAddress : NSObject

//Address fields
@property (nonatomic, readonly) NSString *street;
@property (nonatomic, readonly) NSString *city;
@property (nonatomic, readonly) NSString *state;
@property (nonatomic, readonly) NSString *zip;
@property (nonatomic, readonly) NSString *country;
@property (nonatomic, readonly) NSString *countryCode;

//Init method to init object from dictionary gotten from ABRecordRef
- (id)initWithAddressDictionary:(NSDictionary *)dictionary;

@end
