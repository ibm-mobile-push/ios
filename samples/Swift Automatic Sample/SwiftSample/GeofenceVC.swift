/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2016, 2017
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

import UIKit
import MapKit

class GeofenceVC: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var gpsButton: UIBarButtonItem!
    @IBOutlet weak var status: UIButton!
    
    var locationManager: CLLocationManager?
    var lastLocation: CLLocation?
    var followGPS: Bool = true
    var overlayIds: NSMutableSet = []
    var queue = DispatchQueue(label: "background")
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        DispatchQueue.main.async {
            self.locationManager = CLLocationManager()
            self.locationManager!.delegate = self
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("DownloadedLocations"), object: nil, queue: OperationQueue.main) { (note) in
            self.addGeofenceOverlaysNearCoordinate(coordinate: self.lastLocation!.coordinate, radius: 1000)
        }
    }
    
    func updateStatus()
    {
        let config = MCESdk.sharedInstance().config;
        if(config!.geofenceEnabled)
        {
            switch(CLLocationManager.authorizationStatus())
            {
            case .denied:
                status.setTitle("DENIED", for: .normal)
                status.setTitleColor(.red, for: .normal)
                break
            case .notDetermined:
                status.setTitle("DELAYED (Touch to enable)", for: .normal)
                status.setTitleColor(.gray, for: .normal)
                break
            case .authorizedAlways:
                status.setTitle("ENABLED", for: .normal)
                status.setTitleColor(.green, for: .normal)
                break
            case .restricted:
                status.setTitle("RESTRICTED?", for: .normal)
                status.setTitleColor(.gray, for: .normal)
                break
            case .authorizedWhenInUse:
                status.setTitle("ENABLED WHEN IN USE", for: .normal)
                status.setTitleColor(.gray, for: .normal)
                break
            }
        }
        else
        {
            status.setTitle("DISABLED", for: .normal)
            status.setTitleColor(.red, for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStatus()
        createMonitor()
    }
    
    func createMonitor()
    {
        overlayIds = []
        if let locationManager = locationManager
        {
            locationManager.startUpdatingLocation()
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
        if let locationManager = locationManager
        {
            locationManager.stopUpdatingLocation()
        }
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
    
    @objc func didDragMap(gestureRecognizer: UIGestureRecognizer)
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
    
    @IBAction func enable(sender: AnyObject)
    {
        MCESdk.sharedInstance().manualLocationInitialization()
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
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        updateStatus()
    }
}


