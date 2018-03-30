/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2017, 2018
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */


#if __has_feature(modules)
@import Foundation;
@import CoreLocation;
#else
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#endif

/** The MCEArea class represents a geographic area. */
@interface MCEArea : NSObject

/** radius represents the size of the geographic area from the center to edge in meters */
@property double radius;

/** latitude represents the latitude at the center of the geographic area */
@property (readonly) double latitude;

/** longitude represents the longitude at the center of the geographic area */
@property (readonly) double longitude;

/** coordinate represents the center point of the geographic area */
@property (readonly) CLLocationCoordinate2D coordinate;

@end
