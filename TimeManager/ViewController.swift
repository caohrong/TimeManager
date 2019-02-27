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
        
        let defaults = UserDefaults(suiteName: "group.TimeManager") // this is the name of the group we added in "App Groups"
        defaults?.synchronize()
        
        print(defaults?.integer(forKey: "key"))
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
}

