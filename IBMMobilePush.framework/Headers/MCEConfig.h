/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2014, 2018
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */


#if __has_feature(modules)
@import CoreLocation;
#else
#import <CoreLocation/CoreLocation.h>
#endif

extern int mceLogLevel;

/** MCEConfig provides the current configuration of the SDK. */
@interface MCEConfig : NSObject

/** This method returns the singleton object of this class. */
+ (instancetype)sharedInstance;

/** sessionTimeout specifies how long sessions last. It can be specified in the MceConfig.plist file. If it is not specified, it is 20 minutes by default. */
@property NSInteger sessionTimeout;

/** baseUrl specifies where the SDK connects to. It can be specified in the MceConfig.plist file. If it is not specified, it is https://api.ibm.com by default. */
@property NSURL* baseUrl;

/** appKey specifies the appKey that is currently in use. A devAppKey and prodAppKey can be specified in the MceConfig.plist file and are automatically determined on launch, depending on the environment the app is running in.
 
 Note: This value may not be correct on Apple Watch, please use MCERegistrationDetails.sharedInstance.appKey instead.
 */
@property NSString* appKey;

/** autoInitializeFlag specifies if the SDK should initialize itself automatically or wait until the MCESdk manualInitialization method is called. This could be helpful if you want to limit the registered users and channels in your database. If not specified, this value is TRUE. */
@property BOOL autoInitializeFlag;

/** autoInitializeLocationFlag specifies if the SDK should initialize the location services at first launch or wait until the MCESdk manualLocationInitialization method is called. */
@property BOOL autoInitializeLocationFlag;

/** metricTimeInterval specifies how frequently metrics are sent to the server. If not specified, it defaults to 3 minutes. */
@property double metricTimeInterval;

/** appDelegateClass specifies the class that app delegate calls are forwarded to if you use the easy integration method. By default, it is not specified and does not forward calls that are not present in MceConfig.plist. */
@property Class appDelegateClass;

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

/** Name of user activity handoff activity name, used when the Apple Watch hands off actions to the iPhone paired with it. **/
@property NSString * handoffUserActivityName;

/** Name of the interface controller used to let the user know that they will need to continue the action on their iPhone. **/
@property NSString * handoffInterfaceController;

/** The name of the action cateory that is used to display dynamic watch notifications to the user. **/
@property NSString * watchCategory;

/** A configuration flag that resets the userId and channelId to new values on reinstallation. **/
@property BOOL invalidateExistingUser;

/** A configuration flag writes databases to the iTunes file sharing location instead of private storage */
@property BOOL privateDatabaseStorage;

/** This configuration flag allows the SDK to register with the server when the registration has been invalidated when it is set to true. When it is false, the application should check the MCERegistrationDetails.sharedInstance.userInvalidated response and when true execute MCESdk.sharedInstance's manualInitialization method in order to register with the server again. */
@property BOOL autoReinitialize;

@end

