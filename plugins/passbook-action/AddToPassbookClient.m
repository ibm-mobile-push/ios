/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2015, 2016
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#import "AddToPassbookClient.h"

@implementation AddToPassbookClient
-(void)getPassFrom: (NSURL*) url withCompletion:(PassCallback)callback
{
    [self get:url completion:^(NSData *result, NSError *error) {
        if(error)
        {
            callback(nil, error);
            return;
        }
        
        NSError * passError = nil;
        PKPass * pass = [[PKPass alloc]initWithData:result error:&passError];
        if(passError)
        {
            callback(nil, passError);
            return;
        }

        callback(pass, nil);
    }];
}
@end

