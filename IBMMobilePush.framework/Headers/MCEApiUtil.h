/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2014, 2018
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */


//
// Created by Feras on 8/20/13.
//


#if __has_feature(modules)
@import Foundation;
@import CoreLocation;
#else
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#endif

#if TARGET_OS_WATCH
#define MCE_FF_WATCH @"watch"
#else
#define MCE_FF_TABLET @"tablet"
#define MCE_FF_HANDSET @"handset"
#endif

/** The MCEApiUtil class contains some helper methods for interacting with APIs */
@interface MCEApiUtil : NSObject

/** The deviceModel method returns the model of the device being used. */
+ (NSString *) deviceModel;

/** The formFactor of the device being used */
+ (NSString *) formFactor;

/** The offset method returns timezone offset in microseconds. */
+  (NSString *) offset;

/** The osVersion method returns the version of the OS that is running. */
+ (NSString *)osVersion;

#if TARGET_OS_WATCH==0
/** The carrierName method returns the name of the carrier that the device is connected to. */
+ (NSString *)carrierName;
#endif

/** The currentDateInISO8601Format returns the current timestamp in ISO8601 format. */
+ (NSString *)currentDateInISO8601Format;

/** The dateToIso8601Format method converts an NSDate to a string formatted for ISO8601. */
+ (NSString *)dateToIso8601Format:(NSDate *)date;

/** The iso8601ToDate method converts an NSString in ISO8601 format to an NSDate object. */
+ (NSDate *)iso8601ToDate:(NSString *)iso8601Date;

/** The deviceToken method converts from an NSData, provided by APNS to an NSString. */
+ (NSString *)deviceToken:(NSData *)deviceToken;

#if TARGET_OS_WATCH==0
/** The pushEnabled method returns if the user has enabled or disabled push. */
+(BOOL)pushEnabled;
#endif

/** Returns cached data for specified URL.
 @param url Resource location
 @param download TRUE if the resource should be downloaded if it's not cached, FALSE otherwise
 @returns Cached NSData object.
 */
+(NSData*)cachedDataForUrl:(NSURL*)url downloadIfRequired: (BOOL)download;

@end
