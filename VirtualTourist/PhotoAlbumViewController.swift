//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Chris Scheid on 12/17/17.
//  Copyright © 2017 Chris Scheid. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData


class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    var pin: Pin!
    var photoArray = [Photo]()
    var deletePhotoArray = [Photo]()
    let itemsPerRow: CGFloat = 3
    let sectionInsets = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print("id: \(pin.pinId) lat: \(pin.latitude) lon: \(pin.longitude)")
        
        // Set Map Center around pin
        let location = CLLocationCoordinate2D(latitude: CLLocationDegrees(pin.latitude),longitude: CLLocationDegrees(pin.longitude))
        setMapLocation(coordinate: location, width: Constants.MapConstants.DetailMapWidth, height: Constants.MapConstants.DetailMapHeight)
        
        // Set the pin
        createMapAnnotation(coordinate: location)
        
        // Load the photos - either from core data or Flickr
        loadPhotos()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    private func setMapLocation(coordinate: CLLocationCoordinate2D, width: CLLocationDistance, height: CLLocationDistance)
    {
        
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, width, height)
        
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "TravelLocation") as? MKPinAnnotationView
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "TravelLocation")
            annotationView?.canShowCallout = true
            annotationView?.rightCalloutAccessoryView = UIButton(type: .infoLight)
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // Open LinkedIn page in Safari
        if let url = URL(string: (view.annotation?.subtitle!)!) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    private func createMapAnnotation(coordinate: CLLocationCoordinate2D)
    {
        // Create map annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
    // Load photos - either from Flickr or cached from Core Data
    func loadPhotos(){
        // clear photo array
        self.photoArray = [Photo]()
        
        if let fetchResult = fetchPinPhotosFromCache() {
            photoArray = fetchResult
            
            collectionView.reloadData()
        } else {
            // Fetch images from Flickr
            FlickrClient.getPhotoImages(lat: pin.latitude, lon: pin.longitude) { (imageUrls, error) in
                if (imageUrls == nil || imageUrls?.count == 0)
                {
                    DispatchQueue.main.async {
                        self.setNoPhotosLabel()
                    }
                }
                else{
                    if let imageUrls = imageUrls {
                        for imageUrl in imageUrls {
                            // Store image url as a Photo
                            let photo = Photo(context: CoreDataStack.shared.context)
                            photo.mediaURL = imageUrl
                            photo.photo_pin = self.pin
                            // Save Core Data
                            CoreDataStack.shared.save()
                            
                            // add photo to array
                            self.photoArray.append(photo)
                        }
                        
                        DispatchQueue.main.async {
                            // Reload the collection view
                            self.collectionView.reloadData()
                            
                            self.setNoPhotosLabel();
                        }
                    }
                  
                }
            }
        }
    }
    
    @IBAction func refreshPhotoAlbumAction(_ sender: Any) {
        self.infoLabel.isHidden = true;
        self.collectionView.isHidden = false;
        
        // Delete all existing photos
        for photo in photoArray {
            CoreDataStack.shared.context.delete(photo)
        }
        
        CoreDataStack.shared.save()
        photoArray = [Photo]()
        collectionView.reloadData()
        
        // Get new set of photos
        loadPhotos()
    }
    
    @IBAction func deletePhotoAction(_ sender: Any) {
        for photo in deletePhotoArray {
            CoreDataStack.shared.context.delete(photo)
            photoArray.remove(at: photoArray.index(of: photo)!)
        }
        
        // Save changes
        CoreDataStack.shared.save()
        
        // Clear array
        deletePhotoArray = [Photo]()
       
        // Reload collection view
        collectionView.reloadData()
        
        setNoPhotosLabel();
        
    }
    
    private func setNoPhotosLabel()
    {
        self.infoLabel.isHidden = true;
        self.collectionView.isHidden = false;
        if (photoArray.count == 0)
        {
            self.infoLabel.text = "No photos found or no network connection"
            self.infoLabel.isHidden = false;
            self.collectionView.isHidden = true;
        }
    }

    private func fetchPinPhotosFromCache() -> [Photo]? {

        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
            let predicate = NSPredicate(format: "photo_pin == %@", argumentArray: [pin])
            fetchRequest.predicate = predicate
            
            if let result = try CoreDataStack.shared.context.fetch(fetchRequest) as? [Photo] {
                return result.count > 0 ? result : nil
            }
        } catch {
            print("Couldn't find any Pins")
        }
        return nil
    }
    

    // if an error occurs, print it and re-enable the UI
    func displayError(_ error: String?) {
        DispatchQueue.main.async() {
            if let errorString = error {
                let alert = UIAlertController(title: "Error", message: errorString, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
    
// Collection View
extension PhotoAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate {
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        
        let photo = self.photoArray[indexPath.row]
        
        cell.imageView.image = UIImage(named: "icons8-picture-100")
        
        // Reset dim
        cell.contentView.alpha = 1.0
        
        if let imageData = photo.image {
            let image = UIImage(data: imageData as Data)
            cell.imageView.image = image
            
        } else {
            FlickrClient.getImage(with: photo.mediaURL!) { (data, error) in
                DispatchQueue.main.async {
                    if error == nil {
                        photo.image = data as NSData?
                        collectionView.reloadItems(at: [indexPath])
                    }
                }
            }
        }
        
        return cell
    }
    
    // Add photos to delete array
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Get selected cell 
        let cell = collectionView.cellForItem(at: indexPath)
        // Dim selected photo
        cell?.contentView.alpha = 0.5
        
        // Get selected photo
        let selectedPhoto = photoArray[indexPath.row]
        if !deletePhotoArray.contains(selectedPhoto) {
            deletePhotoArray.append(selectedPhoto)
        }
        
        // Enable delete button
        deleteButton.isEnabled = true
    }
    
    func setupFlowLayout() {
        collectionView.allowsMultipleSelection = true
        
        let space: CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }

}



  
