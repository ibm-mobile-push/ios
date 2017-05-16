/* IBM Confidential
 * OCO Source Materials
 * 5725E28, 5725S01, 5725I03
 * © Copyright IBM Corp. 2014, 2016
 *
 * The source code for this program is not published or otherwise
 * divested of its trade secrets, irrespective of what has been
 * deposited with the U.S. Copyright Office.
 */

#import "MCEEvent.h"
#import "MCEClient.h"

/** The MCEEventClient class is used to send events directly to the server. If an error occurs, you can resend the request, if desired. If you want the SDK to handle retries, use the MCEEventService class. */
@interface MCEEventClient : MCEClient

/** The sendEvents:completion: method is used to send events directly to the server. If an error occurs, you can resend the request, if desired. */
- (void)sendEvents:(NSArray*)events completion:(void (^)(NSError * error))callback;

@end
