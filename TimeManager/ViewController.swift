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
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let toDate = Date()
        let fromDate = Date(timeIntervalSince1970: toDate.timeIntervalSince1970 - 60 * 60 * 24 * 100)
        CalendarManager.shared.getEvent(from: "Tyme2", fromDate: fromDate, toDate: toDate)
    }
}

