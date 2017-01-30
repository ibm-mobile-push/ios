/* IBM Confidential
 * OCO Source Materials
 * 5725E28, 5725S01, 5725I03
 * © Copyright IBM Corp. 2015, 2016
 * The source code for this program is not published or otherwise
 * divested of its trade secrets, irrespective of what has been
 * deposited with the U.S. Copyright Office.
 */

@import Foundation;

/** The MCEClient class is a baseclass that can be used to communicate with web servers. Subclasses can be either initialized as synchronous or asynchronous and have access to an http client that is configured for their use. */

@interface MCEClient : NSObject

/** MCECompletionCallback is the callback block format for the methods in this class. If an error object is returned the request has failed and will need to be retried if desired.  */
typedef void (^MCECompletionCallback)(NSData *result, NSError* error);

/** The patch:payload:completion: method sends the PATCH HTTP method to the specified URL.
 
 @param url The URL to send the message to

 @param payload The payload to be sent to the server
 @param callback A callback that receives the data sent back from the server, if the error pointer is not null then the request failed and may be retried if desired.
 */
- (void) patch: (NSURL*) url payload: (NSDictionary*)payload completion:(MCECompletionCallback)callback;

/** The get:completion: method sends the GET HTTP method to the specified URL.
 
 @param url The URL to send the message to
 @param callback A callback that receives the data sent back from the server, if the error pointer is not null then the request failed and may be retried if desired.
 */
- (void) get: (NSURL*) url completion:(MCECompletionCallback)callback;

/** The post:payload:completion: method sends the POST HTTP method to the specified URL.
 
 @param url The URL to send the message to
 @param payload The payload to be sent to the server
 @param callback A callback that receives the data sent back from the server, if the error pointer is not null then the request failed and may be retried if desired.
 */
- (void) post: (NSURL*) url payload: (NSDictionary*)payload completion:(MCECompletionCallback)callback;

/** The put:payload:completion: method sends the PUT HTTP method to the specified URL.
 
 @param url The URL to send the message to
 @param payload The payload to be sent to the server
 @param callback A callback that receives the data sent back from the server, if the error pointer is not null then the request failed and may be retried if desired.
 */
- (void) put: (NSURL*) url payload: (NSDictionary*)payload completion:(MCECompletionCallback)callback;

/** The delete:payload:completion: method sends the DELETE HTTP method to the specified URL.
 
 @param url The URL to send the message to
 @param payload The payload to be sent to the server
 @param callback A callback that receives the data sent back from the server, if the error pointer is not null then the request failed and may be retried if desired.
 */
- (void) delete: (NSURL*)url payload: (NSDictionary*)payload completion:(MCECompletionCallback)callback;

/** The buildUrlWithBaseUrl:parts: method assembles URLs based on a base and a set of component parts.
 
 @param baseUrl A URL base, eg http://ibm.com
 @param parts An array of parts to append to the URL eg @[ @"foo", @"bar", @"baz.html" ]
 @return A URL with the base and the appended parts eg http://ibm.com/foo/bar/baz.html
 */
- (NSURL*)buildUrlWithBaseUrl:(NSURL*)baseUrl parts:(NSArray*)parts;

@end
