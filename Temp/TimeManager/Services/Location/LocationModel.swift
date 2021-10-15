//
//  LocationModel.swift
//  TimeManager
//
//  Created by Huanrong on 4/8/19.
//  Copyright © 2019 Huanrong. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocation {
    var speedFormat:String {
        get {
            return self.speed < 0 ? "·.··" : String(format: "%.2f", (self.speed * 3.6))
        }
    }
    
    var singleAccuracyLevelFormate:String {
        get {
            return "±\(horizontalAccuracy)m"
        }
    }
    
    var singleAccuracyLevel:Int {
        get {
            let kSignalAccuracy6 = 6.0
            let kSignalAccuracy5 = 11.0
            let kSignalAccuracy4 = 31.0
            let kSignalAccuracy3 = 51.0
            let kSignalAccuracy2 = 101.0
            let kSignalAccuracy1 = 201.0
            
            if horizontalAccuracy < kSignalAccuracy6 {
                return 6
            } else if horizontalAccuracy < kSignalAccuracy5 {
                return 5
            } else if horizontalAccuracy < kSignalAccuracy4 {
                return 4
            } else if horizontalAccuracy < kSignalAccuracy3 {
                return 3
            } else if horizontalAccuracy < kSignalAccuracy2 {
                return 2
            } else if horizontalAccuracy < kSignalAccuracy1 {
                return 1
            } else{
                return 0
            }
        }
        
    }
}

extension CLLocation : CustomStringConvertible {
    open override var description: String {
        let latFormat = String(format: "%.6f", coordinate.latitude)
        let lonFormat = String(format: "%.6f", coordinate.longitude)
        let altFormat = String(format: "%.2f", altitude)
        return "(\(latFormat),\(lonFormat)) · altitude: \(altFormat)m"
    }
}

struct LocationModel {
    var coordinate:CLLocationCoordinate2D     //坐标
    var signalAccuracyLevel:String               //精度
    var altitude:CLLocationDistance         //海拔
    var speedFormat:String        //速度描述信息
    var speed:Double              //速度
}

