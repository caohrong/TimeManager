//
//  TodayViewController.swift
//  TimeManager_Widget
//
//  Created by Huanrong on 2/27/19.
//  Copyright © 2019 Huanrong. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        LocationManager.shared.start(auto_stop: true)
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        print("▬▬▬▬▬▬▬▬▬▬ஜ۩۞۩ஜ▬▬▬▬▬▬▬▬▬▬▬▬▬▬组件更新")
        let defaults = UserDefaults(suiteName: "group.TimeManager")
        defaults?.set(500, forKey: "key")
        defaults?.synchronize()
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
