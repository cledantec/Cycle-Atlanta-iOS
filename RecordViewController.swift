//
//  RecordViewController.swift
//  Cycle Atlanta
//
//  Created by C. David Byrd on 2/3/17.
//  Copyright © 2107 Ga Tech. All rights reserved.
//
//

import UIKit
import MapKit

class RecordViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    // Reference to the actual MKMapView object from storyboard.
    @IBOutlet weak var mapView: MKMapView!
    
    // Strong reference to the location manager service and a history of the current trip coordinates.
    var locationManager = CLLocationManager()
    var userLocationTrace = Trip()
    
    let jsonStore = "tripData"
    
    let defaults = UserDefaults()
    
    var tmpI = 0
    
    // Initiate location services with high precision.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
        mapView.showsUserLocation = true
        mapView.mapType = MKMapType.standard
        
        locationManager.delegate = self
        
        locationManager.requestAlwaysAuthorization()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.allowDeferredLocationUpdates(untilTraveled: 100, timeout: 60)  // meters, seconds
        locationManager.startUpdatingLocation()
        
        // See if there is a stored trip to reload.
        //loadTrip()
        
        // Save trip every sixty seconds.
        Timer.scheduledTimer(
            timeInterval: 5.0, target: self, selector: #selector(RecordViewController.storeTrip),
            userInfo: nil, repeats: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Called when new location data is available (possibly with many updates at once).
        // Append the information to our internal coordinate trace.
        for loc in locations {
            userLocationTrace.coords.append(loc)
        }
        
        // Remove the user trace overlay, modify it, and add it back in.
        if mapView.overlays.count > 0 {
            // Currently assumes a single overlay.  This may need to change someday.
            mapView.remove(mapView.overlays[0])
        }
        
        // Extract CLLocationCoordinate2D array from CLLocation array.
        var coords = userLocationTrace.coords.map { $0.coordinate }
        
        // Draw overlay polyline from CLLocationCoordinate2D array.
        mapView.add(MKPolyline(coordinates: &coords, count: self.userLocationTrace.coords.count))
    }
    
    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        locationManager.allowDeferredLocationUpdates(untilTraveled: 100, timeout: 60)  // meters, seconds
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        // Called when an overlay needs to be drawn.  If it is our polyline user trace, set its render options.
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            
            polylineRenderer.strokeColor = UIColor.blue.withAlphaComponent(0.5)
            polylineRenderer.lineWidth = 7
            polylineRenderer.lineJoin = CGLineJoin.round
            polylineRenderer.lineCap = CGLineCap.round
            
            return polylineRenderer
        }
        
        return MKOverlayRenderer()
    }
    
    /*
     func loadTrip () {
     if let jsonData = defaults.stringForKey(jsonStore) {
     // Parse the json.
     //print ("Found: " + jsonData)
     
     var json : [String: AnyObject]!
     
     // Reconstruct the data somehow.
     do {
     json = try NSJSONSerialization.JSONObjectWithData(jsonData.dataUsingEncoding(NSUTF8StringEncoding)!, options: .AllowFragments) as? [String: AnyObject]
     } catch {
     print ("JSON reconstruction error: \(error)")
     }
     
     //print (json)
     self.userLocationTrace = Trip(json: json)!
     } else {
     print ("No trip data to load!")
     print ("\(defaults.dictionaryRepresentation())")
     self.userLocationTrace = Trip()
     }
     
     // Store the loaded (or new) trip.
     storeTrip()
     }
     */
    
    func storeTrip () {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.utility).async {
            self.tmpI += 1
            let intvl = Date()
            print ("Storing session " + String(self.tmpI))
            /*
             let dict = self.userLocationTrace.toJSON()
             print ("Trying to store dict \(dict)")
             if let jsonString = self.dictToNSString(dict) {
             print ("Converted \(jsonString)")
             self.defaults.setObject(jsonString, forKey: self.jsonStore)
             print ("Stored data: \(jsonString)")
             } else {
             print ("Failed dictToString for JSON \(dict)")
             }
             */
            self.userLocationTrace.storeCoords()
            let diff = intvl.timeIntervalSinceNow
            
            print ("Stored session " + String(self.tmpI) + ": " + String(diff))
        }
    }
    
    func dictToNSString (_ dict : JSON?) -> NSString? {
        do {
            let rawData = try JSONSerialization.data(withJSONObject: dict!, options: .prettyPrinted)
            let data = NSString(data: rawData, encoding: String.Encoding.utf8.rawValue)!
            //print ("Wrote JSON: \(data)")
            return data
        } catch {
            print("JSON serialization failed:  \(error)")
            return nil
        }
    }
    
    @IBAction func tapClearButton(_ sender: AnyObject) {
        userLocationTrace.clear()
        storeTrip()
        // Remove the user trace overlay, modify it, and add it back in.
        if mapView.overlays.count > 0 {
            // Currently assumes a single overlay.  This may need to change someday.
            mapView.remove(mapView.overlays[0])
        }
        
        // Extract CLLocationCoordinate2D array from CLLocation array.
        var coords = userLocationTrace.coords.map { $0.coordinate }
        
        // Draw overlay polyline from CLLocationCoordinate2D array.
        mapView.add(MKPolyline(coordinates: &coords, count: self.userLocationTrace.coords.count))
    }
    
}

