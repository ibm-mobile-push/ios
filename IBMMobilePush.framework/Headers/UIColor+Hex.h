/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2014, 2018
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#if __has_feature(modules)
@import UIKit;
#else
#import <UIKit/UIKit.h>
#endif

/** This class extension is used to translate an html color representation to a UIColor. */
@interface UIColor (fromHex)

/** This method is used to translate an html color representation to a UIColor. */
+(UIColor*)colorWithHexString:(NSString*)hex;
@end
