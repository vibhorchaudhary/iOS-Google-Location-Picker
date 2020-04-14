//
//  ViewController.swift
//  Location
//
//  Created by Vibhor Chaudhary on 14/04/20.
//  Copyright © 2020 Vibhor Chaudhary. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps

class ViewController: BaseViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    @IBOutlet var googleMaps: GMSMapView!
    
    @IBOutlet var mapPinIv: UIImageView!
    
    @IBOutlet var userAddressLabel: UILabel!
    
    @IBOutlet var cardView: CardView!
    
    private var mLocationHelper: LocationHelper = LocationHelper()
    
    private var didMapViewChangeCalled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        // Do any additional setup after loading the view.
        
        setLocationDetails()
        initGoogleMaps()
    }
    
    
    func onBackPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // Current Location Methods start
    func setLocationDetails() {
        self.mLocationHelper.setDelegate()
        
        getUserCurrentLocation()
        
        self.mLocationHelper.getUserCurrentLocation(message: "Application needs location permission to show your current location on maps.")
    }
    
    func getUserCurrentLocation() {
        mLocationHelper.userCurrentLocation =  { (location: CLLocation?) in
            if let currentLocation = location {
                self.updateViewsWhenLocationIsReceived(location: currentLocation)
            } else {
                self.updateViewsWhenLocationIsNull()
            }
        }
    }
    
    func updateViewsWhenLocationIsReceived(location : CLLocation?) {
        
        guard let currLocation = location else {
            return
        }
        
        debugPrint("Current user location geocods are : \(String(describing: location))")
        let camera = GMSCameraPosition.init(target: currLocation.coordinate , zoom: 15)
        self.googleMaps.animate(to: camera)
    }
    
    func updateViewsWhenLocationIsNull() {
        debugPrint("did not find user current location")
    }
    // Current Location Methods ends
    
    
    // Google Maps Methods start
    func initGoogleMaps() {
        googleMaps.isMyLocationEnabled = true
        googleMaps.settings.myLocationButton = true
        googleMaps.delegate = self
        googleMaps.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        didMapViewChangeCalled = true
        cardView.isHidden = true
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        if(didMapViewChangeCalled) {
            reverseGeocodeCoordinate(position.target)
            didMapViewChangeCalled = false
        }
    }
    
    private func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            guard let address = response?.firstResult(), let lines = address.lines else {
                return
            }
            let userAddressString = lines.joined(separator: "\n")
            debugPrint(userAddressString)
            self.userAddressLabel.text = userAddressString
            self.cardView.isHidden = false
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
        }
    }
}
