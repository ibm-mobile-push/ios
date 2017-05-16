/* IBM Confidential
 * OCO Source Materials
 * 5725E28, 5725S01, 5725I03
 * © Copyright IBM Corp. 2014, 2017
 *
 * The source code for this program is not published or otherwise
 * divested of its trade secrets, irrespective of what has been
 * deposited with the U.S. Copyright Office.
 */

//
// Created by Feras on 8/20/13.
//


@import Foundation;
@import CoreLocation;

#define MCE_FF_TABLET @"tablet"
#define MCE_FF_HANDSET @"handset"

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

/** The carrierName method returns the name of the carrier that the device is connected to. */
+ (NSString *)carrierName;

/** The currentDateInISO8601Format returns the current timestamp in ISO8601 format. */
+ (NSString *)currentDateInISO8601Format;

/** The dateToIso8601Format method converts an NSDate to a string formatted for ISO8601. */
+ (NSString *)dateToIso8601Format:(NSDate *)date;

/** The iso8601ToDate method converts an NSString in ISO8601 format to an NSDate object. */
+ (NSDate *)iso8601ToDate:(NSString *)iso8601Date;

/** The deviceToken method converts from an NSData, provided by APNS to an NSString. */
+ (NSString *)deviceToken:(NSData *)deviceToken;

/** The packageAttributes method takes a list of key value pairs and reformats it into an array of (key, value, type) in the attributes key of a dictionary. */
+ (NSDictionary*)packageAttributes:(NSDictionary*)attributes;

/** The attributesFromPackagedAttributes: method takes an array of (key, value, type) in the attribute key of a dictionary and reformats it into a standard key value dictionary. */
+ (NSDictionary*)attributesFromPackagedAttributes:(NSDictionary*)packagedAttributes;

/** The pushEnabled method returns if the user has enabled or disabled push. */
+(BOOL)pushEnabled;

/** Returns cached data for specified URL.
 @param url Resource location
 @param download TRUE if the resource should be downloaded if it's not cached, FALSE otherwise
 @returns Cached NSData object.
 */
+(NSData*)cachedDataForUrl:(NSURL*)url downloadIfRequired: (BOOL)download;

@end
