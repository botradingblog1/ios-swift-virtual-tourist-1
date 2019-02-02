# Virtual Tourist App to view Flickr images based on location
## Overview
This app let's you pick places on the world map and view a random set of Flickr images associated with this location. It's a fun way to discover the world.


## Implementation
* We are using two View Controllers - one for a UITableView and one for a UICollectionView to display the data.
* The Memes are stored in the Meme model.
* The MemeEditorViewController is used to build the Meme. It uses the standard UIImagePickerController to get an image from either the camera or the photoLibrary.
* For the share action we are using a standard UIActivityViewController and passing the image to share.
* As temporary data storage, we are just using a Meme array in the AppDelegate. In the future, the app could be extended to use persistent data storage.

## Usage
1. When the app is started, a map is displayed. You can use pinch, zoom and pan to adjust the map
2. Long press on the map to create a pin at the desired location.
3. When you click on the pin, a random set of images are fetched from Flickr for this location.

## Screenshots
![Virtual Tourist 1](Screenshots/virtual-tourist-ss-1?raw=true "Virtual Tourist 1")

![Virtual Tourist 2](Screenshots/virtual-tourist-ss-2.png?raw=true "Virtual Tourist 2")
