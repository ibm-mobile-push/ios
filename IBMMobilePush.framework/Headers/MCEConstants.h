/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2014, 2018
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#if __has_feature(modules)
@import Foundation;
#else
#import <Foundation/Foundation.h>
#endif

/** The MCEConstants header contains several important SDK integration constants */

/** The MCESdkVersion constant contains the current release number */
extern const NSString * MCESdkVersion;

typedef NSNotificationName MCENotificationName NS_STRING_ENUM;

/** The MCERegisteredNotification message is sent via NSNotificationCenter when the SDK registers with the IBM servers */
extern const MCENotificationName MCERegisteredNotification;

/** The MCERegistrationChangedNotification message is sent via NSNotificationCenter when the userId or channelId change durring the phone home process */
extern const MCENotificationName MCERegistrationChangedNotification;

/** The MCEEventSuccess message is sent via NSNotificationCenter when events are successfully sent to the server */
extern const MCENotificationName MCEEventSuccess;

/** The MCEEventSuccess message is sent via NSNotificationCenter when events fail to send to the server. No action is required by the developer, the system will automatically retry with back-off. */
extern const MCENotificationName MCEEventFailure;

/** The SetUserAttributesError message is sent via NSNotificationCenter when Set User Attributes fails to send to the server. No action is required by the developer, the system will automatically retry with back-off. */
extern const MCENotificationName SetUserAttributesError;

/** The SetUserAttributesSuccess message is sent via NSNotificationCenter when Set User Attributes is successfully sent to the server */
extern const MCENotificationName SetUserAttributesSuccess;

/** The UpdateUserAttributesError message is sent via NSNotificationCenter when Update User Attributes fails to send to the server. No action is required by the developer, the system will automatically retry with back-off. */
extern const MCENotificationName UpdateUserAttributesError;

/** The UpdateUserAttributesSuccess message is sent via NSNotificationCenter when Update User Attributes is successfully sent to the server */
extern const MCENotificationName UpdateUserAttributesSuccess;

/** The DeleteUserAttributesError message is sent via NSNotificationCenter when Delete User Attributes fails to send to the server. No action is required by the developer, the system will automatically retry with back-off. */
extern const MCENotificationName DeleteUserAttributesError;

/** The DeleteUserAttributesSuccess message is sent via NSNotificationCenter when Delete User Attributes is successfully sent to the server */
extern const MCENotificationName DeleteUserAttributesSuccess;

/** The SetChannelAttributesError message is sent via NSNotificationCenter when Set Channel Attributes fails to send to the server. No action is required by the developer, the system will automatically retry with back-off. */
extern const MCENotificationName SetChannelAttributesError;

/** The SetChannelAttributesSuccess message is sent via NSNotificationCenter when Set Channel Attributes is successfully sent to the server */
extern const MCENotificationName SetChannelAttributesSuccess;

/** The UpdateChannelAttributesError message is sent via NSNotificationCenter when Update Channel Attributes fails to send to the server. No action is required by the developer, the system will automatically retry with back-off. */
extern const MCENotificationName UpdateChannelAttributesError;

/** The UpdateChannelAttributesSuccess message is sent via NSNotificationCenter when Update Channel Attributes is successfully sent to the server */
extern const MCENotificationName UpdateChannelAttributesSuccess;

/** The DeleteChannelAttributesError message is sent via NSNotificationCenter when Delete Channel Attributes fails to send to the server. No action is required by the developer, the system will automatically retry with back-off. */
extern const MCENotificationName DeleteChannelAttributesError;

/** The DeleteChannelAttributesSuccess message is sent via NSNotificationCenter when Delete Channel Attributes is successfully sent to the server */
extern const MCENotificationName DeleteChannelAttributesSuccess;

/** The Event type reported for simple notification actions */
extern const NSString * SimpleNotificationSource;

/** The Event type reported for inbox notification actions */
extern const NSString * InboxSource;

/** The Event type reported for inbox notification actions */
extern const NSString * InAppSource;

/** The LocationDatabaseReady message is sent when the location database is ready to be used. */
extern const MCENotificationName LocationDatabaseReady;

extern const MCENotificationName LocationDatabaseUpdated;

/* The EnteredGeofence message is sent when a geofence has been breached */
extern const MCENotificationName EnteredGeofence;

/* The EnteredGeofence message is sent when a geofence has been left */
extern const MCENotificationName ExitedGeofence;

/** The EnteredBeacon message is sent when a beacon region has been breached */
extern const MCENotificationName EnteredBeacon;

/** The ExitedBeacon message is sent when a beacon region has been left */
extern const MCENotificationName ExitedBeacon;

/** The DownloadedLocations message is sent when locations updates are downloaded from the server. */
extern const MCENotificationName DownloadedLocations;

/** The ResetReferenceLocation message is sent when the reference location has changed. */
extern const MCENotificationName ResetReferenceLocation;

/** The RefreshActiveGeofences message is sent when the active geofences have changed. */
extern const MCENotificationName RefreshActiveGeofences;

/** The InboxCountUpdate is sent when the number of inbox messages changes or the unread count of messages changes. */
extern const MCENotificationName InboxCountUpdate;

/** Called when the Inbox Database has been changed */
extern const MCENotificationName MCESyncDatabase;

/** Called when a custom action is opened by a user but is not registered in the application */
extern const MCENotificationName MCECustomPushNotRegistered;

/** Called when a custom action is opened by a user but is not registered in the application, but was previously registered in the application */
extern const MCENotificationName MCECustomPushNotYetRegistered;
