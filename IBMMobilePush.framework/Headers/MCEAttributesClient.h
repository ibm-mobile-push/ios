/* IBM Confidential
 * OCO Source Materials
 * 5725E28, 5725S01, 5725I03
 * © Copyright IBM Corp. 2014, 2014
 *
 * The source code for this program is not published or otherwise
 * divested of its trade secrets, irrespective of what has been
 * deposited with the U.S. Copyright Office.
 */

//
// Created by Feras on 7/11/13.
// Copyright (c) 2013 Xtify. All rights reserved.
//

@import Foundation;
#import "MCEClient.h"

/** The MCEAttributesClient class can be used to set, update, or delete user or channel attributes directly on the server. If an error occurs, you can resend the request, if desired; or, if you want the SDK to handle retries, use the MCEAttributesQueueManager class. */
@interface MCEAttributesClient : MCEClient

/** @name Channel Methods */

/** The setChannelAttributes method replaces channel attributes on the server with the specified set of attribute key value pairs. */
- (void)setChannelAttributes:(NSDictionary *)attributes completion:(void (^)(NSError * error))callback;

/** The updateChannelAttributes method adds or updates the specified attributes to the channel record on the server. */
- (void)updateChannelAttributes:(NSDictionary *)attributes completion:(void (^)(NSError * error))callback;

/** The deleteChannelAttributes method removes the specified keys from the channel record on the server. */
- (void)deleteChannelAttributes:(NSArray *)attributeKeys completion:(void (^)(NSError * error))callback;

/** @name User Methods */

/** The setUserAttributes method replaces the user attributes on the server with the specified set of attribute key value pairs. */
- (void)setUserAttributes:(NSDictionary *)attributes completion:(void (^)(NSError * error))callback;

/** The updateUserAttributes method adds or updates the specified attributes to the user record on the server. */
- (void)updateUserAttributes:(NSDictionary *)attributes completion:(void (^)(NSError * error))callback;

/** The deleteUserAttributes method removes the specified keys from the user record on the server. */
- (void)deleteUserAttributes:(NSArray *)attributeKeys completion:(void (^)(NSError * error))callback;

@end
