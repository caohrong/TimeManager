//
//  ViewController.swift
//  TimeManager
//
//  Created by Huanrong on 4/8/19.
//  Copyright © 2019 Huanrong. All rights reserved.
//

import UIKit

class HRViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Title"
        
        self.navigationController?.pushViewController(OpenGpxTrackerController(), animated: true)
    }

}
