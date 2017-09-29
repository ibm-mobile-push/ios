/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2016, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

#import "GeofenceVC.h"
#import <IBMMobilePush/IBMMobilePush.h>

@interface GeofenceVC ()
@property CLLocationManager * locationManager;
@property CLLocation * lastLocation;
@property BOOL followGPS;
@property NSMutableSet * overlayIds;
@property dispatch_queue_t queue;
@property NSMutableDictionary * circleToIdentifier;
@end

@implementation GeofenceVC
-(void)awakeFromNib
{
    [super awakeFromNib];
    self.queue = dispatch_queue_create("background", nil);
}

-(IBAction)enable:(id)sender
{
    [MCESdk.sharedInstance manualLocationInitialization];
}

-(void)updateStatus
{
    MCEConfig* config = [[MCESdk sharedInstance] config];
    if(config.geofenceEnabled)
    {
        switch(CLLocationManager.authorizationStatus)
        {
            case kCLAuthorizationStatusDenied:
                [self.status setTitle:@"DENIED" forState:UIControlStateNormal];
                [self.status setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                break;
            case kCLAuthorizationStatusNotDetermined:
                [self.status setTitle:@"DELAYED (Touch to enable)" forState:UIControlStateNormal];
                [self.status setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                break;
            case kCLAuthorizationStatusAuthorizedAlways:
                [self.status setTitle:@"ENABLED" forState:UIControlStateNormal];
                [self.status setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
                break;
            case kCLAuthorizationStatusRestricted:
                [self.status setTitle:@"RESTRICTED?" forState:UIControlStateNormal];
                [self.status setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];

                break;
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                [self.status setTitle:@"ENABLED WHEN IN USE" forState:UIControlStateNormal];
                [self.status setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                break;
        }
    }
    else
    {
        [self.status setTitle:@"DISABLED" forState:UIControlStateNormal];
        [self.status setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self createMonitor];
    [self updateStatus];
}

// TODO remove monitor when app not in foreground?
-(void)createMonitor
{
    self.overlayIds = [NSMutableSet set];
    self.circleToIdentifier = [NSMutableDictionary dictionary];
    
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self destroyMonitor];
}
-(void)destroyMonitor
{
    [self.mapView removeOverlays: self.mapView.overlays];
    self.overlayIds = nil;
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;
    self.locationManager = nil;
}

-(IBAction)refresh:(id)sender
{
    [[[MCELocationClient alloc] init] scheduleSync];
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    self.followGPS=TRUE;
    [self updateGpsButton];
    UIPanGestureRecognizer* panRec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didDragMap:)];
    [panRec setDelegate:self];
    [self.mapView addGestureRecognizer:panRec];
    
    self.mapView.showsUserLocation = TRUE;
    self.mapView.delegate=self;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"RefreshActiveGeofences" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [self addGeofenceOverlaysNearCoordinate:self.lastLocation.coordinate radius:1000];
        NSArray * overlays = self.mapView.overlays;
        [self.mapView removeOverlays:overlays];
        [self.mapView addOverlays:overlays];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"DownloadedLocations" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        
        [self addGeofenceOverlaysNearCoordinate: self.lastLocation.coordinate radius:1000];
    }];
}

- (void)didDragMap:(UIGestureRecognizer*)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        self.followGPS=FALSE;
        [self updateGpsButton];
        
        MKCoordinateRegion region = self.mapView.region;
        CLLocation * location = [[CLLocation alloc]initWithLatitude: region.center.latitude longitude: region.center.longitude];
        
        if(self.lastLocation==nil || [self.lastLocation distanceFromLocation:location] > 10)
        {
            //get latitude in meters
            CLLocation * north = [[CLLocation alloc] initWithLatitude:(region.center.latitude - region.span.latitudeDelta * 0.5) longitude:region.center.longitude];
            CLLocation * south = [[CLLocation alloc] initWithLatitude:(region.center.latitude + region.span.latitudeDelta * 0.5) longitude:region.center.longitude];
            double metersLatitude = [north distanceFromLocation:south];
            
            //get longitude in meters
            CLLocation * east = [[CLLocation alloc] initWithLatitude:region.center.latitude longitude:(region.center.longitude - region.span.longitudeDelta * 0.5)];
            CLLocation * west = [[CLLocation alloc] initWithLatitude:region.center.latitude longitude:(region.center.longitude + region.span.longitudeDelta * 0.5)];
            double metersLongitude = [east distanceFromLocation:west];
            
            double maxMeters = MAX(metersLatitude, metersLongitude);
            
            [self addGeofenceOverlaysNearCoordinate: location.coordinate radius:maxMeters];
            self.lastLocation = location;
        }
        
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

