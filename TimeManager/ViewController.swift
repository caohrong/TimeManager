//
//  ViewController.swift
//  TimeManager
//
//  Created by Huanrong on 2/27/19.
//  Copyright © 2019 Huanrong. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController {
    let mapView = MKMapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.mapType = MKMapType.standard
        if let location = DatabaseMamager.shared.latestLocationInDataBase() {
            print("\(location.coordinate.latitude)\(location.coordinate.longitude)")
            mapView.region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
        }
        mapView.frame = view.bounds
        view.addSubview(mapView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        LocationManager.shared.start(auto_stop: true)
        
//        let mark = MKAnnotation
//        HealthDataManager.shared.sleepData()
        
//        CalendarManager.shared.required()
//        let currentTime = Date()
//        let fromTime = Date(timeIntervalSince1970: currentTime.timeIntervalSince1970 - 3600)
//        CalendarManager.shared.createEvent(fromTime: fromTime, toTime: currentTime, eventName: "Test")
        
//        CalendarManager.shared.deletedEvent(name: "Sleeping Time")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
}

