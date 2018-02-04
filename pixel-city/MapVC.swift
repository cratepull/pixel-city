//
//  MapVC.swift
//  pixel-city
//
//  Created by Sebastian Salamanca on 2/3/18.
//  Copyright © 2018 Sebastian Salamanca. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapVC: UIViewController {
    
    //OUtlets
    @IBOutlet weak var mapView: MKMapView!
    
    // Vars
    var locationManager = CLLocationManager()
    
    let authorizationStatus = CLLocationManager.authorizationStatus()
    
    // Actions
    @IBAction func centerMapBtnWasPressed(_ sender: Any) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationServices()
    }
}


extension MapVC: MKMapViewDelegate{

}

extension MapVC: CLLocationManagerDelegate{
    func configureLocationServices(){
        if authorizationStatus == .notDetermined{
            locationManager.requestAlwaysAuthorization()
        }else{
            return
        }
    }
}


