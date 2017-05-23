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

class SecondViewController: UIViewController, GMSMapViewDelegate {

    var tempItems = [NSDictionary]()
    var coord =  [CLLocationCoordinate2D]()
    //var mapView = GMSMapView()
    var info : String = ""
    var markerKey = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let f: CGRect = self.view.frame
        let mapFrame: CGRect  = CGRect.init(x: f.origin.x, y: 50, width: f.size.width, height: f.size.height)
        
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        var mapView = GMSMapView.map(withFrame: mapFrame, camera: camera)
        mapView.delegate = self
        
        mapView = loadDatafromDatabase(mapView)
        print("coords: ")
        print(self.coord)
       
        self.view.addSubview(mapView)
    }
 
    
    func loadDatafromDatabase(_ mapview : GMSMapView) -> GMSMapView{
        
        let currentRef = Database.database().reference().child("calculations")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        //for bounds
        
    
        var bounds = GMSCoordinateBounds()
        
        currentRef.observe(.value, with: { snapshot in
            
            for item in snapshot.children {
                
                let snap = item as! DataSnapshot
               let uid = snap.key
                
                let child = item as! DataSnapshot
                
               print("child: ", child as AnyObject)
                let dict = child.value as! NSDictionary
                
                print("dict:  ", dict)
                
                self.tempItems.append(dict)
               
                let getLatitude = dict.value(forKey: "latitude")
                let getLongitude = dict.value(forKey: "longitude")
               
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: getLatitude as! CLLocationDegrees, longitude: getLongitude as! CLLocationDegrees)
                marker.title = dict.value(forKey: "mAmount") as? String
                
                marker.snippet = uid
                
                marker.map = mapview
                bounds = bounds.includingCoordinate(marker.position)
                
            }
            let update = GMSCameraUpdate.fit(bounds, withPadding: 75)
            mapview.animate(with: update)
            
          //  return tempItems
            print("temp items: ")
            print(self.tempItems)
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        })
       
        return mapview
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        
        self.markerKey = (marker.snippet! as? String)!
        
        let db = Database.database().reference().child("calculations").child((marker.snippet! as? String)!)
        
        db.observeSingleEvent(of: .value, with: { (snapshot) in
            
            //var dict = [NSDictionary]()
            
            let snap = snapshot.children
            let child = snap as! DataSnapshot
            let dict = child.value as! NSDictionary
        
            let s : String = dict.value(forKey: "streetAddr") as! String
            let c : String = dict.value(forKey: "cityAddr") as! String
            let a : String = dict.value(forKey: "anr") as! String
            let l : String = dict.value(forKey: "loanAmt") as! String
            let m : String = dict.value(forKey: "mAmount") as! String
            
            let totalString: String = "\(s) \(c) \n ANR: \(a) \n loanAmount: \(l) \nMonthlyPayment: \(m)"
            
            self.info = totalString
            
            print("\n TOTAL STRING \n : \(totalString)")
            print("\n DICT: \n \(dict)")
        })
        
        
        let alert = UIAlertController(title: "Property info", message: info , preferredStyle: UIAlertControllerStyle.actionSheet)
        
        alert.addAction(UIAlertAction(title:"EDIT", style : UIAlertActionStyle.default , handler : {
            ACTION in
            self.editMarker()
        }))
        
        alert.addAction(UIAlertAction(title:"DELETE", style : UIAlertActionStyle.destructive , handler : {
            ACTION in
            self.deleteMarker()
        }))
        
        alert.addAction(UIAlertAction(title:"CANCEL", style : UIAlertActionStyle.default , handler : nil
        ))
        
        self.present(alert, animated: true, completion: nil)
       
    
  
   

}
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func editMarker () {
        
        if !(self.markerKey.isEmpty){
            let storyb = self.storyboard?.instantiateViewController(withIdentifier: "FirstViewController")
            storyb?.setValue(self.markerKey as! String, forKey: "dbkey")
            
            self.markerKey = ""
            
            self.performSegue(withIdentifier: "mapsToFirst", sender: self)
        }
        
        
    }
    
    
    func deleteMarker () {
        if !(self.markerKey.isEmpty) {
            Database.database().reference().child("calculations").child(markerKey as! String).removeValue()
            self.markerKey = ""
            self.viewDidLoad()
        }
        
    }
    
   

}
