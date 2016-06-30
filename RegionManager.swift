//
//  RegionManager.swift
//  Cycle Atlanta
//
//
//

import Foundation

class RegionManager {
    
    var region: OBARegionV2?
    
    class var sharedInstance :RegionManager {
        struct Singleton {
            static let instance = RegionManager()
        }
        
        return Singleton.instance
    }
}
