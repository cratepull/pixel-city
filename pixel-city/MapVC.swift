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

class MapVC: UIViewController, UIGestureRecognizerDelegate {
    
    //OUtlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pullUpView: UIView!
    @IBOutlet weak var pullUpViewConstrain: NSLayoutConstraint!
    // Vars
    var locationManager = CLLocationManager()
    var spinner: UIActivityIndicatorView?
    var progressLabel: UILabel?
    
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadous:Double = 1000
    
    var screenSize = UIScreen.main.bounds
    
    
    // Actions
   
    
    @IBAction func centerMapWasPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationServices()
        addDoubleTap()
    }
    
    
    func addDoubleTap(){
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    
    
    }
    
    func addSwipe(){
        
        let swipe  = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swipe.direction = .down
        pullUpView.addGestureRecognizer(swipe)
    }
    
    @objc func animateViewDown(){
        
        pullUpViewConstrain.constant = 0
        
        UIView.animate(withDuration: 0.3) { 
            self.view.layoutIfNeeded()
        }
    }
    
    func addSpinner(){
        
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: (screenSize.width / 2) - ((spinner?.frame.width)! / 2) , y:  75 )
        spinner?.activityIndicatorViewStyle = .whiteLarge
        spinner?.color = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        spinner?.startAnimating()
        pullUpView.addSubview(spinner!)
    
    }
    
    func animateViewUp(){
        
        pullUpViewConstrain.constant = 150
        UIView.animate(withDuration: 0.3) { 
            self.view.layoutIfNeeded()
        }
        
    }
}


extension MapVC: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation{
            return nil
        }
        
        var pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        pinAnnotation.pinTintColor = UIColor.orange
        pinAnnotation.animatesDrop = true
        
        return pinAnnotation
    }
    
    func centerMapOnUserLocation(){
        guard let coordinate = locationManager.location?.coordinate else {return}
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadous * 2.0, regionRadous * 2.0)
        
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer){
        removePin()
        animateViewUp()
        addSwipe()
        addSpinner()
        let touchPoint = sender.location(in: mapView)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
       let anotation = DroppablePin(coordenate: touchCoordinate, identifier: "droppablePin")
        
        mapView.addAnnotation(anotation)
        
        let coordernateRegion = MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadous * 2.0, regionRadous * 2.0)
        
        mapView.setRegion(coordernateRegion, animated: true)
    }
    
    func removePin(){
        for annotation in mapView.annotations{
            mapView.removeAnnotation(annotation)
        }
    }
}

extension MapVC: CLLocationManagerDelegate {
    func configureLocationServices() {
        if authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else {
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }
}


