//
//  LocationManager.swift
//  TimeManager
//
//  Created by Huanrong on 2/27/19.
//  Copyright © 2019 Huanrong. All rights reserved.
//

import UIKit
import CoreLocation

class LocationManager: NSObject {
    static var shared:LocationManager = LocationManager()
    private override init() {
        super.init()
        self.enableLocationServices()
        locationManager.delegate = self
    }
    
    weak var delegate: CLLocationManagerDelegate? {
        didSet {
            locationManager.delegate = delegate
        }
    }
    
    fileprivate let locationManager:CLLocationManager = {
        let manager = CLLocationManager()
        manager.requestAlwaysAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 2 //meters
        manager.headingFilter = 1 //degrees (1 is default)
        manager.pausesLocationUpdatesAutomatically = false
        if #available(iOS 9.0, *) {
            manager.allowsBackgroundLocationUpdates = true
        }
        return manager;
    }()
}

//request auth
extension LocationManager {
    func enableLocationServices() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            print("用户没有选择位置更新");
            self.locationManager.requestAlwaysAuthorization()
            break
            
        case .restricted, .denied:
            print("2允许永久访问地理位置权限");
            // Disable location features
            //            disableMyLocationBasedFeatures()
            break
            
        case .authorizedWhenInUse:
            print("3允许永久访问地理位置权限");
            // Enable basic location features
            //            enableMyWhenInUseFeatures()
            break
            
        case .authorizedAlways:
            //权限正常
            break
        }
    }
}

//Public Function
extension LocationManager {
    func start(auto_stop:Bool) {
        locationManager.startUpdatingLocation()
        if auto_stop {
            let mainQueue = DispatchQueue.main
            let deadline = DispatchTime.now() + .seconds(10)
            mainQueue.asyncAfter(deadline: deadline) {
                print("▬▬▬▬▬▬▬▬▬▬ஜ۩۞۩ஜ▬▬▬▬▬▬▬▬▬▬▬▬▬▬定时到");
                self.stop()
            }
        }
    }
    func stop() {
        print("▬▬▬▬▬▬▬▬▬▬ஜ۩۞۩ஜ▬▬▬▬▬▬▬▬▬▬▬▬▬▬停止更新位置");
        locationManager.stopUpdatingLocation()
    }
    
    func startHeading() {
        locationManager.startUpdatingHeading()
    }
}

//Delegate
extension LocationManager : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print("位置更新-----------");
        let location = locations[0]
//        print("▬▬▬▬▬▬▬▬▬▬ஜ۩۞۩ஜ▬▬▬▬▬▬▬▬▬▬▬▬▬▬\(location.coordinate.latitude)---\(location.coordinate.longitude)")
        
//        guard let mode = locations.last else { return }
//        DatabaseMamager.shared.insertLocation(location: mode)
    }
    
    func locationManager(_ manager: CLLocationManager,
                                     didChangeAuthorization status: CLAuthorizationStatus) {   switch status {
    case .restricted, .denied:
        // Disable your app's location features
        //        disableMyLocationBasedFeatures()
        break
    case .authorizedWhenInUse:
        // Enable only your app's when-in-use features.
        //        enableMyWhenInUseFeatures()
        break
    case .authorizedAlways:
        // Enable any of your app's location services.
        //        enableMyAlwaysFeatures()
        break
        
    case .notDetermined:
        break
        }
    }
}
