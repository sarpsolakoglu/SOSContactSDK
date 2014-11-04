//
//  SContact.m
//  SOSContacts
//
//  Created by Sarp Solakoglu on 04/11/14.
//  Copyright (c) 2014 Sarp Solakoglu. All rights reserved.
//

#import "SContact.h"
#import "SAddress.h"

@implementation SContact

- (id)initWithRecordRef:(ABRecordRef)recordRef
{
    self = [super init];
    if (self)
    {

        //Extract the fields into relative properties
        _firstName = [self stringProperty:kABPersonFirstNameProperty fromRecord:recordRef];
        _middleName = [self stringProperty:kABPersonMiddleNameProperty fromRecord:recordRef];
        _lastName = [self stringProperty:kABPersonLastNameProperty fromRecord:recordRef];
        _company = [self stringProperty:kABPersonOrganizationProperty fromRecord:recordRef];
        _phones = [self arrayProperty:kABPersonPhoneProperty fromRecord:recordRef];
        _emails = [self arrayProperty:kABPersonEmailProperty fromRecord:recordRef];
        
        //The address object has multiple fields
        NSMutableArray *addresses = [[NSMutableArray alloc] init];
        NSArray *array = [self arrayProperty:kABPersonAddressProperty fromRecord:recordRef];
        for (NSDictionary *dictionary in array)
        {
            //Init the SAddress object from the dictionary
            SAddress *address = [[SAddress alloc] initWithAddressDictionary:dictionary];
            [addresses addObject:address];
        }
        _addresses = addresses.copy;
        
    }
    return self;
}

//Method to get property from ABRecordRef and return as NSString
- (NSString *)stringProperty:(ABPropertyID)property fromRecord:(ABRecordRef)recordRef
{
    CFTypeRef valueRef = (ABRecordCopyValue(recordRef, property));
    return (__bridge_transfer NSString *)valueRef;
}

//Method to get multi-value properties (phone, email, address) from ABRecordRef and return as an Array
- (NSArray *)arrayProperty:(ABPropertyID)property fromRecord:(ABRecordRef)recordRef
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    ABMultiValueRef multiValue = ABRecordCopyValue(recordRef, property);
    NSUInteger count = (NSUInteger)ABMultiValueGetCount(multiValue);
    for (NSUInteger i = 0; i < count; i++)
    {
        CFTypeRef value = ABMultiValueCopyValueAtIndex(multiValue, i);
        NSString *string = (__bridge_transfer NSString *)value;
        if (string)
        {
            [array addObject:string];
        }
    }
    CFRelease(multiValue);
    return array.copy;
}

//Simple conversion
- (NSDictionary*)convertToDict{
    if (self) {
        NSMutableDictionary *innerDictValue = [[NSMutableDictionary alloc] init];
        if (_firstName != nil){
            [innerDictValue setObject:_firstName forKey:@"firstName"];
        }
        if (_middleName != nil){
            [innerDictValue setObject:_middleName forKey:@"middleName"];
        }
        if (_lastName != nil){
            [innerDictValue setObject:_lastName forKey:@"lastName"];
        }
        if (_company != nil){
            [innerDictValue setObject:_company forKey:@"company"];
        }
        if (_phones != nil && _phones.count > 0){
            NSMutableDictionary *phoneDict = [[NSMutableDictionary alloc] init];
            for (int i=0;i<_phones.count;i++) {
                [phoneDict setObject:_phones[i] forKey:[NSString stringWithFormat:@"phone %d",i+1]];
            }
            [innerDictValue setObject:phoneDict forKey:@"phones"];
        }
        if (_emails != nil && _emails.count > 0){
            NSMutableDictionary *emailDict = [[NSMutableDictionary alloc] init];
            for (int i=0;i<_emails.count;i++) {
                [emailDict setObject:_emails[i] forKey:[NSString stringWithFormat:@"email %d",i+1]];
            }
            [innerDictValue setObject:emailDict forKey:@"emails"];
        }
        return innerDictValue;
    }
    return nil;
}

@end
