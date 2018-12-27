//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Chris Scheid on 12/17/17.
//  Copyright © 2017 Chris Scheid. All rights reserved.
//

import UIKit

class FlickrClient {
    
    public static func getPhotoImages(lat: Double, lon: Double, completion: @escaping(_ imageUrls: [String]?, _ error: String?) -> Void) {
        
        var imageUrlArray = [String]()
        
        // Calculate bounding box
        let latlonBox = buildLatLongBox(lat: lat, lon: lon);
        
        let randomPage = (arc4random_uniform(10) + 1)
        
        let methodParameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchPhotosMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.BBox: latlonBox,
            Constants.FlickrParameterKeys.Page: String(randomPage),
            Constants.FlickrParameterKeys.PerPage: Constants.FlickrParameterValues.PerPageValue,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
        ]
        
        let urlString = Constants.Flickr.APIBaseURL + escapedParameters(methodParameters as [String:AnyObject])
        print("Flickr Url: "+urlString)
        
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        
        // create network request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                completion(nil, "There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completion(nil, "Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                completion(nil, "No data was returned by the request!")
                return
            }
            
            // parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                completion(nil, "Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
                completion(nil, "Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            /* GUARD: Are the "photos" and "photo" keys in our result? */
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject], let photoArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
                completion(nil, "Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' and '\(Constants.FlickrResponseKeys.Photo)' in \(parsedResult)")
                return
            }
            
            // Loop results and get image url
            for photo in photoArray {
                if let imageUrl = photo["url_m"] as? String {
                    imageUrlArray.append(imageUrl)
                }
            }
            completion(imageUrlArray, "")
        }
        
        task.resume()
        
    }
    
    public static func getImage(with url: String, completion: @escaping(_ data: Data?, _ error: String?) -> Void) {
        
        downloadTask(with: url, convertData: false) { (response, error) in
            completion(response as? Data, error)
        }
    }
    
    private static func downloadTask(with url: String, convertData: Bool, completion: @escaping(_ response: AnyObject?, _ error: String?) -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            
            guard (error == nil) else {
                completion(nil, "There was an error with your request")
                return
            }
            
            guard let data = data else {
                completion(nil, "No data was returned by the request!")
                return
            }
            
            guard let code = (response as? HTTPURLResponse)?.statusCode, (200...299).contains(code) else {
                completion(nil, "Not a successfull status code")
                return
            }
            
            if convertData {
                self.convertData(data, completion: completion)
            } else {
                completion(data as AnyObject?, nil)
            }
        }
        
        task.resume()
    }
    
    private static func convertData(_ data: Data, completion: (_ response: AnyObject?, _ error: String?) -> Void) {
        var parsedResult: AnyObject! = nil
        
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            completion(nil, "Error parsing json")
        }
        
        completion(parsedResult, nil)
    }
    
    private static func buildLatLongBox(lat: Double, lon: Double) -> String {
        let minLat = lat - 1
        let maxLat = lat + 1
        let minLon = lon - 1
        let maxLon = lon + 1
        return "\(minLon),\(minLat),\(maxLon),\(maxLat)"
    }
    
    private static func escapedParameters(_ parameters: [String:AnyObject]) -> String {
        
        if parameters.isEmpty {
            return ""
        } else {
            var keyValuePairs = [String]()
            
            for (key, value) in parameters {
                
                // make sure that it is a string value
                let stringValue = "\(value)"
                
                // escape it
                let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                
                // append it
                keyValuePairs.append(key + "=" + "\(escapedValue!)")
                
            }
            
            return "?\(keyValuePairs.joined(separator: "&"))"
        }
    }
}
