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
import Alamofire
import AlamofireImage

class MapVC: UIViewController, UIGestureRecognizerDelegate {
    
    //OUtlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pullUpView: UIView!
    @IBOutlet weak var pullUpViewConstrain: NSLayoutConstraint!
    
    // Vars
    var locationManager = CLLocationManager()
    var spinner: UIActivityIndicatorView?
    var progressLabel: UILabel?
    var screenSize = UIScreen.main.bounds
    
    
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadous:Double = 1000
    
    var flowLayout  = UICollectionViewFlowLayout()
    var collectionView : UICollectionView?
    
    
    var imageUrlArray = [String]()
    var imageArray = [UIImage]()
    
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
        
        collectionView = UICollectionView(frame: view.bounds , collectionViewLayout: flowLayout)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        pullUpView.addSubview(collectionView!)
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
        cancelAllSessions()
        pullUpViewConstrain.constant = 0
        UIView.animate(withDuration: 0.3) { 
            self.view.layoutIfNeeded()
        }
    }
    
    func addSpinner(){
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: (screenSize.width / 2) - ((spinner?.frame.width)! / 2) , y:  150 )
        spinner?.activityIndicatorViewStyle = .whiteLarge
        spinner?.color = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        spinner?.startAnimating()
        collectionView?.addSubview(spinner!)
    }
    
    func removeSpinner(){
        if spinner != nil {
            spinner?.removeFromSuperview()
        }
    }
    
    func addProgressLbl(){
        progressLabel = UILabel()
        progressLabel?.frame = CGRect(x: (screenSize.width / 2) - 100 , y: 80, width: 200, height: 40)
        progressLabel?.font = UIFont(name: "Avenier Next", size: 14)
        progressLabel?.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        progressLabel?.textAlignment = .center
        collectionView?.addSubview(progressLabel!)
    }
    
    
    func removeProgressLabel(){
        if progressLabel != nil{
            progressLabel?.removeFromSuperview()
        }
    }
    
    func animateViewUp(){
        pullUpViewConstrain.constant = 300
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
        
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
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
        removeSpinner()
        removeProgressLabel()
        cancelAllSessions()
        
        imageUrlArray = []
        imageArray = []
        
        collectionView?.reloadData()
        
        
        animateViewUp()
        addSwipe()
        addSpinner()
        addProgressLbl()
        
        
        let touchPoint = sender.location(in: mapView)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let anotation = DroppablePin(coordenate: touchCoordinate, identifier: "droppablePin")
        
        mapView.addAnnotation(anotation)
        
        let coordernateRegion = MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadous * 2.0, regionRadous * 2.0)
        
        mapView.setRegion(coordernateRegion, animated: true)
        
        retrieveUrls(forAnnotation: anotation) { (success) in
            
            if success {
                self.retrieveImages(handler: { (success) in
                    if success {
                        self.removeSpinner()
                        self.removeProgressLabel()
                        self.collectionView?.reloadData()
                    }
                })
            }
        }
    }
    
    func removePin(){
        for annotation in mapView.annotations{
            mapView.removeAnnotation(annotation)
        }
    }
    
    func retrieveUrls(forAnnotation anotation: DroppablePin, handler: @escaping (_ status: Bool)->()){
        Alamofire.request(flickrUrl(forApiKey: apiKey, withAnnotation: anotation, andNumberOfPhotos: 40)).responseJSON { (response) in
            
            guard let json = response.result.value as? Dictionary<String, AnyObject> else { return }
            let photosDic = json["photos"] as! Dictionary<String, AnyObject>
            let photosDicArray = photosDic["photo"] as! [Dictionary<String, AnyObject>]
            
            for photo in photosDicArray{
                
                let postUrl = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_h_d.jpg"
                
                self.imageUrlArray.append(postUrl)
            
            }
            
            handler(true)
        }
    }
    
    func retrieveImages(handler: @escaping(_ status: Bool)->()){
        for url in imageUrlArray{
            Alamofire.request(url).responseImage(completionHandler: { (response) in
                guard let image = response.result.value else { return }
                
                self.imageArray.append(image)
                self.progressLabel?.text = "\(self.imageArray.count)/40 IMAGES DOWNLOADED"
                
                if self.imageArray.count == self.imageUrlArray.count{
                    handler(true)
                }
            })
        }
    }
    
    func cancelAllSessions() {
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach({ $0.cancel() })
            downloadData.forEach({ $0.cancel() })
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



extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell else { return UICollectionViewCell() }
        let imageFromIndex = imageArray[indexPath.row]
        let imageView = UIImageView(image: imageFromIndex)
        cell.addSubview(imageView)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC
            else { return }
        
        popVC.initData(forImage: self.imageArray[indexPath.row])
        present(popVC, animated: true, completion: nil)
    }
}

