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
        dateComponts.hour = 00
        dateComponts.minute = 00
        dateComponts.second = 00
        
        guard let startDate = calendar.date(from: dateComponts) else {
            fatalError("error")
        }
        
        let endDate = calendar.date(from: components)
        
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
    
    func sleepTime(withData:[HKCategorySample]) {
        
        let dataF = DateFormatter()
        dataF.dateFormat = "yyyy-MM-dd HH:mm"
        
        var dic:[Double:Double] = [:]
        for item in withData {
            let startTimeString =  dataF.string(from: item.startDate)
            let endTimeString = dataF.string(from: item.endDate)
            let result = "StartTime:" + startTimeString + "到" + endTimeString
            let type = HKCategoryValueSleepAnalysis(rawValue: item.value)
            switch type! {
            case .inBed:
                let startTime = item.startDate.timeIntervalSince1970
                let endTime = item.endDate.timeIntervalSince1970
                
                if let tempEndTime = dic[startTime] {
                    if tempEndTime < endTime  {
                        dic[startTime] = endTime;
                    }
                } else {
                    dic[startTime] = endTime
                }
                
                break
            case .asleep:
//                print(result + " 睡着了")
                break
            case .awake:
//                print(result + " 醒着的")
                break
            }
        }
        
        //Test
        var sleepDatas:[HKCategorySample] = []
        for (key, value) in dic {
            let startDate = Date(timeIntervalSince1970: key)
            let endDate = Date(timeIntervalSince1970: value)
            let startTime = dataF.string(from: startDate)
            let endTime = dataF.string(from: endDate)
//            print(startTime + "到" + endTime)
            let sampe = HKCategorySample(type: HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!, value: HKCategoryValueSleepAnalysis.inBed.rawValue, start: startDate, end: endDate)
            sleepDatas.append(sampe)
            
            CalendarManager.shared.createEvent(fromTime: startDate, toTime: endDate, eventName: "Sleeping")
        }
        
//        for singleValue in dic {
//            var tempValues = singleValue.value
//            var currentMixitem:HKCategorySample = tempValues.remove(at: 0)
//            for item in tempValues {
//                let range = item.startDate.timeIntervalSince1970 - item.endDate.timeIntervalSince1970
//                if currentMixitem.startDate.timeIntervalSince1970 - item.endDate.timeIntervalSince1970 < range {
//                    currentMixitem = item
//                }
//            }
//            let hours = (currentMixitem.endDate.timeIntervalSince1970 - currentMixitem.startDate.timeIntervalSince1970) / 3600
//            let dataF = DateFormatter()
//            dataF.dateFormat = "yyyy-MM-dd HH:mm"
//            print("从\(dataF.string(from: currentMixitem.startDate))到\(dataF.string(from: currentMixitem.endDate))睡了\(hours)小时")
//            dicNew[singleValue.key] = currentMixitem
//            CalendarManager.shared.createEvent(fromTime: currentMixitem.startDate, toTime: currentMixitem.endDate, eventName: "Sleeping")
//        }
    }
}


extension HKCategorySample {
    func sleepDataPrint() {
        let dataF = DateFormatter()
        dataF.dateFormat = "yyyy-MM-dd HH:mm"
//        if self.sampleType  {
//            <#code#>
//        }
    }
}


//if case sampelType = item.sampleType {
//    //确定睡眠时间
//    //如果是上午
//    let calendar = Calendar.current
//    //                    let dataComponent = [.year, .month, .day, .hour, .minute]
//    let startDate = item.startDate
//    let endDate = item.startDate
//
//    let startComponent  = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: startDate)
//    let endDateComponent = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: startDate)
//
//    //Get current day Range
//    let currentDayStart:TimeInterval, currentDayEnd:TimeInterval
//    var rangeStartComponent = startComponent
//    rangeStartComponent.hour = 16
//    rangeStartComponent.minute = 00
//    rangeStartComponent.second = 00
//    guard let divideDate = calendar.date(from: rangeStartComponent) else {
//        return
//    }
//    //如果是下午
//    if let hours = startComponent.hour, hours >= 16 {
//        currentDayStart = divideDate.timeIntervalSince1970
//        currentDayEnd = currentDayStart + 60 * 60 * 24;
//    } else {
//        currentDayEnd = divideDate.timeIntervalSince1970
//        currentDayStart = currentDayEnd - 60 * 60 * 24;
//    }
//
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "yyyy-MM-dd"
//    let currentDateKey = dateFormatter.string(from: Date(timeIntervalSince1970: currentDayStart))
//    print(currentDateKey);
//    if var existArrayValue = dic[currentDateKey] {
//        existArrayValue.append(item)
//        dic[currentDateKey] = existArrayValue
//    } else {
//        dic[currentDateKey] = [item]
//    }
//}

