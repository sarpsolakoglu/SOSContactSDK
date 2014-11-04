//
//  SAddressBook.m
//  SOSContacts
//
//  Created by Sarp Solakoglu on 04/11/14.
//  Copyright (c) 2014 Sarp Solakoglu. All rights reserved.
//

#import "SAddressBook.h"

@interface SAddressBook ()
@property (nonatomic, readonly) ABAddressBookRef addressBook;
@property (nonatomic, strong) NSError *errorRecieved;
@property (nonatomic, readonly) dispatch_queue_t localQueue;
@property (nonatomic, assign) BOOL waitForSem2;
@property (nonatomic, readonly) dispatch_semaphore_t semaphore1;
@property (nonatomic, readonly) dispatch_semaphore_t semaphore2;
@property (nonatomic, assign) int retryCount;
@end

@implementation SAddressBook

//Singleton concept
+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

//Init with default values
- (id)init
{
    self = [super init];
    if (self)
    {
        _retryLimit = 3;
        _waitForSem2 = NO;
        _errorRecieved = nil;
        _api_url = @"";
        _api_key = @"";
        _shouldAskForPermission = YES;
        _addressBook = ABAddressBookCreateWithOptions(NULL, nil);
        NSString *name = [NSString stringWithFormat:@"com.esoes.SOSContact"];
        _localQueue = dispatch_queue_create([name cStringUsingEncoding:NSUTF8StringEncoding], NULL);
    }
    return self;
}

- (void)dealloc
{
    if (_addressBook) {
        CFRelease(_addressBook);
    }
}


//Main method
-(void)copyAddressBook:(void (^)(NSError *error))completionBlock{
    //Runs on own queue
    dispatch_async(self.localQueue, ^{
        //These semaphores are used to make the execution of the completion block to wait so that
        //we can wait for the results of permission request and the POST call.
        _waitForSem2 = NO;
        _semaphore1 = dispatch_semaphore_create(0);
        _semaphore2 = dispatch_semaphore_create(0);
        //Check the current access status to Address Book
        ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
        switch (status)
        {
            //Permission is denied to the app.
            case kABAuthorizationStatusDenied:
            case kABAuthorizationStatusRestricted:
            {
                
                _errorRecieved = SOSC_ERROR_NO_PERMISSION;
                
                dispatch_semaphore_signal(_semaphore1);
                break;
            }
            //Permission is already authorized to the app.
            case kABAuthorizationStatusAuthorized:
            {
                //Continue to get and send data
                [self postData:[self generateDictionaryFromContactList:[self getAllContactInfo]]];
                
                dispatch_semaphore_signal(_semaphore1);
                break;
            }
            //Permission status is unkwown
            default:
            {
                //Does the SDK user want to ask for permission.
                if (_shouldAskForPermission) {
                    //Gently ask
                    ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
                        //Permission isn't granted. Return error.
                        if (!granted){
                            
                            _errorRecieved = SOSC_ERROR_NO_PERMISSION;
                            
                        } else {
                            //Continue to get and send data
                            [self postData:[self generateDictionaryFromContactList:[self getAllContactInfo]]];
                        }
                        
                         dispatch_semaphore_signal(_semaphore1);
                    });
                } else {
                   //SDK user doesn't want to ask for permission. Return error.
                    _errorRecieved = SOSC_ERROR_NEED_TO_ASK_FOR_PERMISSION;
                    
                    dispatch_semaphore_signal(_semaphore1);
                }
                
                break;
            }
        }
        
        //Wait on own queue and let the other jobs finish before proceding
        dispatch_semaphore_wait(_semaphore1, DISPATCH_TIME_FOREVER);
        
        if (_waitForSem2) {
            dispatch_semaphore_wait(_semaphore2, DISPATCH_TIME_FOREVER);
        }
        
        //Let the completion block execute and let the SDK user if there is an error.
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           
                           if (completionBlock)
                           {
                               completionBlock(_errorRecieved);
                           }
                       });
    });
}


-(NSArray*)getAllContactInfo{
    //Get the contacts from address book
    CFArrayRef peopleArrayRef = ABAddressBookCopyArrayOfAllPeople(self.addressBook);
    NSUInteger contactCount = (NSUInteger)CFArrayGetCount(peopleArrayRef);
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    //Iterate
    for (NSUInteger i = 0; i < contactCount; i++)
    {
        //Get each ABRecordRef and convert it to our own contact data, SContact.
        ABRecordRef recordRef = CFArrayGetValueAtIndex(peopleArrayRef, i);
        SContact *contact = [[SContact alloc] initWithRecordRef:recordRef];
        [contacts addObject:contact];
    }
    CFRelease(peopleArrayRef);
    //Return an array of SContacts
    return contacts.copy;
}

-(NSDictionary*)generateDictionaryFromContactList:(NSArray*)contactList{
    //Create a NSDictionary from all SContacts that will be later converted to JSON data.
    NSMutableDictionary *outerDict = [[NSMutableDictionary alloc] init];
    for (int i=0; i<contactList.count; i++) {
        //Use the Dictionary conversion written inside the SContact class to fill outer dictionary.
        SContact *contact = contactList[i];
        NSDictionary *contactDict = [contact convertToDict];
        [outerDict setObject:contactDict forKey:[NSString stringWithFormat:@"contact %d",i+1]];
    }
    return outerDict;
}

-(void)postData:(NSDictionary*)dict{
    
    //If there will be data transfer, we need to wait for the result.
    _waitForSem2 = YES;
    
    //Convert the dictionary we created before into JSON data.
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    
    //Arange the connection config
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    //For this example an API-KEY is used and is sent with the HTTP header.
    sessionConfiguration.HTTPAdditionalHeaders = @{ @"api-key" : _api_key};
    sessionConfiguration.timeoutIntervalForRequest = 10.0;
    sessionConfiguration.timeoutIntervalForResource = 20.0;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    NSURL *url = [NSURL URLWithString:_api_url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPBody = jsonData;
    request.HTTPMethod = @"POST";
    //POST the data
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            //If an error is returned from the server try as much as the SDK user has determined to send the data.
            if(_retryCount == _retryLimit){
                //If the retry limit is reached return the error.
                _errorRecieved = error;
                _retryCount = 0;
                dispatch_semaphore_signal(_semaphore2);
                return;
            } else {
                //Keep trying
                [self postData:(NSDictionary*)dict];
                _retryCount++;
            }
        } else {
            //Success
            _retryCount = 0;
            dispatch_semaphore_signal(_semaphore2);
        }
    }];
    [postDataTask resume];
    
}

@end
