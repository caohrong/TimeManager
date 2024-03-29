//
//  ViewController.swift
//  TimeManager
//
//  Created by Huanrong on 4/8/19.
//  Copyright © 2019 Huanrong. All rights reserved.
//

import CoreLocation
import Mapbox
import UIKit

class HRViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Title"
//        self.navigationController?.pushViewController(OpenGpxTrackerController(), animated: true)

//        let shared = GPXDataManager.shared

        // 39.899767, 116.374322 宣武门
//        let chinaLocation = CLLocationCoordinate2D.init(latitude: 39.899767, longitude: 116.374322)
//        let newLocation = CLLocation(latitude: 39.899767, longitude: 116.374322).undeviatedCoordinates()
//        print("https://www.google.com/maps/place/\(chinaLocation.latitude)+\(chinaLocation.longitude)")
//        print("https://www.google.com/maps/place/\(newLocation.latitude)+\(newLocation.longitude)")

//        let url = URL(string: "mapbox://styles/mapbox/streets-v11")
//        let mapView = MGLMapView(frame: view.bounds, styleURL: url)
//        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        mapView.setCenter(CLLocationCoordinate2D(latitude: 59.31, longitude: 18.06), zoomLevel: 9, animated: false)
//        view.addSubview(mapView)
//        self.navigationController?.pushViewController(MapboxController(), animated: true)

        let calendar = Calendar.current
        var oneDataAgaComponents = DateComponents()
        oneDataAgaComponents.day = -1
        let onedayAgo = calendar.date(byAdding: oneDataAgaComponents, to: Date())
        var oneYearFromNowComponents = DateComponents()
        oneYearFromNowComponents.year = -1
        let oneYearFromNow = calendar.date(byAdding: oneYearFromNowComponents, to: Date())

        let shared = HealthDataManager.shared.sleepData()
    }
}