-(IBAction)clickGpsButton:(id)sender
{
    self.followGPS = !self.followGPS;
    [self updateGpsButton];
}

-(void)updateGpsButton
{
    if(self.followGPS)
        self.gpsButton.tintColor=[UIColor colorWithRed:0 green:0.4784313725 blue:1 alpha:1];
    else
        self.gpsButton.tintColor=[UIColor colorWithRed:0 green:0.4784313725 blue:1 alpha:0.3];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation * location = locations.lastObject;
    if(self.followGPS)
    {
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location.coordinate, 1000, 1000);
        [self.mapView setRegion:region animated:TRUE];
    }
    
    if(self.lastLocation==nil || [self.lastLocation distanceFromLocation:location] > 10)
    {
        [self addGeofenceOverlaysNearCoordinate:location.coordinate radius:1000];
        self.lastLocation = location;
    }
}

-(void)addGeofenceOverlaysNearCoordinate: (CLLocationCoordinate2D) coordinate radius: (double) radius
{
    // This is only needed because the mapkit system blows up when there are too many overlays and annotations
    radius = MIN(radius, 10000);
    dispatch_async(self.queue, ^(void){
        NSMutableArray * additionalOverlays = [NSMutableArray array];
        NSMutableArray * removeOverlays = [NSMutableArray array];
        NSMutableSet * geofences = [[MCELocationDatabase sharedInstance] geofencesNearCoordinate:coordinate radius:radius];
        NSMutableSet * currentOverlayRefs = [NSMutableSet set];
        for (MCEGeofence * geofence in geofences) {
            NSDictionary * reference = @{@"latitude": @(geofence.latitude), @"latitude": @(geofence.latitude), @"radius": @(geofence.radius)};
            [currentOverlayRefs addObject:reference];

            if(![self.overlayIds containsObject:geofence.locationId])
            {
                self.circleToIdentifier[reference] = geofence.locationId;
                [additionalOverlays addObject:[MKCircle circleWithCenterCoordinate:geofence.coordinate radius:geofence.radius]];
                [self.overlayIds addObject:geofence.locationId];
            }
        }
        
        for(MKCircle * overlay in self.mapView.overlays)
        {
            NSDictionary * reference = @{@"latitude": @(overlay.coordinate.latitude), @"latitude": @(overlay.coordinate.longitude), @"radius": @(overlay.radius)};
            if(![currentOverlayRefs containsObject:reference])
                [removeOverlays addObject: overlay];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            NSLog(@"additional: %@", additionalOverlays);
            [self.mapView addOverlays: additionalOverlays];
            NSLog(@"remove: %@", removeOverlays);
            [self.mapView removeOverlays: removeOverlays];
        });
        
    });
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    BOOL active = false;
    if([overlay isKindOfClass:[MKCircle class]])
    {
        MKCircle * circle = (MKCircle *)overlay;
        
        NSString * identifier = self.circleToIdentifier[@{@"latitude": @(circle.coordinate.latitude), @"latitude": @(circle.coordinate.latitude), @"radius": @(circle.radius)}];
        
        if(identifier)
        {
            for (CLRegion * region in self.locationManager.monitoredRegions) {
                if([region.identifier isEqual: identifier])
                {
                    active=true;
                }
            }
        }
    }
    MKCircleRenderer * renderer = [[MKCircleRenderer alloc] initWithCircle: overlay];
    
    if(active)
    {
        renderer.fillColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.1];
        renderer.strokeColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1.0];
    }
    else
    {
        renderer.fillColor = [UIColor colorWithRed:0 green:0.4784313725 blue:1 alpha:0.1];
        renderer.strokeColor = [UIColor colorWithRed:0 green:0.4784313725 blue:1 alpha:1.0];
    }
    renderer.lineWidth = 1;
    renderer.lineDashPattern = @[ @(2), @(2) ];
    return renderer;
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    [self updateStatus];
}

@end
