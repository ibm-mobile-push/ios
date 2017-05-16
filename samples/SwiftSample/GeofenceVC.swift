/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2016, 2016
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

import UIKit
import MapKit

class GeofenceVC: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var gpsButton: UIBarButtonItem!
    @IBOutlet weak var status: UILabel!
    
    var locationManager: CLLocationManager
    var lastLocation: CLLocation?
    var followGPS: Bool = true
    var overlayIds: NSMutableSet = []
    var queue: DispatchQueue
    
    required init?(coder aDecoder: NSCoder) {
        locationManager = CLLocationManager()
        queue = DispatchQueue(label: "background")
        super.init(coder: aDecoder)
        locationManager.delegate = self
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("DownloadedLocations"), object: nil, queue: OperationQueue.main) { (note) in
            self.addGeofenceOverlaysNearCoordinate(coordinate: self.lastLocation!.coordinate, radius: 1000)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let config = MCESdk.sharedInstance().config;
        if(config!.geofenceEnabled)
        {
            status.text="ENABLED"
            status.textColor = UIColor.green
        }
        else
        {
            status.text="DISABLED"
            status.textColor = UIColor.red
        }
        
        createMonitor()
    }
    
    func createMonitor()
    {
        overlayIds = []
        let authStatus = CLLocationManager.authorizationStatus()
        if(authStatus == CLAuthorizationStatus.restricted || authStatus == CLAuthorizationStatus.denied)
        {
            NSLog("Not allowed to use location services, notify user?")
            return
        }
        
        locationManager.startUpdatingLocation()
        
        if(authStatus == CLAuthorizationStatus.notDetermined)
        {
            NSLog("Auth status unknown, asking user")
            locationManager.requestWhenInUseAuthorization()
        }
        
        if(!CLLocationManager.locationServicesEnabled())
        {
            NSLog("Location services is not enabled, notifiy user?")
            return
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        destroyMonitor()
    }
    
    func destroyMonitor()
    {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        overlayIds = []
        locationManager.stopUpdatingLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        followGPS=true
        updateGpsButton()
        let panRec = UIPanGestureRecognizer(target: self, action: #selector(didDragMap(gestureRecognizer:)))
        panRec.delegate=self
        mapView.addGestureRecognizer(panRec)
        mapView.showsUserLocation=true
        mapView.delegate=self
    }
    
    func didDragMap(gestureRecognizer: UIGestureRecognizer)
    {
        if(gestureRecognizer.state == UIGestureRecognizerState.ended)
        {
            followGPS=false
            updateGpsButton()
            let region = mapView.region
            let location = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)
            if lastLocation != nil || lastLocation!.distance(from: location) > 10
            {
                let north = CLLocation(latitude: region.center.latitude - region.span.latitudeDelta * 0.5, longitude: region.center.longitude)
                let south = CLLocation(latitude: region.center.latitude + region.span.latitudeDelta * 0.5, longitude: region.center.longitude)
                let metersLatitude = north.distance(from: south)
                
                let east = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude - region.span.longitudeDelta * 0.5)
                let west = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude + region.span.longitudeDelta * 0.5)
                let metersLongitude = east.distance(from: west)
                
                let maxMeters = max(metersLatitude, metersLongitude)
                addGeofenceOverlaysNearCoordinate(coordinate: location.coordinate, radius: maxMeters)
                lastLocation = location
            }
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }
    
    @IBAction func refresh(sender: AnyObject)
    {
        MCELocationClient().scheduleSync()
    }
    
    @IBAction func clickGpsButton(sender: AnyObject)
    {
        followGPS = !followGPS
        updateGpsButton()
    }
    
    func updateGpsButton()
    {
        if(followGPS)
        {
            gpsButton.tintColor = UIColor(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        }
        else
        {
            gpsButton.tintColor = UIColor(red: 0, green: 0.4784313725, blue: 1, alpha: 0.3)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        if(followGPS)
        {
            let region = MKCoordinateRegionMakeWithDistance(location!.coordinate, 1000, 1000)
            mapView.setRegion(region, animated: true)
        }
        
        if(lastLocation == nil || lastLocation!.distance(from: location!)>10)
        {
            addGeofenceOverlaysNearCoordinate(coordinate: location!.coordinate, radius: 1000)
            lastLocation = location
        }
    }
    
    func addGeofenceOverlaysNearCoordinate(coordinate: CLLocationCoordinate2D, radius: Double)
    {
        let r = min(radius, 10000)
        DispatchQueue.global().async {
            var overlays = [MKOverlay]()
            var annotations = [MKAnnotation]()
            let geofences = MCELocationDatabase.sharedInstance().geofencesNearCoordinate(coordinate, radius: r)
            for geofence in geofences!
            {
                if let geofence = geofence as? CLCircularRegion
                {
                    if !self.overlayIds.contains(geofence.identifier)
                    {
                        overlays.append(MKCircle(center: geofence.center, radius: geofence.radius))
                        self.overlayIds.add(geofence.identifier)
                        let annotation = MKPointAnnotation()
                        annotation.coordinate=geofence.center
                        annotation.title=geofence.identifier
                        annotation.subtitle=NSString(format: "Latitude %f, Longitude %f, Radius: %.1f", geofence.center.latitude, geofence.center.longitude, geofence.radius) as String
                        annotations.append(annotation)
                    }
                }
            }
            DispatchQueue.main.async {
                self.mapView.addOverlays(overlays)
                self.mapView.addAnnotations(annotations)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKCircleRenderer(overlay: overlay)
        renderer.fillColor = UIColor(red: 0, green: 0.4784313725, blue: 1, alpha: 0.1)
        renderer.strokeColor = UIColor(red: 0, green: 0.4784313725, blue: 1, alpha: 1.0)
        renderer.lineWidth = 1
        renderer.lineDashPattern = [2,2]
        return renderer
    }
}
