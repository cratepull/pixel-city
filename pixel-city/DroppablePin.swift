//
//  DroppablePin.swift
//  pixel-city
//
//  Created by Sebastian Salamanca on 2/4/18.
//  Copyright © 2018 Sebastian Salamanca. All rights reserved.
//

import UIKit
import MapKit

class DroppablePin: NSObject, MKAnnotation {

    dynamic var coordinate: CLLocationCoordinate2D
    var identifier: String = ""
    
    init(coordenate:CLLocationCoordinate2D, identifier:String ){
        self.coordinate = coordenate
        self.identifier = identifier
        super.init()
    }
}
