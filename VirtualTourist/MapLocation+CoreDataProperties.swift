//
//  MapLocation+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Chris Scheid on 12/18/17.
//  Copyright © 2017 Chris Scheid. All rights reserved.
//

import Foundation
import CoreData


extension MapLocation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MapLocation> {
        return NSFetchRequest<MapLocation>(entityName: "MapLocation");
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var mapLocationId: Int32

}
