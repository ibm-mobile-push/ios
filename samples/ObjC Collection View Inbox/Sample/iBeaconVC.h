/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2016, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#if __has_feature(modules)
@import UIKit;
@import CoreLocation;
#else
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#endif

@interface iBeaconVC : UITableViewController <CLLocationManagerDelegate>
-(IBAction)refresh:(id)sender;
@end
