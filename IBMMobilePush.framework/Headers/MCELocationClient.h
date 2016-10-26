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

@interface MCELocationClient : MCEClient  <NSURLSessionDelegate, NSURLSessionDownloadDelegate>
@property (nonatomic, copy) void (^completionHandler)();
@property (nonatomic, copy) void (^fetchCompletionHandler)(UIBackgroundFetchResult);
-(BOOL)handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler;
-(void)scheduleSync;
@end
