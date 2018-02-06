//
//  Constants.swift
//  pixel-city
//
//  Created by Sebastian Salamanca on 2/5/18.
//  Copyright © 2018 Sebastian Salamanca. All rights reserved.
//

import Foundation

let apiKey = "08faabbcb64ed737eeaeb29075c94042"

func flickrUrl(forApiKey key: String, withAnnotation annotation: DroppablePin, andNumberOfPhotos number: Int ) -> String {
    
    return "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=ml&per_page=\(number)&format=json&nojsoncallback=1"
}
