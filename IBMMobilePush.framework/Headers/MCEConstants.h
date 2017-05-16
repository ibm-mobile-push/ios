/* IBM Confidential
 * OCO Source Materials
 * 5725E28, 5725S01, 5725I03
 * © Copyright IBM Corp. 2014, 2016
 *
 * The source code for this program is not published or otherwise
 * divested of its trade secrets, irrespective of what has been
 * deposited with the U.S. Copyright Office.
 */

/** The MCEConstants header contains several important SDK integration constants */

/** The MCESdkVersion constant contains the current release number */
static NSString * const MCESdkVersion = @"3.6.6.0";

/** The RegisteredNotification message is sent via NSNotificationCenter when the SDK registers with the IBM servers */
static NSString * const RegisteredNotification = @"RegisteredNotification";

/** The RegistrationChangedNotification message is sent via NSNotificationCenter when the userId or channelId change durring the phone home process */
static NSString * const RegistrationChangedNotification = @"RegistrationChangedNotification";

/** The MCEEventSuccess message is sent via NSNotificationCenter when events are successfully sent to the server */
static NSString * const MCEEventSuccess = @"MCEEventSuccess";

/** The MCEEventSuccess message is sent via NSNotificationCenter when events fail to send to the server. No action is required by the developer, the system will automatically retry with back-off. */
static NSString * const MCEEventFailure = @"MCEEventFailure";

/** The SetUserAttributesError message is sent via NSNotificationCenter when Set User Attributes fails to send to the server. No action is required by the developer, the system will automatically retry with back-off. */
static NSString * const SetUserAttributesError = @"SetUserAttributesError";

/** The SetUserAttributesSuccess message is sent via NSNotificationCenter when Set User Attributes is successfully sent to the server */
static NSString * const SetUserAttributesSuccess = @"SetUserAttributesSuccess";

/** The UpdateUserAttributesError message is sent via NSNotificationCenter when Update User Attributes fails to send to the server. No action is required by the developer, the system will automatically retry with back-off. */
static NSString * const UpdateUserAttributesError = @"UpdateUserAttributesError";

/** The UpdateUserAttributesSuccess message is sent via NSNotificationCenter when Update User Attributes is successfully sent to the server */
static NSString * const UpdateUserAttributesSuccess = @"UpdateUserAttributesSuccess";

/** The DeleteUserAttributesError message is sent via NSNotificationCenter when Delete User Attributes fails to send to the server. No action is required by the developer, the system will automatically retry with back-off. */
static NSString * const DeleteUserAttributesError = @"DeleteUserAttributesError";

/** The DeleteUserAttributesSuccess message is sent via NSNotificationCenter when Delete User Attributes is successfully sent to the server */
static NSString * const DeleteUserAttributesSuccess = @"DeleteUserAttributesSuccess";

/** The SetChannelAttributesError message is sent via NSNotificationCenter when Set Channel Attributes fails to send to the server. No action is required by the developer, the system will automatically retry with back-off. */
static NSString * const SetChannelAttributesError = @"SetChannelAttributesError";

/** The SetChannelAttributesSuccess message is sent via NSNotificationCenter when Set Channel Attributes is successfully sent to the server */
static NSString * const SetChannelAttributesSuccess = @"SetChannelAttributesSuccess";

/** The UpdateChannelAttributesError message is sent via NSNotificationCenter when Update Channel Attributes fails to send to the server. No action is required by the developer, the system will automatically retry with back-off. */
static NSString * const UpdateChannelAttributesError = @"UpdateChannelAttributesError";

/** The UpdateChannelAttributesSuccess message is sent via NSNotificationCenter when Update Channel Attributes is successfully sent to the server */
static NSString * const UpdateChannelAttributesSuccess = @"UpdateChannelAttributesSuccess";

/** The DeleteChannelAttributesError message is sent via NSNotificationCenter when Delete Channel Attributes fails to send to the server. No action is required by the developer, the system will automatically retry with back-off. */
static NSString * const DeleteChannelAttributesError = @"DeleteChannelAttributesError";

/** The DeleteChannelAttributesSuccess message is sent via NSNotificationCenter when Delete Channel Attributes is successfully sent to the server */
static NSString * const DeleteChannelAttributesSuccess = @"DeleteChannelAttributesSuccess";

/** The Event type reported for simple notification actions */
static NSString * const SimpleNotificationSource = @"simpleNotification";

/** The Event type reported for inbox notification actions */
static NSString * const InboxSource = @"inboxMessage";

/** The Event type reported for inbox notification actions */
static NSString * const InAppSource = @"inAppMessage";

/** The LocationDatabaseReady message is sent when the location database is ready to be used. */
static NSString * const LocationDatabaseReady = @"LocationDatabaseReady";

static NSString * const LocationDatabaseUpdated = @"LocationDatabaseUpdated";

/* The EnteredGeofence message is sent when a geofence has been breached */
static NSString * const EnteredGeofence = @"EnteredGeofence";

/* The EnteredGeofence message is sent when a geofence has been left */
static NSString * const ExitedGeofence = @"ExitedGeofence";

/** The EnteredBeacon message is sent when a beacon region has been breached */
static NSString * const EnteredBeacon = @"EnteredBeacon";

/** The ExitedBeacon message is sent when a beacon region has been left */
static NSString * const ExitedBeacon = @"ExitedBeacon";

/** The DownloadedLocations message is sent when locations updates are downloaded from the server. */
static NSString * const DownloadedLocations = @"DownloadedLocations";

/** The ResetReferenceLocation message is sent when the reference location has changed. */
static NSString * const ResetReferenceLocation = @"ResetReferenceLocation";

/** The RefreshActiveGeofences message is sent when the active geofences have changed. */
static NSString * const RefreshActiveGeofences = @"RefreshActiveGeofences";
