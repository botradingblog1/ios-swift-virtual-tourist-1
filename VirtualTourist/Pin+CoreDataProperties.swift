//
//  Pin+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Chris Scheid on 12/18/17.
//  Copyright © 2017 Chris Scheid. All rights reserved.
//

import Foundation
import CoreData


extension Pin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pin> {
        return NSFetchRequest<Pin>(entityName: "Pin");
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var pinId: Int32
    @NSManaged public var pin_photo: NSSet?

}

// MARK: Generated accessors for pin_photo
extension Pin {

    @objc(addPin_photoObject:)
    @NSManaged public func addToPin_photo(_ value: Photo)

    @objc(removePin_photoObject:)
    @NSManaged public func removeFromPin_photo(_ value: Photo)

    @objc(addPin_photo:)
    @NSManaged public func addToPin_photo(_ values: NSSet)

    @objc(removePin_photo:)
    @NSManaged public func removeFromPin_photo(_ values: NSSet)

}
