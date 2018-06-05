//
//  ViewController.swift
//  LocationTracker
//
//  Created by Razvan Julian on 31/05/2018.
//  Copyright © 2018 Razvan Julian. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import SnapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var map: MKMapView!
    @IBOutlet var trackBarButton: UIBarButtonItem!
    @IBOutlet var restartBarButton: UIBarButtonItem!
    @IBOutlet var addBarButton: UIBarButtonItem!
    @IBOutlet var listBarButton: UIBarButtonItem!
    
    let locationManager = CLLocationManager()
    var initialLocation = CLLocationCoordinate2D()
    var locationsArray = [CLLocationCoordinate2D]()
    
    var isTracking = Bool()
    
    var polyline: MKPolyline?
    var accuracyRangeCircle: MKCircle?
    
    var currentTime = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
            
        self.view.addSubview(map)
            
        self.map.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
            
        self.map.delegate = self
        self.map.showsUserLocation = true
        self.map.showsCompass = true
        self.map.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
            
        self.accuracyRangeCircle = MKCircle(center: CLLocationCoordinate2D(latitude: initialLocation.latitude, longitude: initialLocation.longitude), radius: 50)
        self.map.add(self.accuracyRangeCircle!)
            
        self.isTracking = true
     
        self.navigationItem.title = "Tracking in ON"
                
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.allowsBackgroundLocationUpdates = true
        
        if #available(iOS 11.0, *) {
            self.locationManager.showsBackgroundLocationIndicator = true
        }
        
        self.locationManager.startUpdatingLocation()
            
        self.isTracking = true
            
        if self.locationManager.location?.coordinate != nil{
            self.initialLocation = (self.locationManager.location?.coordinate)!
        }
  
        self.polyline = MKPolyline(coordinates: locationsArray, count: locationsArray.count)
        self.map.add(polyline as! MKOverlay)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        if activePlace != -1 {
            
            if places.count > activePlace {
                
                self.isTracking = false
                
                self.navigationItem.title = "Route"
                
                self.trackBarButton.image = UIImage(named: "navigation-off")
        
                self.locationManager.allowsBackgroundLocationUpdates = false
                self.locationManager.stopUpdatingLocation()
                
                self.polyline = nil
                
                self.locationsArray.removeAll()
                
                self.map.removeOverlays(map.overlays)
                self.map.removeAnnotations(map.annotations)
                            
                if let title = places[activePlace]["title"] {
                
                    let locations = places[activePlace]["locations"] as! [CLLocationCoordinate2D]
        
                    let sourceLocation = locations.first
                    let destinationLocation = locations.last

                    let sourcePlacemark = MKPlacemark(coordinate: sourceLocation!, addressDictionary: nil)
                    let destinationPlacemark = MKPlacemark(coordinate: destinationLocation!, addressDictionary: nil)
        
                    let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
                    let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
                    let sourceAnnotation = MKPointAnnotation()
                    sourceAnnotation.title = "Source"
        
                    if let location = sourcePlacemark.location {
                        sourceAnnotation.coordinate = location.coordinate
                    }
        
                    let destinationAnnotation = MKPointAnnotation()
                    destinationAnnotation.title = "Destination"
        
                    if let location = destinationPlacemark.location {
                        destinationAnnotation.coordinate = location.coordinate
                    }
        
                    self.map.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true)
        
                    let directionRequest = MKDirectionsRequest()
                    directionRequest.source = sourceMapItem
                    directionRequest.destination = destinationMapItem
                    directionRequest.transportType = .automobile
        
                    // Calculate the direction
                    let directions = MKDirections(request: directionRequest)
        
                    directions.calculate {
                        (response, error) -> Void in
        
                        guard let response = response else {
                        if let error = error {
                            print("Error: \(error)")
                        }
                            
                        return
                    }
                        
                        let route = response.routes[0]
                        self.map.add((route.polyline), level: MKOverlayLevel.aboveRoads)
            
                        let rect = route.polyline.boundingMapRect
                        self.map.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
                    
                        self.map.fitMapViewToAnnotaionList()
                    }
                }
            }
        }
        
    }
    

    @IBAction func trackAction(_ sender: UIBarButtonItem) {
        
        if activePlace == -1 {
            
            if isTracking {
                
                self.navigationItem.title = "Tracking is OFF"
                self.trackBarButton.image = UIImage(named: "navigation-off")
                self.locationManager.allowsBackgroundLocationUpdates = false
                self.locationManager.stopUpdatingLocation()
            
            } else {
                
                self.navigationItem.title = "Tracking is ON"
                self.trackBarButton.image = UIImage(named: "navigation-on")
                self.locationManager.startUpdatingLocation()
            }
            
            isTracking = !isTracking
            
        } else {
            
            self.cleanMap()
            self.navigationItem.title = "Tracking is ON"
            self.trackBarButton.image = UIImage(named: "navigation-on")
            self.locationManager.startUpdatingLocation()
            self.isTracking = true
        }
        
    }
    
    
    @IBAction func restartAction(_ sender: UIBarButtonItem) {
        
        if activePlace != -1 {
            self.navigationItem.title = "Current Location"
        }
        
        cleanMap()
    }
    
    
    func cleanMap() {
        
        activePlace = -1
        self.polyline = nil
        self.locationsArray.removeAll()
        self.map.removeOverlays(map.overlays)
        self.map.removeAnnotations(map.annotations)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: (self.locationManager.location?.coordinate)!, span: span)
        self.map.setRegion(region, animated: true)
    }
    
    
    @IBAction func addAction(_ sender: UIBarButtonItem) {
        
        if activePlace == -1 {
            
            if locationsArray.count > 0 {
            
                getCurrentTime()
                
                let location = CLLocation(latitude: locationsArray[0].latitude, longitude: locationsArray[0].longitude)
                
                CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                    
                    var title = ""
                    
                    if error != nil {
                        
                        print(error!)
                        
                    } else {
                        
                        if let placemark = placemarks?[0] {
                            
                            if placemark.subThoroughfare != nil {
                                
                                title += placemark.subThoroughfare! + " "
                            }
                            
                            if placemark.thoroughfare != nil {
                                
                                title += placemark.thoroughfare!
                            }
                        }
                    }
                    
                    if title == "" {
                        
                        title = "The location title is not accurate."
                    }
                    
                    if places.count == 1 && places[0].count == 0 {
                        places.remove(at: 0)
                    }
                    
                    
                    places.append(["title": title, "latitude": String(location.coordinate.latitude), "longitude": String(location.coordinate.longitude), "locations": (self.locationsArray), "time": String(self.currentTime)])
                })
                
            } else {
                
                alert(title: "There's no location recorded.", message: "Please turn on the tracking mode to let the app record your location.")
            }
            
        } else {
            
            alert(title: "There's no location recorded.", message: "Please turn on the tracking mode to let the app record your location.")
        }
    }
    
    
    @IBAction func listAction(_ sender: UIBarButtonItem) {
        
        self.performSegue(withIdentifier: "listSegue", sender: nil)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        
        self.locationsArray.append(location)
        self.polyline = MKPolyline(coordinates: locationsArray, count: locationsArray.count)
        
        self.map.setRegion(region, animated: true)
        self.map.add(polyline as! MKOverlay)
    }
 
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay === self.accuracyRangeCircle{
            let circleRenderer = MKCircleRenderer(circle: overlay as! MKCircle)
            circleRenderer.fillColor = UIColor(white: 0.0, alpha: 0.25)
            circleRenderer.lineWidth = 0
            return circleRenderer
            
        } else {
            
            let polylineRenderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
            polylineRenderer.strokeColor = UIColor(rgb:0x1b60fe)
            polylineRenderer.alpha = 0.5
            polylineRenderer.lineWidth = 5.0
            return polylineRenderer
        }
        
    }
    

    func alert(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
//        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
//            let settingsURL = URL(string: UIApplicationOpenSettingsURLString)
//            if let url = settingsURL {
//                UIApplication.shared.open(url, options: [:], completionHandler: nil)
//            }
//        }
//
//        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
//
//        alertController.addAction(settingsAction)
//        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func getCurrentTime() {
        
        let date = Date()
        let calender = Calendar.current
        let components = calender.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
        
        let year = components.year
        let month = components.month
        let day = components.day
        let hour = components.hour
        let minute = components.minute
        let second = components.second
        
        currentTime = String(day!) + "." + String(month!) + "." + String(year!) + " " + String(hour!)  + ":" + String(minute!) + ":" +  String(second!)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        if (error as NSError).domain == kCLErrorDomain && (error as NSError).code == CLError.Code.denied.rawValue{
            // If user denied your app access to location information.
            self.alert(title: "Please turn on the Location Services", message: "To use location tracking feature of the app, please turn on the location service from the Settings app.")
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

extension MKMapView {
    
    func fitMapViewToAnnotaionList() -> Void {
        
        let mapEdgePadding = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        var zoomRect:MKMapRect = MKMapRectNull
        
        for index in 0..<self.annotations.count {
            
            let annotation = self.annotations[index]
            let aPoint:MKMapPoint = MKMapPointForCoordinate(annotation.coordinate)
            let rect:MKMapRect = MKMapRectMake(aPoint.x, aPoint.y, 0.1, 0.1)
            
            if MKMapRectIsNull(zoomRect) {
                zoomRect = rect
            } else {
                zoomRect = MKMapRectUnion(zoomRect, rect)
            }
            
        }
        
        self.setVisibleMapRect(zoomRect, edgePadding: mapEdgePadding, animated: true)
    }
    
}


extension UIColor {
    
    convenience init(rgb: UInt) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
}

