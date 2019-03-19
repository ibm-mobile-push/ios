/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2016, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#import "NotificationService.h"
#import <IBMMobilePushNotificationService/IBMMobilePushNotificationService.h>

@implementation NotificationService

-(instancetype)init {
    NSDictionary * config = @{
                              @"baseUrl": @"https://sdk.ibm.xtify.com",
                              @"appKey": @{
                                      @"dev":  @"INSERT DEV APPKEY HERE",
                                      @"prod": @"INSERT PROD APPKEY HERE"
                                      },
                              @"autoReinitialize": @YES,
                              @"invalidateExistingUser": @NO,
                              @"location": @{
                                      @"autoInitialize": @YES,
                                      @"sync": @{
                                              @"syncRadius": @100000,
                                              @"syncInterval": @300
                                              },
                                      @"geofence": @{
                                              @"accuracy": @"3km"
                                              },
                                      @"ibeacon": @{
                                              @"UUID": @"SET YOUR IBEACON UUID HERE"
                                              }
                                      },
                              @"autoInitialize": @YES,
                              @"sessionTimeout": @20,
                              @"loglevel": @"verbose",
                              @"logfile": @YES,
                              @"watch": @{
                                      @"category": @"mce-watch-category",
                                      @"handoff": @{
                                              @"userActivityName": @"com.mce.application",
                                              @"interfaceController": @"handoff"
                                              }
                                      }
                              };
    
    [MCEConfig sharedInstanceWithDictionary: config];
    return [super init];
}


@end
