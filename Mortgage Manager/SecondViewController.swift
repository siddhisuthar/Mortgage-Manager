//
//  SecondViewController.swift
//  Mortgage Manager
//
//  Created by Siddhi Suthar on 5/17/17.
//  Copyright © 2017 Siddhi. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase
import FirebaseDatabase

class SecondViewController: UIViewController {

    var coordinatePassed = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDatafromDatabase()
     
        let f: CGRect = self.view.frame
        let mapFrame: CGRect  = CGRect.init(x: f.origin.x, y: 50, width: f.size.width, height: f.size.height)
        
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: mapFrame, camera: camera)
     
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView
       
        self.view.addSubview(mapView)
    }
    
    func loadDatafromDatabase(){
        
        let currentRef = FIRDatabase.database().reference().child("calculations")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        var tempItems = [NSDictionary]()
        currentRef.observe(.value, with: { snapshot in
            
            for item in snapshot.children {
                let child = item as! FIRDataSnapshot
                let dict = child.value as! NSDictionary
                tempItems.append(dict)
            }
            print("temp items: ")
            print(tempItems)
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        })
       // forward geocoding
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

