//
//  TimeSummaryManager.swift
//  TimeManager
//
//  Created by Huanrong on 3/13/19.
//  Copyright © 2019 Huanrong. All rights reserved.
//

import UIKit

struct TimeSummaryManager {
    static var shared = TimeSummaryManager()
    let dispatch: DispatchQueue

    private init() {
        dispatch = DispatchQueue(label: "com.caohr.timeManager")
    }

    public func start() {}

    public func stop() {}
}

// Calender
extension TimeSummaryManager {}
