/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2016, 2016
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#import "MCENotificationService.h"

@interface MCENotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation MCENotificationService

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSLog(@"MCENotificationService: downloadTask: didFinishDownloadingToURL %@", location);
    NSError * error = nil;
    NSString * identifier = [[NSUUID UUID] UUIDString];
    NSURL * attachmentURL = [NSURL fileURLWithPathComponents:@[NSTemporaryDirectory(), downloadTask.originalRequest.URL.lastPathComponent]];
    self.bestAttemptContent.body = attachmentURL.absoluteString;
    [[NSFileManager defaultManager] copyItemAtURL:location toURL:attachmentURL error:&error];
    if(error)
    {
        NSLog(@"MCENotificationService: Copy Error: %@", [error localizedDescription]);
        self.contentHandler(self.bestAttemptContent);
        return;
    }
    UNNotificationAttachment * attachment = [UNNotificationAttachment attachmentWithIdentifier:identifier URL:attachmentURL options:@{} error:&error];
    if(error)
    {
        NSLog(@"MCENotificationService: Attachment Error: %@", [error localizedDescription]);
        self.contentHandler(self.bestAttemptContent);
        return;
    }
    self.bestAttemptContent.attachments=@[attachment];
    self.contentHandler(self.bestAttemptContent);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error;
{
    NSLog(@"MCENotificationService: didCompleteWithError: %@", [error localizedDescription]);
    self.contentHandler(self.bestAttemptContent);
}

-(void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    NSLog(@"MCENotificationService: didBecomeInvalidWithError: %@", [error localizedDescription]);
    self.contentHandler(self.bestAttemptContent);
}

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    NSURL * url = [NSURL URLWithString: request.content.userInfo[@"media-attachment"]];
    if(url)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"MCENotificationService: setting up download session: %@", url);
            NSURLSession * session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
            [[session downloadTaskWithURL:url] resume];
            NSLog(@"MCENotificationService: set up download session: %@", url);
        });
        return;
    }
    
    self.contentHandler(self.bestAttemptContent);
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    NSLog(@"MCENotificationService: Service time expired!");
    self.contentHandler(self.bestAttemptContent);
}

@end
