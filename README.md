# Virtual Tourist App to view Flickr images based on location
## Overview
This app let's you pick places on the world map and view a random set of Flickr images associated with this location. It's a fun way to discover the world.

## Getting Started
Open the .xcodeproject file in a recent version of XCode. Then clean, build and run on a device or emulator.

## Prerequisites
Apple Mac OSX laptop, XCode 8+

## Building
1. Double-click on the .xcodeproj or open the project from within XCode
2. In XCode IDE, select Produce / Clean and then Build from the top menu
3. Use the 'Play' (>) button to launch the app on a device or emulator

## Installing & Deployment
1. The program can be run immediately on an XCode simulator. 
2. In order to run the program on an actual Apple device, an Apple developer membership and a provisioning profile for the device is needed.

## Usage
1. When the app is started, a map is displayed. You can use pinch, zoom and pan to adjust the map
2. Long press on the map to create a pin at the desired location.
3. When you click on the pin, a random set of images are fetched from Flickr for this location.

## Implementation
* The app uses two view controllers: A MapViewController for the map view and a PhotoAlbumViewController for the photo view
* The maps are rendered using the standard iOS MapKit.
* Entities like MapLocation, Pin, Photo are persisted by using the iOS CoreData library.
* The photos are fetched in the PhotoAlbumViewController by passing the location geo coordinates to the Flickr REST API.

## Versioning
Version 1.0

## Authors
Christian Scheid - (https://justmobiledev.com)[https://justmobiledev.com]

## License
This project is licensed under the MIT License - see the LICENSE.md file for details

## Screenshots
![Virtual Tourist 1](Screenshots/virtual-tourist-ss-1.png?raw=true "Virtual Tourist 1")

![Virtual Tourist 2](Screenshots/virtual-tourist-ss-2.png?raw=true "Virtual Tourist 2")
