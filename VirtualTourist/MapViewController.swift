//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Chris Scheid on 12/17/17.
//  Copyright © 2017 Chris Scheid. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import CoreLocation


class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>?
    let PhotoAlbumSegueName = "ShowPhotoAlbumViewController"
    
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        // Configure user location
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()

        // Configure Map
        configureMap();
        
        // Fetch and display pinss
        fetchMapPins();

    }

    private func configureMap()
    {
        
        // Set initial map location
        setStoredMapLocation()
        
        // Add a gesture recognizer map for adding pins
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleMapTap(gesture:)))
        longPressGesture.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPressGesture)
        
    }
    
    // Store new map center on pan/zoom
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let coordinate = mapView.centerCoordinate

        // Store map location
        storeMapLocation(coordinate: coordinate)
     
    }
    
    private func fetchMapPins()
    {
        // Create fetch request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        
        do {
            if let result = try CoreDataStack.shared.context.fetch(fetchRequest) as? [Pin] {
                // Loop pins and create annotations
                for pin in result {
                    // create annotation from coordinates
                    let location = CLLocationCoordinate2D(latitude: CLLocationDegrees(pin.latitude),longitude: CLLocationDegrees(pin.longitude))
                    
                    createMapAnnotation(coordinate: location);
                }
            }
        } catch {
            print("Couldn't find any Pins")
        }
    }
    
    // Event Handler for long press
    func handleMapTap(gesture: UILongPressGestureRecognizer){
        if gesture.state == .ended {
            let point = gesture.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            // print(coordinate)
            
            // Add annotation:
            createMapAnnotation(coordinate: coordinate)
            
            // Store it in core data
            createPin(coordinate:coordinate)
        }
    }
    
    private func setStoredMapLocation(){
   
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MapLocation")
            
            // Configure Fetch Request
            fetchRequest.includesPropertyValues = true
            
            
            if let result = try CoreDataStack.shared.context.fetch(fetchRequest) as? [MapLocation], let mapLocation = result.first {
               let location = CLLocationCoordinate2D(latitude: CLLocationDegrees(mapLocation.latitude),longitude: CLLocationDegrees(mapLocation.longitude))

                setMapLocation(coordinate: location, width: Constants.MapConstants.InitialMapWidth, height: Constants.MapConstants.InitialMapHeight)
            }
            else {
                // Create / set default location
                let location = CLLocationCoordinate2D(latitude: CLLocationDegrees(Constants.MapConstants.LatCenterUs),longitude: CLLocationDegrees(Constants.MapConstants.LonCenterUs))
                storeMapLocation(coordinate: location)
                
                setMapLocation(coordinate: location, width: Constants.MapConstants.InitialMapWidth, height: Constants.MapConstants.InitialMapHeight)
            }

        } catch {
            print("An error occured fetching Map Locations")
        }
    }
    
    private func storeMapLocation(coordinate: CLLocationCoordinate2D){
        
        deleteMapLocations()
        
        // Create new Map Location
        let mapLocation = MapLocation(context: CoreDataStack.shared.context)
        mapLocation.mapLocationId = Utils.getUniqueId()
        mapLocation.latitude = Double(coordinate.latitude)
        mapLocation.longitude = Double(coordinate.longitude)

        CoreDataStack.shared.save()
    }
    
    private func setMapLocation(coordinate: CLLocationCoordinate2D, width: CLLocationDistance, height: CLLocationDistance)
    {

        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, width, height)
        
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    private func deleteMapLocations()
    {
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MapLocation")
        
        // Configure Fetch Request
        fetchRequest.includesPropertyValues = false
        
        do {
            if let result = try CoreDataStack.shared.context.fetch(fetchRequest) as? [MapLocation] {
                for mapLocation in result {
                    CoreDataStack.shared.context.delete(mapLocation)
                }
            }
            
        } catch {
            print("Unable to delete records")
        }
    }
    
    private func createMapAnnotation(coordinate: CLLocationCoordinate2D)
    {
        // Create map annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }

    // Creates a pin in core data
    private func createPin(coordinate: CLLocationCoordinate2D)
    {
        
        let pin = Pin(context: CoreDataStack.shared.context)
        pin.pinId = Utils.getUniqueId()
        pin.latitude = Double(coordinate.latitude)
        pin.longitude = Double(coordinate.longitude)
        
        // Save to core data
        CoreDataStack.shared.save()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "TravelLocation") as? MKPinAnnotationView
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "TravelLocation")
            annotationView?.canShowCallout = false
            annotationView?.rightCalloutAccessoryView = UIButton(type: .infoLight)

        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
 
    // MARK: Handle pin click and open Pin View
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        
        if let annotation = view.annotation {
            
            // Deselect annotation
            mapView.deselectAnnotation(annotation, animated: false)
            
            // Fetch Pin using lat and lon
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
            let predicate = NSPredicate(format: "latitude == %@ AND longitude == %@", argumentArray: [annotation.coordinate.latitude, annotation.coordinate.longitude])
            fetchRequest.predicate = predicate
            
            do {
                if let result = try CoreDataStack.shared.context.fetch(fetchRequest) as? [Pin],let pin = result.first {
                        // Show album page
                        performSegue(withIdentifier: PhotoAlbumSegueName, sender: pin)
                    }
            } catch {
                print("Couldn't find any Pins")
            }
        }
    }
    
    // Override prepare segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == PhotoAlbumSegueName)
        {
            // Get the VC
            let photoAlbumViewController = segue.destination as! PhotoAlbumViewController
            photoAlbumViewController.pin = sender as! Pin
        }
    }
    
    func displayError(_ errorString: String?) {
        if let errorString = errorString {
            let alert = UIAlertController(title: "Error", message: errorString, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

}

