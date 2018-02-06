//
//  PopVC.swift
//  pixel-city
//
//  Created by Sebastian Salamanca on 2/6/18.
//  Copyright © 2018 Sebastian Salamanca. All rights reserved.
//

import UIKit

class PopVC: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var popImageView: UIImageView!
    
    var passedImage : UIImage!
    
    func initData(forImage image: UIImage){
        self.passedImage = image
    }
    
    func addDoubleTap(){
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(screenWasDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        view.addGestureRecognizer(doubleTap)
    }
    
    
    @objc func screenWasDoubleTap (){
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popImageView.image = passedImage
        addDoubleTap()
    }
    

}
