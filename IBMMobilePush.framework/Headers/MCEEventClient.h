/* IBM Confidential
 * OCO Source Materials
 * 5725E28, 5725S01, 5725I03
 * © Copyright IBM Corp. 2014, 2017
 *
 * The source code for this program is not published or otherwise
 * divested of its trade secrets, irrespective of what has been
 * deposited with the U.S. Copyright Office.
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
