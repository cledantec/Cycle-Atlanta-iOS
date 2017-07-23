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

class RecordViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, TripDetailsDelegate, NoteDetailsDelegate {
    
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
    @IBOutlet weak var noteButton: UIButton!
    @IBOutlet weak var tripView: UIView!
    
    // Reference to the noteView view (presents UI for note types).
    @IBOutlet weak var noteView: UIView!
    
    // Top stats display.
    @IBOutlet weak var speedCounter: UILabel!
    @IBOutlet weak var distanceCounter: UILabel!
    @IBOutlet weak var timeCounter: UILabel!
    
    // Strong reference to the location manager service and a history of the current trip coordinates.
    var locationManager = CLLocationManager()
    var userLocationTrace = TripPath()
    
    // Trip manager (legacy).
    var tripManager = TripManager()
    var noteManager = NoteManager()
    
    // Trip in progress flag.
    var tripInProgress = false
    
    // Holds the start time of the trip for calculating elapsed time.
    var tripStartTime = NSDate.timeIntervalSinceReferenceDate
    
    // Key name to local JSON store for coordinate path.
    let jsonStore = "tripPathData"
    
    // Reference to iOS user defaults store.
    let defaults = UserDefaults()
    
    // Debug variable for storing coordinates and testing.
    var tmpI = 0
    
    // Holds selected trip type during save dialog.
    var selectedTripType = 7    // other
    
    // Holds selected note type during save dialog.
    var selectedNoteType = 0    // other
    
    // Initiate location services with high precision.
    override func viewDidLoad() {
        NSLog("Loading context from app delegate %@", appDelegate)
        context = appDelegate.getManagedObjectContext(appDelegate.getPersistentStoreCoordinator())
        NSLog("Loaded context %@", context!)
        tripManager = TripManager.init(managedObjectContext: context)
        noteManager = NoteManager.init(managedObjectContext: context)
        
        // Store device ID for uploading to server.  (Refuses to accept data [500 error] without device ID.)
        appDelegate.initUniqueIDHash()
        
        super.viewDidLoad()
        
        mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
        mapView.showsUserLocation = true
        mapView.mapType = MKMapType.standard
        
        mapView.delegate = self
        
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
        
        // Save trip every few seconds.
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
            if currentSpeed < 0 {
                speedCounter.text = "0.0 mph"
            } else {
                speedCounter.text = String.localizedStringWithFormat("%.1f mph", currentSpeed * 3600 / 1609.344)
            }
        } else {
            speedCounter.text = "0.0 mph"
        }
        
        // Remaining logic runs only during a recording.
        if !tripInProgress { return }
        
        for loc in locations {
            userLocationTrace.coords.append(loc)
            let distance = tripManager.addCoord(loc)
            
            // Update distance display.
            self.distanceCounter.text = String.localizedStringWithFormat("%.1f mi", distance / 1609.344)
        }
        
        // Update time display.
        let elapsedTime = NSDate.timeIntervalSinceReferenceDate - tripStartTime
        let doubleTime = Double(elapsedTime)
        let hours = Int(doubleTime) / 3600
        let minutes = (Int(doubleTime) - (hours*3600)) / 60
        let seconds = (Int(doubleTime) - (hours*3600) - (minutes*60))
        
        self.timeCounter.text = String.localizedStringWithFormat("%02d:%02d:%02d", hours, minutes, seconds)
        
        removeUserTraceOverlay()
        
        // Extract CLLocationCoordinate2D array from CLLocation array.
        let coords = userLocationTrace.coords.map { $0.coordinate }
        
        print ("Creating polyline from coords in didUpdateLocations")
        
