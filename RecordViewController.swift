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
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var discardTripButton: UIButton!
    
    // Core Data managed object context.
    var appDelegate = UIApplication.shared.delegate as! CycleAtlantaAppDelegate
    var context : NSManagedObjectContext?

    // Reference to the tripView view (presents UI for trip types).
    @IBOutlet weak var tripView: UIView!
    
    // Top stats display.
    @IBOutlet weak var speedCounter: UILabel!
    
    // Strong reference to the location manager service and a history of the current trip coordinates.
    var locationManager = CLLocationManager()
    var userLocationTrace = TripPath()
    
    // Trip manager (legacy).
    var tripManager = TripManager()
    
    // Trip in progress flag.
    var tripInProgress = false
    
    // Key name to local JSON store for coordinate path.
    let jsonStore = "tripPathData"
    
    // Reference to iOS user defaults store.
    let defaults = UserDefaults()
    
    // Debug variable for storing coordinates and testing.
    var tmpI = 0
    
    // Holds selected trip type during save dialog.
    var selectedTripType = 7    // other
    
    // Initiate location services with high precision.
    override func viewDidLoad() {
        context = appDelegate.managedObjectContext
        tripManager = TripManager.init(managedObjectContext: context)
        
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
        
        // Get a fresh TripManager.
        tripManager.dirty = true
        tripManager.parent = self
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Called when new location data is available (possibly with many updates at once).
        // Append the information to our internal coordinate trace.
        
        // Update speed display whether recording or not.
        if let currentSpeed = locations.last?.speed {
            speedCounter.text = String.localizedStringWithFormat("%.1f mph", currentSpeed * 3600 / 1609.344)
        } else {
            speedCounter.text = "0.0 mph"
        }
        
        // Remaining logic runs only during a recording.
        if !tripInProgress { return }
        
        for loc in locations {
            userLocationTrace.coords.append(loc)
            tripManager.addCoord(loc)
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
    
    @IBAction func tapStartButton(_ sender: AnyObject) {
        // Hide the start button and show the stop button.
        startButton.isHidden = true
        stopButton.isHidden = false
        continueButton.isHidden = true
        discardTripButton.isHidden = true
        
        tripView.isHidden = true
        
        // Clear any cached data from a previous trip.
        userLocationTrace.clear()
        storeTrip()
        
        tripInProgress = true
        
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
    
    @IBAction func tapSaveButton(_ sender: AnyObject) {
        // Ask about saving the trip.
        
        // For now, just redisplay the start button.
        startButton.isHidden = true
        stopButton.isHidden = true
        continueButton.isHidden = false
        discardTripButton.isHidden = false
        
        tripView.isHidden = false
    }
    
    @IBAction func tapContinueButton(_ sender: Any) {
        // Keep recording after all.
        startButton.isHidden = true
        stopButton.isHidden = false
        continueButton.isHidden = true
        discardTripButton.isHidden = true
        
        tripView.isHidden = true
    }

    @IBAction func tapDiscardTripButton(_ sender: Any) {
        // Toss the trip and stop recording.
        startButton.isHidden = false
        stopButton.isHidden = true
        continueButton.isHidden = true
        discardTripButton.isHidden = true
        
        tripView.isHidden = true
        
        tripInProgress = false
    }
    
    @IBAction func saveTrip(_ sender: UIButton) {
        var title = ""
        var message = ""
        var tripType = 0
        
        switch (sender.tag) {
        case 1:
            title = "Exercise"
            message = LocalizedMessages.TRIP_EXERCISE
            tripType = 3
        case 2:
            title = "Other"
            message = LocalizedMessages.TRIP_OTHER
            tripType = 7
        case 3:
            title = "Social"
            message = LocalizedMessages.TRIP_SOCIAL
            tripType = 4
        case 4:
            title = "Commute"
            message = LocalizedMessages.TRIP_COMMUTE
            tripType = 0
        case 5:
            title = "Work"
            message = LocalizedMessages.TRIP_WORK
            tripType = 2
        case 6:
            title = "Errand"
            message = LocalizedMessages.TRIP_ERRAND
            tripType = 6
        default:
            title = "Other"
            message = LocalizedMessages.TRIP_OTHER
            tripType = 7
            
        }
        
        self.selectedTripType = tripType
        
        print (title, message, tripType)
        
        // Display the alert request for saving immediately or adding a note.
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { action in
            self.uploadTrip()
            self.startButton.isHidden = false
        }
        let noteAction = UIAlertAction(title: "Add Details", style: .default) { action in
            print(action)
        }

        alert.addAction(saveAction)
        alert.addAction(noteAction)
        
        present(alert, animated: true, completion: nil)

        // And hide the other buttons.
        startButton.isHidden = true
        stopButton.isHidden = true
        continueButton.isHidden = true
        discardTripButton.isHidden = true
        
        tripView.isHidden = true
        
        // And definitely end the trip now that they have chosen to save a trip category.
        tripInProgress = false
        
    }
    
    func uploadTrip () {
        let purpose = self.selectedTripType
        tripManager.setPurpose(UInt32(purpose))
        tripManager.saveTrip()
    }
    
}

