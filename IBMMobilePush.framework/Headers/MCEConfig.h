/* IBM Confidential
 * OCO Source Materials
 * 5725E28, 5725S01, 5725I03
 * © Copyright IBM Corp. 2014, 2016
 *
 * The source code for this program is not published or otherwise
 * divested of its trade secrets, irrespective of what has been
 * deposited with the U.S. Copyright Office.
 */

@import CoreLocation;

extern int mceLogLevel;

/** MCEConfig provides the current configuration of the SDK. */
@interface MCEConfig : NSObject

/** sessionTimeout specifies how long sessions last. It can be specified in the MceConfig.plist file. If it is not specified, it is 20 minutes by default. */
@property NSInteger sessionTimeout;

/** baseUrl specifies where the SDK connects to. It can be specified in the MceConfig.plist file. If it is not specified, it is https://api.ibm.com by default. */
@property NSURL* baseUrl;

/** appKey specifies the appKey that is currently in use. A devAppKey and prodAppKey can be specified in the MceConfig.plist file and are automatically determined on launch, depending on the environment the app is running in. */
@property NSString* appKey;

/** autoInitializeFlag specifies if the SDK should initialize itself automatically or wait until the MCESdk manualInitialization method is called. This could be helpful if you want to limit the registered users and channels in your database. If not specified, this value is TRUE. */
@property BOOL autoInitializeFlag;

/** metricTimeInterval specifies how frequently metrics are sent to the server. If not specified, it defaults to 3 minutes. */
@property double metricTimeInterval;

/** appDelegateClass specifies the class that app delegate calls are forwarded to if you use the easy integration method. By default, it is not specified and does not forward calls that are not present in MceConfig.plist. */
@property Class appDelegateClass;

/** This method allows the configuration to be initialized with specified values instead of reading from the MceConfig.plist file. 
 
 @param dictionary specifies all configuration values using the same key names expected from the MceConfig.plist file.
 */
- (id)initWithDictionary:(NSDictionary *)dictionary;

/** locationSyncRadius specifies the size of the reference region to sync from the server to the device. */
@property int locationSyncRadius;

/** locationSyncTimeout specifies the minimum frequently that the deivce can sync locations from the server. */
@property int locationSyncTimeout;

/** geofenceEnabled specifies if geofences are enabled in the config file. */
@property BOOL geofenceEnabled;

/** Are beacons enabled or not */
@property BOOL beaconEnabled;

/** Beacon UUID to search for */
@property NSUUID * beaconUUID;

/** Location accuracy to set for location manager object */
@property CLLocationAccuracy geofenceAccuracy;

@end
