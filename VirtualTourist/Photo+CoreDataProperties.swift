//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Chris Scheid on 12/18/17.
//  Copyright © 2017 Chris Scheid. All rights reserved.
//

import Foundation
import CoreData


extension Photo {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }
    
    @NSManaged public var image: NSData?
    @NSManaged public var photoId: Int32
    @NSManaged public var mediaURL: String?
    @NSManaged public var title: String?
    @NSManaged public var photo_pin: Pin?
    
}
