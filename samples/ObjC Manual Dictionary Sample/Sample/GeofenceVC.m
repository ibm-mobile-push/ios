/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2016, 2019
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
    self.status.accessibilityIdentifier=@"status";
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

-(void)createMonitor
{
    self.overlayIds = [NSMutableSet set];
    self.circleToIdentifier = [NSMutableDictionary dictionary];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.locationManager = [[CLLocationManager alloc]init];
        self.locationManager.delegate = self;
        [self.locationManager startUpdatingLocation];
    });
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
        [self addGeofenceOverlaysNearCoordinate:self.lastLocation.coordinate radius:100000];
        NSArray * overlays = self.mapView.overlays;
        [self.mapView removeOverlays:overlays];
        [self.mapView addOverlays:overlays];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"DownloadedLocations" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        
        [self addGeofenceOverlaysNearCoordinate: self.lastLocation.coordinate radius:100000];
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
        
        [self addGeofenceOverlaysNearCoordinate: location.coordinate radius:100000];
        self.lastLocation = location;
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

        if(self.lastLocation==nil || [self.lastLocation distanceFromLocation:location] > 10)
        {
            [self addGeofenceOverlaysNearCoordinate:location.coordinate radius:10000];
            self.lastLocation = location;
        }
    }
}

-(void)addGeofenceOverlaysNearCoordinate: (CLLocationCoordinate2D) coordinate radius: (double) radius
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        NSMutableArray * additionalOverlays = [NSMutableArray array];
        NSMutableArray * removeOverlays = [NSMutableArray array];
        NSMutableSet * geofences = [[MCELocationDatabase sharedInstance] geofencesNearCoordinate:coordinate radius:radius];
        
        NSMutableSet * currentlyDisplayedIds = [NSMutableSet set];
        for(MKCircle * overlay in self.mapView.overlays) {
            [currentlyDisplayedIds addObject:overlay.title];
        }
        
        NSMutableSet * currentGeofenceIds = [NSMutableSet set];
        for (MCEGeofence * geofence in geofences) {
            [currentGeofenceIds addObject: geofence.locationId];
            if( ![currentlyDisplayedIds containsObject: geofence.locationId] ) {
                MKCircle * circle = [MKCircle circleWithCenterCoordinate:geofence.coordinate radius:geofence.radius];
                circle.title = geofence.locationId;
                [additionalOverlays addObject: circle];
            }
        }
        
        for(MKCircle * overlay in self.mapView.overlays) {
            if(![currentGeofenceIds containsObject:overlay.title]) {
                [removeOverlays addObject:overlay];
            }
        }
        
        [self.mapView removeOverlays: removeOverlays];
        [self.mapView addOverlays: additionalOverlays];
    });
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    BOOL active = false;
    if([overlay isKindOfClass:[MKCircle class]])
    {
        MKCircle * circle = (MKCircle *)overlay;
        
        NSString * identifier = circle.title;
        
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

