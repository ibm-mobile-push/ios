/* IBM Confidential
 * OCO Source Materials
 * 5725E28, 5725S01, 5725I03
 * © Copyright IBM Corp. 2016, 2016
 *
 * The source code for this program is not published or otherwise
 * divested of its trade secrets, irrespective of what has been
 * deposited with the U.S. Copyright Office.
 */

@import Foundation;
@import UIKit;
#import "MCEClient.h"

/**
 The MCELocationClient syncronizes geofences and iBeacons to montior with the server.
 */
@interface MCELocationClient : MCEClient  <NSURLSessionDelegate, NSURLSessionDownloadDelegate>

/** Fetch completion handler to be executed after sync. */
@property (nonatomic, copy) void (^fetchCompletionHandler)(UIBackgroundFetchResult);

/**
 This method handles the background download of the location updates from the server.
 
 @param identifier is passed from the application delegate callback.
 @param completionHandler is passed from the application delegate callback.
 */
-(BOOL)handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler;

/** This method schedules a sync to the server. */
-(void)scheduleSync;

@end
