/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2014, 2018
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */


#import "MCEEvent.h"
#import "MCEClient.h"

/** The MCEEventClient class is used to send events directly to the server. If an error occurs, you can resend the request, if desired. If you want the SDK to handle retries, use the MCEEventService class.
 
    Please note, this class is deprecated, please use the MCEEventService class instead.
 */

__attribute__ ((deprecated))
@interface MCEEventClient : NSObject

/** The sendEvents:completion: method is used to send events directly to the server. If an error occurs, you can resend the request, if desired. */
- (void)sendEvents:(NSArray*)events completion:(void (^)(NSError * error))callback;

@end
