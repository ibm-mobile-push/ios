/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2016, 2018
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */


#if __has_feature(modules)
@import Foundation;
@import UIKit;
#else
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#endif

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
-(BOOL)handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler;

/** This method schedules a sync to the server. */
-(void)scheduleSync;

@end
