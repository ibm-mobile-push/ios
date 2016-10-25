/* IBM Confidential
 * OCO Source Materials
 * 5725E28, 5725S01, 5725I03
 * © Copyright IBM Corp. 2014, 2015
 *
 * The source code for this program is not published or otherwise
 * divested of its trade secrets, irrespective of what has been
 * deposited with the U.S. Copyright Office.
 */

@import Foundation;

@class MCEResultSet;

/** The MCERichContent class represents the rich content of a message. Multiple messages can contain the same rich content. */
@interface MCERichContent : NSObject

/** richContentId is a unique identifier for the rich content. */
@property NSString * richContentId;

/** content is where the template's content is stored. The elements of this dictionary are undefined by the SDK and consist of whatever is sent. */
@property NSDictionary * content;

/** The richContentFromResultSet:error: method returns an allocated and initialized MCERichContent object with the contents of a database row or an NSError object if a problem occurs.

 @param results A database result set.
 @param error An error object describing the problem. 
 @return Returns the initialized object.
 */
+(instancetype)richContentFromResultSet:(MCEResultSet*)results error: (NSError **)error;

/** The initWithResultSet:error: method returns an initialized MCERichContent object with the contents of a database row or an NSError object if an issue occurred.

 @param results A database result set.
 @param error An error object describing the problem. 
 @return Returns the initialized object.
*/
-(instancetype)initWithResultSet:(MCEResultSet*)results error: (NSError **)error;

/** The richContentFromPayload: method returns an allocated and initialized MCERichContent object with the contents of a server API response.

 @param payload the server API response.
 @return Returns the initialized object.
*/
+(instancetype)richContentFromPayload: (NSDictionary*)payload;

/** The initWithPayload: method returns an initialized MCERichContent object with the contents of a server API response.
 
 @param payload the server API response.
 @return Returns the initialized object.
 */
-(instancetype)initWithPayload:(NSDictionary*)payload;

/** The contentData: method returns the NSData that represents the content object in the database.
 
 @param error An error describing what went wrong.
 @return An NSData object represents the content object.
*/
-(NSData*)contentData: (NSError **)error;

/** The contentData method returns the NSData that represents the content object in the database or nil if a problem occurs.
 
 @return An NSData object represents the content object or nil.
 */
-(NSData*)contentData;

@end
