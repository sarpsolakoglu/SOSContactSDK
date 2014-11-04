//
//  SAddress.m
//  SOSContacts
//
//  Created by Sarp Solakoglu on 04/11/14.
//  Copyright (c) 2014 Sarp Solakoglu. All rights reserved.
//

#import "SAddress.h"

@implementation SAddress

//Bridge refs to relative string values
- (id)initWithAddressDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        _street = dictionary[(__bridge NSString *)kABPersonAddressStreetKey];
        _city = dictionary[(__bridge NSString *)kABPersonAddressCityKey];
        _state = dictionary[(__bridge NSString *)kABPersonAddressStateKey];
        _zip = dictionary[(__bridge NSString *)kABPersonAddressZIPKey];
        _country = dictionary[(__bridge NSString *)kABPersonAddressCountryKey];
        _countryCode = dictionary[(__bridge NSString *)kABPersonAddressCountryCodeKey];
    }
    return self;
}

@end
