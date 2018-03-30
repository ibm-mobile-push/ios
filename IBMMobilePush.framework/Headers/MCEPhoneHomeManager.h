/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2015, 2018
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#if __has_feature(modules)
@import Foundation;
#else
#import <Foundation/Foundation.h>
#endif

/** The MCEPhoneHomeManager class can be used to force a phone home update when you know the userId or channelId is updated on the server. */
@interface MCEPhoneHomeManager : NSObject

/** The phoneHome method tries to phone home, if a phone home was done less the 24 hours ago this method will do nothing. */
+(void)phoneHome;

/** The forcePhoneHome method forces a phone home update. */
+(void)forcePhoneHome;

@end
