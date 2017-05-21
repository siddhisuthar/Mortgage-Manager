//
//  FirstViewController.swift
//  Mortgage Manager
//
//  Created by Siddhi Suthar on 5/17/17.
//  Copyright © 2017 Siddhi. All rights reserved.
//

import UIKit
import DropDown
import CoreLocation
import GoogleMaps
import Firebase
import FirebaseDatabase

class FirstViewController: UIViewController {

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var propertyType: UIButton!
    let selectPropertyType = DropDown()
    @IBOutlet weak var street: UITextField!
    @IBOutlet weak var city: UITextField!
    @IBOutlet weak var selectState: UIButton!
    @IBOutlet weak var zipcode: UITextField!
    let selectStateDropdown = DropDown()
    @IBOutlet weak var housePrice: UITextField!
    @IBOutlet weak var annualInterestRate: UITextField!
    @IBOutlet weak var downPaymentAmount: UITextField!
    @IBOutlet weak var monthlyPayment: UILabel!
    @IBOutlet weak var mortgageLoanLength: UIButton!
    let selectLoanLength = DropDown()
    
    var lati : Double = 0.0
    var long : Double = 0.0
   
    var coordinate = CLLocationCoordinate2D()
    var geocoder = CLGeocoder()
   
    
    @IBAction func selectPropertyType(_ sender: Any) {
        selectPropertyType.show()
    }
    @IBAction func selectMortgageLoanLength(_ sender: Any) {
        selectLoanLength.show()
    }
    @IBAction func selectStateClick(_ sender: Any) {
        selectStateDropdown.show()
    }
    
    @IBAction func calculatePayment(_ sender: Any) {

        let lengthOfMortgageLoan = Int(mortgageLoanLength.titleLabel!.text!)
        
        if ((housePrice.text?.characters.count)!>0 && (downPaymentAmount.text?.characters.count)!>0 && (annualInterestRate.text?.characters.count)!>0 && lengthOfMortgageLoan! != 0) {
           
            let monthlyIntRate: Double = Double(annualInterestRate.text!)! / (12 * 100);
            let months: Double = Double(lengthOfMortgageLoan! * 12);
            
            let loanAmount = Double(housePrice.text!)! - Double(downPaymentAmount.text!)!;
            
            let monthlyPaymentAmount: Double = (loanAmount * monthlyIntRate) / (1 - pow((1+monthlyIntRate), -months))
            
            monthlyPayment.text = String(format: "%.2f", monthlyPaymentAmount)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupStateDropDown()
        setupLoanLengthDropDown()
        setupPropertyTypeDropDown()
    }

    @IBAction func didTapSave(_ sender: Any) {
        if (street.text?.characters.count)!>0 && (city.text?.characters.count)!>0 && (zipcode.text?.characters.count)!>0 {
            
            let address = "\(street.text!), \(city.text!),  \(selectState.titleLabel!.text!) \(zipcode.text!)"
            print("address is: \(address)")
            
            geocoder.geocodeAddressString(address) { (placemarks, error) in
                // Process Response
                self.processResponse(withPlacemarks: placemarks, error: error)
            }
        }
    }
     func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        
        if let error = error {
            print("Unable to Forward Geocode Address (\(error))")
            locationLabel.text = "Unable to Find Location for Address"
            
        } else {
            var location: CLLocation?
            
            if let placemarks = placemarks, placemarks.count > 0 {
                location = placemarks.first?.location
            }
            
            if let location = location {
                coordinate = location.coordinate
                locationLabel.text = "\(coordinate.latitude) \(coordinate.longitude)"
              
                lati = coordinate.latitude
                long = coordinate.longitude
                
                postToDatabase()
                
            } else {
                locationLabel.text = "No Matching Location Found"
            }
        }
    }
    
    
    
    //setting up dropdowns
    func setupStateDropDown(){
    
        selectStateDropdown.anchorView = selectState
        selectStateDropdown.direction = .bottom
        selectStateDropdown.dataSource = ["CA", "AZ", "TX"]
        selectStateDropdown.bottomOffset = CGPoint(x: 0, y: selectState.bounds.height)
        
        selectStateDropdown.selectionAction = { [unowned self] (index, item) in
            self.selectState.setTitle(item, for: .normal)
        }
    }
    func setupLoanLengthDropDown(){
        selectLoanLength.anchorView = mortgageLoanLength
        selectLoanLength.direction = .bottom
        selectLoanLength.dataSource = ["15", "30"]
        selectLoanLength.bottomOffset = CGPoint(x: 0, y: mortgageLoanLength.bounds.height)
        
        selectLoanLength.selectionAction = { [unowned self] (index, item) in
            self.mortgageLoanLength.setTitle(item, for: .normal)
        }
    }
    func setupPropertyTypeDropDown(){
        selectPropertyType.anchorView = propertyType
        selectPropertyType.direction = .bottom
        selectPropertyType.dataSource = ["House", "Townhouse", "Condo"]
        selectPropertyType.bottomOffset = CGPoint(x: 0, y: propertyType.bounds.height)
        
        selectPropertyType.selectionAction = { [unowned self] (index, item) in
            self.propertyType.setTitle(item, for: .normal)
        }
    }
    
    func postToDatabase(){
        
        let calculation: NSDictionary = [
         "streetAddr" : street.text!,
         "cityAddr" : city.text!,
         "stateAddr" : selectState.titleLabel!.text!,
         "zip" : zipcode.text!,
         "hPrice" : housePrice.text!,
         "anr" : annualInterestRate.text!,
         "dPayment" : downPaymentAmount.text!,
         "loanlength" : mortgageLoanLength.titleLabel!.text!,
         "mAmount" : monthlyPayment.text!,
         "latitude": lati,
         "longitude": long]
        
        print("calculation: ")
        print(calculation)
        let databaseRef = FIRDatabase.database().reference()
        databaseRef.child("calculations").childByAutoId().setValue(calculation)
        
//        var s = databaseRef.child("calculations").
//        databaseRef.child("calculations").queryOrderedByKey("snap")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

