//
//  LocationHelper.swift
//  Location
//
//  Created by Vibhor Chaudhary on 14/04/20.
//  Copyright © 2020 Vibhor Chaudhary. All rights reserved.
//

import UIKit
import CoreLocation

class LocationHelper: NSObject, CLLocationManagerDelegate {
    
    private var mLocationManager: CLLocationManager?
    
    var userCurrentLocation: ((_ location: CLLocation?) -> Void)?
    
    override init() {
        mLocationManager = CLLocationManager()
        mLocationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    public func setDelegate() {
        mLocationManager?.delegate = self
    }
    
    public func getUserCurrentLocation(message: String){
        let status =  CLLocationManager.authorizationStatus()
        if(status == .denied || status == .restricted || !CLLocationManager.locationServicesEnabled()){
            showLocationPermisisonPopUp(message: message)
            return
        }
        
        if(status == .notDetermined){
            if let location =  mLocationManager?.location {
                if(self.userCurrentLocation != nil){
                    self.userCurrentLocation!(location)
                } else {
                    mLocationManager?.requestWhenInUseAuthorization()
                }
            } else {
                mLocationManager?.requestWhenInUseAuthorization()
            }
            return
        }
        
        if let location =  mLocationManager?.location {
            if(self.userCurrentLocation != nil){
                self.userCurrentLocation!(location)
            }
        } else {
            mLocationManager?.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            mLocationManager?.requestLocation()
            print("user allow app to get location data when app is active or in background")
            break
        case .authorizedWhenInUse:
            mLocationManager?.requestLocation()
            print("user allow app to get location data only when app is active")
            break
        case .denied:
            if(userCurrentLocation != nil){
                userCurrentLocation!(nil)
            }
            print("user tap 'disallow' on the permission dialog, cant get location data")
            break
        case .restricted:
            if(userCurrentLocation != nil){
                userCurrentLocation!(nil)
            }
            print("parental control setting disallow location data")
            break
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            if(userCurrentLocation != nil){
                userCurrentLocation!(location)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if(userCurrentLocation != nil){
            userCurrentLocation!(nil)
        }
    }
    
    private func showLocationPermisisonPopUp(message: String){
        let alert = UIAlertController(title: "Permisison Required", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.cancel, handler: {
            action in
            if(self.userCurrentLocation != nil){
                self.userCurrentLocation!(nil)
            }
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            alert.dismiss(animated: true, completion: nil)
        }))
        
//        var topCont = UIApplication.shared.windows.first { $0.isKeyWindow }
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
                topController.present(alert, animated: true, completion: nil)
            }
            // topController should now be your topmost view controller
        }
        //        UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
    }
}
