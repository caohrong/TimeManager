//
//  LocationDataManager.swift
//  TimeManager
//
//  Created by Huanrong on 2/27/19.
//  Copyright © 2019 Huanrong. All rights reserved.
//

import Foundation
import SQLite
import CoreLocation

struct DataBaserTableHelper {
    let location_table = Table("R_LOCATION")
    let id = Expression<Int64>("id")
    let timestamp = Expression<Double>("timestamp")
    let latitude = Expression<Double>("latitude")
    let longitude = Expression<Double>("longitude")
    let altitude = Expression<Double>("altitude")
}

extension DatabaseMamager {
    func create_location_table() {
        let helper = DataBaserTableHelper()
        do {
            try db?.run(helper.location_table.create(block: { (t) in
                t.column(helper.id, primaryKey: true)
                t.column(helper.timestamp)
                t.column(helper.latitude)
                t.column(helper.longitude)
                t.column(helper.altitude)
            }))
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func insertLocation(location:CLLocation) {
        guard case(true) = needUpdateLocation(location: location) else {
            print("❌不需要更新")
            return;
        }
        let helper = DataBaserTableHelper()
        let insert = helper.location_table.insert(helper.timestamp <- location.timestamp.timeIntervalSince1970, helper.latitude <- location.coordinate.latitude, helper.longitude <- location.coordinate.longitude, helper.altitude <- location.altitude)
        do {
            try db?.run(insert)
            print("✅位置插入成功")
        } catch {
            print("插入数据错误▬▬▬▬▬▬▬▬▬▬ஜ۩۞۩ஜ▬▬▬▬▬▬▬▬▬▬▬▬▬▬")
        }
    }
    
    private func needUpdateLocation(location:CLLocation) -> Bool {
        if let latest_location = latestLocationInDataBase() {
            //distance max than 200 meters
            let distance = latest_location.distance(from: location)
//            print(distance)
            if distance > 200 {
                return true
            }
            //time max than 1 hours
            let time = latest_location.timestamp.timeIntervalSince1970 - Date().timeIntervalSince1970
//            print(time)
            if time > 60 * 60 * 6 {
                return true
            }
        }
        return false
    }
    
    func latestLocationInDataBase() -> CLLocation? {
        let helper = DataBaserTableHelper()
        do {
            if let max_id = try db?.scalar(helper.location_table.select(helper.id.max)) {
//                print("现在总共\(max_id)条位置信息")
                let query = helper.location_table.filter(helper.id == max_id)
                if let user = try db?.pluck(query) {
                    let latitude = user[helper.latitude]
                    let longitude = user[helper.longitude]
                    let altitude = user[helper.altitude]
                    let date = Date.init(timeIntervalSince1970: user[helper.timestamp])
                    let location = CLLocation(coordinate: CLLocationCoordinate2DMake(latitude, longitude), altitude: altitude, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: date)
                    return location
                }
            }
        } catch  {
            print(error.localizedDescription);
        }
        return nil
    }
}