        // Draw overlay polyline from CLLocationCoordinate2D array.
        //mapView.add(MKPolyline(coordinates: &coords, count: self.userLocationTrace.coords.count))
        createAndAddOverlay(mapView: mapView, coords: coords)
    }
    
    func createAndAddOverlay(mapView : MKMapView, coords : [CLLocationCoordinate2D]) {
        print ("createAndAddOverlay")
        
        mapView.add(MKPolyline(coordinates: coords, count: coords.count), level: .aboveRoads)
        print ("added overlay of coords")
        print (coords)
    }
    
    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        locationManager.allowDeferredLocationUpdates(untilTraveled: 100, timeout: 60)  // meters, seconds
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        // Called when an overlay needs to be drawn.  If it is our polyline user trace, set its render options.
        print ("mapView:rendererFor called")
        //if overlay is MKPolyline {
            print ("rendering our polyline for the path")
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            
            polylineRenderer.strokeColor = UIColor.blue.withAlphaComponent(0.5)
            polylineRenderer.lineWidth = 7
            polylineRenderer.lineJoin = CGLineJoin.round
            polylineRenderer.lineCap = CGLineCap.round
            
            return polylineRenderer
        //}
        
        //return MKOverlayRenderer()
    }
    
    func resetCounters() {
        self.distanceCounter.text = "0.0 mi"
        self.timeCounter.text = "00:00:00"
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
        noteButton.isHidden = false
        
        tripView.isHidden = true
        
        resetTrip()
        
        tripInProgress = true
        
        // Set the start time to calculate elapsed time.
        self.tripStartTime = NSDate.timeIntervalSinceReferenceDate
        
        // Extract CLLocationCoordinate2D array from CLLocation array.
        let coords = userLocationTrace.coords.map { $0.coordinate }
        
        print ("Creating polyline from coords in tapStartButton")
        // Draw overlay polyline from CLLocationCoordinate2D array.
        //mapView.add(MKPolyline(coordinates: &coords, count: self.userLocationTrace.coords.count))
        createAndAddOverlay(mapView: mapView, coords: coords)
    }
    
    @IBAction func tapSaveButton(_ sender: AnyObject) {
        // Ask about saving the trip.
        startButton.isHidden = true
        stopButton.isHidden = true
        continueButton.isHidden = false
        discardTripButton.isHidden = false
        noteButton.isHidden = true
        
        tripView.isHidden = false
    }
    
    @IBAction func tapContinueButton(_ sender: Any) {
        // Keep recording after all.
        startButton.isHidden = true
        stopButton.isHidden = false
        continueButton.isHidden = true
        discardTripButton.isHidden = true
        noteButton.isHidden = false
        
        tripView.isHidden = true
    }

    @IBAction func tapDiscardTripButton(_ sender: Any) {
        // Toss the trip and stop recording.
        startButton.isHidden = false
        stopButton.isHidden = true
        continueButton.isHidden = true
        discardTripButton.isHidden = true
        noteButton.isHidden = true
        
        tripView.isHidden = true
        
        resetTrip()
    }
    
    func removeUserTraceOverlay() {
        // Remove the user trace overlay, modify it, and add it back in.
        if mapView.overlays.count > 0 {
            // Currently assumes a single overlay.  This may need to change someday.
            mapView.remove(mapView.overlays[0])
        }
    }
    
    func resetTrip() {
        // Clear any cached data from a previous trip.
        resetCounters()
        userLocationTrace.clear()
        storeTrip()
        removeUserTraceOverlay()
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
            self.noteButton.isHidden = true
            self.resetTrip()
        }
        let noteAction = UIAlertAction(title: "Add Details", style: .default) { action in
            print ("Adding details to trip of type \(self.selectedTripType)")
            
            print ("Triggering segue TripDetailSegue")
            self.performSegue(withIdentifier: "TripDetailSegue", sender: nil)
        }

        alert.addAction(saveAction)
        alert.addAction(noteAction)
        
        present(alert, animated: true, completion: nil)

        // And reset to no trip in progress.
        startButton.isHidden = true
        stopButton.isHidden = true
        continueButton.isHidden = true
        discardTripButton.isHidden = true
        noteButton.isHidden = true
        
        tripView.isHidden = true
        
        // And definitely end the trip now that they have chosen to save a trip category.
        tripInProgress = false
    }
    
    @IBAction func saveNote(_ sender: UIButton) {
        var title = ""
        var message = ""
        var noteType = 0
        
        switch (sender.tag) {
        case 1:
            title = "Short Cut"
            message = LocalizedMessages.NOTE_ASSET_SHORT_CUT
            noteType = 2
        case 2:
            title = "Bike Parking"
            message = LocalizedMessages.NOTE_ASSET_PARKING
            noteType = 5
        case 3:
            title = "Bike Shop"
            message = LocalizedMessages.NOTE_ASSET_BIKE_SHOPS
            noteType = 4
        case 4:
            title = "Wash Up"
            message = LocalizedMessages.NOTE_ASSET_WASH_UP
            noteType = 3
        case 5:
            title = "Note This Asset"
            message = LocalizedMessages.NOTE_ASSET_OTHER
            noteType = 0
        case 6:
            title = "Fix Signal"
            message = LocalizedMessages.NOTE_ISSUE_SIGNAL
            noteType = 8
        case 7:
            title = "Rough Road"
            message = LocalizedMessages.NOTE_ISSUE_REPAIR
            noteType = 7
        case 8:
            title = "Needs Enforcement"
            message = LocalizedMessages.NOTE_ISSUE_ENFORCEMENT
            noteType = 9
        case 9:
            title = "Need Parking"
            message = LocalizedMessages.NOTE_ISSUE_PARKING
            noteType = 10
        default:
            title = "Note This Asset"
            message = LocalizedMessages.NOTE_ASSET_OTHER
            noteType = 0
            
        }
  
        
        noteManager.createNote()
        
        if userLocationTrace.coords.count > 0 {
            noteManager.add(userLocationTrace.coords.last)
        }
        
        self.selectedNoteType = noteType
        
        // The real note type IDs in the original database are a bit silly.
        if self.selectedNoteType >= 7 {
            self.noteManager.note.note_type = (self.selectedNoteType - 7) as NSNumber
        } else if self.selectedNoteType <= 5 {
            self.noteManager.note.note_type = (11 - self.selectedNoteType) as NSNumber
        }
        
        print (title, message, noteType)
        
        // Display the alert request for saving immediately or adding user-provided details.
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { action in
            self.noteManager.saveNote()
        }
        let detailsAction = UIAlertAction(title: "Add Details", style: .default) { action in
            print ("Adding details to note of type \(self.selectedNoteType)")
            
            print ("Triggering segue NoteDetailSegue")
            self.performSegue(withIdentifier: "NoteDetailSegue", sender: nil)
        }

        alert.addAction(saveAction)
        alert.addAction(detailsAction)
        
        present(alert, animated: true, completion: nil)

        noteView.isHidden = true
    }
    
    //func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print ("Called prepareForSegue()")
        if segue.identifier == "TripDetailSegue" {
            print ("Segue is TripDetailSegue")
            if let destination = segue.destination as? TripDetailsViewController {
                print ("Set self as delegate on destination \(destination)")
                destination.delegate = self
            } else {
                print ("Can't set self as delegate on destination \(segue.destination)")
            }
        } else if segue.identifier == "NoteDetailSegue" {
            print ("Segue is NoteDetailSegue")
            if let destination = segue.destination as? NoteDetailsViewController {
                print ("Set self as delegate on destination \(destination)")
                destination.delegate = self
            } else {
                print ("Can't set self as delegate on destination \(segue.destination)")
            }
        }

    }
    
    func sendDetails(value: String) {
        // Add the detail note for the trip, then save it.
        print ("sendDetails() called in RecordViewController.")
        tripManager.saveNotes(value)
        uploadTrip()
        self.startButton.isHidden = false
        noteButton.isHidden = true
        resetTrip()
    }

    func sendNoteDetails(value: String) {
        // Add the details for the note, then save it.
        print ("sendNoteDetails() called in RecordViewController.")
        noteManager.note.details = value
        noteManager.saveNote()
    }

    func uploadTrip () {
        let purpose = self.selectedTripType
        tripManager.setPurpose(UInt32(purpose))
        tripManager.saveTrip()
    }
    
    @IBAction func createNote(_ sender: Any) {
        noteView.isHidden = false
    }
    
}

