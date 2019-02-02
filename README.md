# Virtual Tourist App to view Flickr images based on location
## Overview
This app let's you pick places on the world map and view a random set of Flickr images associated with this location. It's a fun way to discover the world.


## Implementation
* The app uses two view controllers: A MapViewController for the map view and a PhotoAlbumViewController for the photo view
* The maps are rendered using the standard iOS MapKit.
* Entities like MapLocation, Pin, Photo are persisted by using the iOS CoreData library.
* The photos are fetched in the PhotoAlbumViewController by passing the location geo coordinates to the Flickr REST API.

## Usage
1. When the app is started, a map is displayed. You can use pinch, zoom and pan to adjust the map
2. Long press on the map to create a pin at the desired location.
3. When you click on the pin, a random set of images are fetched from Flickr for this location.

## Screenshots
![Virtual Tourist 1](Screenshots/virtual-tourist-ss-1.png?raw=true "Virtual Tourist 1")

![Virtual Tourist 2](Screenshots/virtual-tourist-ss-2.png?raw=true "Virtual Tourist 2")
