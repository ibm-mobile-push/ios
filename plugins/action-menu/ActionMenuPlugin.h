/* IBM Confidential
 * OCO Source Materials
 * 5725E28, 5725S01, 5725I03
 * © Copyright IBM Corp. 2014, 2016
 *
 * The source code for this program is not published or otherwise
 * divested of its trade secrets, irrespective of what has been
 * deposited with the U.S. Copyright Office.
 */

#import <Foundation/Foundation.h>
#import <IBMMobilePush/IBMMobilePush.h>

@interface ActionMenuPlugin : NSObject <MCEActionProtocol>

+ (instancetype)sharedInstance;
-(void)showActionsMenu:(NSDictionary*)action withPayload:(NSDictionary*)userInfo;
+(void)registerPlugin;

@end
