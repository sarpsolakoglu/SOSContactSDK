SOSContact iOS SDK Readme
=======

To install add the SOSContact.framework library to your project and import `#import <SOSContact/SAddressBook.h>`

Exampe usage
-------

    //**For this example I assumed there would be a connection with the API key that is sent through the HTTP header. The JSON data is sent in the body.**
    [SAddressBook sharedInstance].api_key = @"lsajf9493aghaaas29";
    //The URL that the JSON data would be posted to.
    [SAddressBook sharedInstance].api_url = @"api.soscontact.com/uploadContacts";
    //How many times it would try to send before giving error.
    [SAddressBook sharedInstance].retryLimit = 4;
    //Should the SDK ask for permission if there isn't any.
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



Errors that could return so the SDK user can take action accordingly.
- SOSC_ERROR_NO_PERMISSION (access denied)
- SOSC_ERROR_NEED_TO_ASK_FOR_PERMISSION (need to ask for access but SDK user did not want to ask)
- error from the NSSessionDataTask 


- Example usage can be found in SOSContactTest project.
- The framework was generated from the SOSContact project and the code can be reviewed from there.
- The SOSContact.framework is also included.