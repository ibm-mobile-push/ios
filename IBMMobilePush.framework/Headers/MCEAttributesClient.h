/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2014, 2018
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */


//
// Created by Feras on 7/11/13.
// Copyright (c) 2013 Xtify. All rights reserved.
//

#if __has_feature(modules)
@import Foundation;
#else
#import <Foundation/Foundation.h>
#endif

#import "MCEClient.h"

/** The MCEAttributesClient class can be used to update, or delete user attributes directly on the server. 
 
 Please note, this class is deprecated, please use MCEAttributesQueueManager instead.
 */

__attribute__ ((deprecated))
@interface MCEAttributesClient : NSObject

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
