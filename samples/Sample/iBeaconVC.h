/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2016, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

@import UIKit;
@import CoreLocation;

@interface iBeaconVC : UITableViewController <CLLocationManagerDelegate>
-(IBAction)refresh:(id)sender;
@end
