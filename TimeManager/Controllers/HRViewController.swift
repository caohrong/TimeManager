//
//  ViewController.swift
//  TimeManager
//
//  Created by Huanrong on 4/8/19.
//  Copyright © 2019 Huanrong. All rights reserved.
//

import UIKit
import CoreLocation

class HRViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Title"
//        self.navigationController?.pushViewController(OpenGpxTrackerController(), animated: true)
        
//        let shared = GPXDataManager.shared
        
        //39.899767, 116.374322 宣武门
        let chinaLocation = CLLocationCoordinate2D.init(latitude: 39.899767, longitude: 116.374322)
        let newLocation = CLLocation(latitude: 39.899767, longitude: 116.374322).undeviatedCoordinates()
        print("https://www.google.com/maps/place/\(chinaLocation.latitude)+\(chinaLocation.longitude)")
        print("https://www.google.com/maps/place/\(newLocation.latitude)+\(newLocation.longitude)")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super .touchesBegan(touches, with: event)
        print("▬▬▬▬▬▬▬▬▬▬ஜ۩۞۩ஜ▬▬▬▬▬▬▬▬▬▬▬▬▬▬");
    }
}
