//
//  Utils.swift
//  VirtualTourist
//
//  Created by Chris Scheid on 12/17/17.
//  Copyright © 2017 Chris Scheid. All rights reserved.
//

import Foundation


class Utils{
    static func getUniqueId() -> Int32{
        // Get current date
        let someDate = Date()
        
        // Convert Date to TimeInterval (typealias for Double)
        let timeInterval = someDate.timeIntervalSince1970
        
        let uniqueId = timeInterval
        
        //let uniqueIdStr:String = String(format:"%d", timeInterval)
        
        return Int32(uniqueId)
    }
}
