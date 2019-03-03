//
//  HealthManger.swift
//  TimeManager
//
//  Created by Huanrong on 2/27/19.
//  Copyright © 2019 Huanrong. All rights reserved.
//

import Foundation
import HealthKit

class HealthDataManager: NSObject {
    static var shared:HealthDataManager = HealthDataManager()
    private let store = HKHealthStore()
    private override init() {
        super.init()
        requestAuth()
    }
    
    func requestAuth() {
        if #available(iOS 12.0, *) {
            
            guard HKHealthStore.isHealthDataAvailable() else {
                print("没有health的功能")
                return;
            }
            
            guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
                    fatalError("*** Unable to create the requested types ***")
            }
            
            switch store.authorizationStatus(for: sleepType) {
            case .notDetermined:
                print("还没请求认证")
                break
            case .sharingAuthorized:
                print("已经认证")
                break
            case .sharingDenied:
                print("被拒绝")
                break
            }
            
            store.requestAuthorization(toShare: nil, read: [sleepType]) { (success, error) in
                guard success else {
                    // Handle errors here.
                    fatalError("*** An error occurred while requesting authorization: \(error!.localizedDescription) ***")
                }
//                self.sleepData()
            }
            
        } else {
            // Fallback on earlier versions
        }
    }
    
    func sleepData() {
        
        let calendar = Calendar.current
        
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
        var dateComponts = DateComponents()
        dateComponts.year = 2019
        dateComponts.month = 1
        dateComponts.day = 1
        dateComponts.hour = 15
        dateComponts.minute = 00
        dateComponts.second = 00
        
        guard let startDate = calendar.date(from: dateComponts) else {
            fatalError("error")
        }
        
        let endDate = calendar.date(from: components)
        print("\(startDate)\(endDate)")
        
        guard let sampleType = HKCategoryType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) else {
            fatalError("error")
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) {
            query, results, error in
            if let error = error {
                print(error.localizedDescription)
            }
            self.sleepTime(withData: results as? [HKCategorySample] ?? [])
        }
        store.execute(query)
    }
    
    func sleepTime(withData:[HKCategorySample]) -> HKCategorySample? {
        guard let results = withData as? [HKCategorySample] else { return nil }
        for item in results {
            let type = item.value
            switch type {
            case 0:
                //在床上
                //                    print("In the bed.........")
                if item.sampleType.identifier == "HKCategoryTypeIdentifierSleepAnalysis" {
                    let hours = (item.endDate.timeIntervalSince1970 - item.startDate.timeIntervalSince1970) / 3600
                    let dataF = DateFormatter()
                    dataF.dateFormat = "yyyy-MM-dd HH:mm"
                    print("从\(dataF.string(from: item.startDate))到\(dataF.string(from: item.endDate))睡了\(hours)小时")
                    CalendarManager.shared.createEvent(fromTime: item.startDate, toTime: item.endDate, eventName: "Sleeping Time")
                }
                break
            case 1:
                //                        print("睡着了")
                break
            case 2:
                //                        print("醒着的")
                break
            default:
                //                        print("其他")
                break
            }
        }
    }
}
