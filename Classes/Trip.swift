//
//  Trip.swift
//  Cycle Atlanta
//
//  Created by C. David Byrd on 2/3/17.
//  Copyright © 2017 Ga Tech. All rights reserved.
//
//

import UIKit
import CoreLocation

class Trip: NSObject, Glossy {
    
    var coords : [CLLocation]
    
    override init() {
        // User defaults
        if let savedTrip = UserDefaults.standard.object(forKey: "tripData") as? Data {
            self.coords = NSKeyedUnarchiver.unarchiveObject(with: savedTrip) as! [CLLocation]
        } else {
            self.coords = [CLLocation]()
        }
        
        print ("Loaded coords: \(self.coords)")
    }
    
    func clear() {
        self.coords = [CLLocation]()
    }
    
    func storeCoords () {
        let tripToSave = NSKeyedArchiver.archivedData(withRootObject: self.coords)
        
        // User defaults
        UserDefaults.standard.set(tripToSave, forKey: "tripData")
        
        //print ("Stored coords: \(coords)")
    }
    
    required init?(json: JSON) {
        if let coords : [CLLocation] = "coords" <~~ json {
            self.coords = coords
        } else {
            print ("JSON trip load failed.  Initializing.")
            self.coords = [CLLocation]()
        }
    }
    
    // Going to have to break out each coordinate separately to store it in json...
    func toJSON() -> JSON? {
        return jsonify([
            "coords" ~~> coords
            ])
    }
    
    
}
