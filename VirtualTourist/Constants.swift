//
//  NetworkConstants.swift
//  VirtualTourist
//
//  Created by Chris Scheid on 12/17/17.
//  Copyright © 2017 Chris Scheid. All rights reserved.
//

import Foundation
import MapKit

struct Constants {
    
    // MARK: Flickr
    struct Flickr {
        static let APIBaseURL = "https://api.flickr.com/services/rest/"
    }
    
    // MARK: Flickr Parameter Keys
    struct FlickrParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let GalleryID = "gallery_id"
        static let Extras = "extras"
        static let Format = "format"
        static let BBox = "bbox"
        static let Page = "page"
        static let PerPage = "per_page"
        static let NoJSONCallback = "nojsoncallback"
    }
    
    // MARK: Flickr Parameter Values
    struct FlickrParameterValues {
        static let APIKey = "6018ce76bba90c3eff10d2f95093f634"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1" /* 1 means "yes" */
        static let SearchPhotosMethod = "flickr.photos.search"
        static let MediumURL = "url_m"
        static let PerPageValue = "12"
    }
    
    // MARK: Flickr Response Keys
    struct FlickrResponseKeys {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let Title = "title"
        static let MediumURL = "url_m"
    }
    
    // MARK: Flickr Response Values
    struct FlickrResponseValues {
        static let OKStatus = "ok"
    }
    
    // MARK: Map constants
    struct MapConstants {
        static let InitialMapWidth: CLLocationDistance = 6000000 // ~ width of US in meters
        static let InitialMapHeight: CLLocationDistance = 2600000 // ~ height of US in meters
        static let DetailMapWidth: CLLocationDistance = 6000 // ~ width of US in meters
        static let DetailMapHeight: CLLocationDistance = 2600 // ~ height of US in meters
        static let ZoomMapWidth: CLLocationDistance = 50000 // meters
        static let ZoomMapHeight: CLLocationDistance = 50000 // meters
        static let LatCenterUs: CLLocationDegrees = 42.877742
        static let LonCenterUs: CLLocationDegrees = -97.380979
    }
}

