/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2016, 2016
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

@import UIKit;
@import CoreLocation;
@import MapKit;

@interface GeofenceVC : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate>
@property IBOutlet MKMapView * mapView;
@property IBOutlet UIBarButtonItem * gpsButton;
-(IBAction)clickGpsButton:(id)sender;
-(IBAction)refresh:(id)sender;
@end
