/* IBM Confidential
 * OCO Source Materials
 * 5725E28, 5725S01, 5725I03
 * © Copyright IBM Corp. 2015, 2015
 * The source code for this program is not published or otherwise
 * divested of its trade secrets, irrespective of what has been
 * deposited with the U.S. Copyright Office.
 */

@import Foundation;

/** The MCEPhoneHomeManager class can be used to force a phone home update when you know the userId or channelId is updated on the server. */
@interface MCEPhoneHomeManager : NSObject

/** The phoneHome method tries to phone home, if a phone home was done less the 24 hours ago this method will do nothing. */
+(void)phoneHome;

/** The forcePhoneHome method forces a phone home update. */
+(void)forcePhoneHome;

@end
