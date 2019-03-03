//
//  ViewController.swift
//  TimeManager
//
//  Created by Huanrong on 2/27/19.
//  Copyright © 2019 Huanrong. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        LocationManager.shared.start(auto_stop: true)
        
        
        HealthDataManager.shared.sleepData()
        
        CalendarManager.shared.required()
        let currentTime = Date()
        let fromTime = Date(timeIntervalSince1970: currentTime.timeIntervalSince1970 - 3600)
        CalendarManager.shared.createEvent(fromTime: fromTime, toTime: currentTime, eventName: "Test")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
}

