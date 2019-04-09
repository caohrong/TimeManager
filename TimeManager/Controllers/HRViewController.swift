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
//        self.navigationController?.pushViewController(OpenGpxTrackerController(), animated: true)
        
        let shared = GPXDataManager.shared
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super .touchesBegan(touches, with: event)
        print("▬▬▬▬▬▬▬▬▬▬ஜ۩۞۩ஜ▬▬▬▬▬▬▬▬▬▬▬▬▬▬");
    }
}
