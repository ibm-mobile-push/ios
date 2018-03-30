/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2017, 2018
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */


#if __has_feature(modules)
@import WatchKit;
#else
#import <WatchKit/WatchKit.h>
#endif

@interface MCENotificationInterfaceController : WKUserNotificationInterfaceController

@property (weak, nonatomic) IBOutlet WKInterfaceImage *headerImage;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *titleLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceMap *mapView;
@property (weak, nonatomic) IBOutlet WKInterfaceGroup *backgroundGroup;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *bodyLabel;

@end
