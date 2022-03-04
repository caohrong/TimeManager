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
    static var shared: HealthDataManager = .init()
    typealias completeResult = ([HKSample]?) -> Void
    private let store = HKHealthStore()
    override private init() {
        super.init()
        requestAuth()
    }

    func requestAuth() {
        if #available(iOS 12.0, *) {
            guard HKHealthStore.isHealthDataAvailable() else {
                print("没有health的功能")
                return
            }

            guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
                fatalError("*** Unable to create the requested types ***")
            }

            switch store.authorizationStatus(for: sleepType) {
            case .notDetermined:
                print("还没请求认证")
            case .sharingAuthorized:
                print("已经认证")
            case .sharingDenied:
                print("被拒绝")
            }

            store.requestAuthorization(toShare: nil, read: [sleepType]) { success, error in
                guard success else {
                    // Handle errors here.
                    fatalError("*** An error occurred while requesting authorization: \(error!.localizedDescription) ***")
                }
            }

        } else {
            // Fallback on earlier versions
        }
    }

    // When user click agree App to use HealthData
    func getAuth() {}

    // ma
    func retrievingSleepDate(start: Date, end: Date, complete: completeResult) {
        guard let sampleType = HKCategoryType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) else {
            fatalError("未知的HKCategoryType类型")
        }
        retrievingSleepDate(start: start, end: end, complete: complete)
    }

    func retrievingHealthDate(start: Date, end: Date, type: HKSampleType, complete: @escaping completeResult) {
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: [])
        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) {
            _, results, error in
            if let error = error {
                print(error.localizedDescription)
            }
            complete(results)
        }
        store.execute(query)
    }

    func sleepData() {
        let calendar = Calendar.current

        var oneYearFromNowcomponents = DateComponents()
        oneYearFromNowcomponents.year = -1

        guard let startDate = calendar.date(byAdding: oneYearFromNowcomponents, to: Date()) else {
            fatalError("error")
        }

        let endDate = Date()

        guard let sampleType = HKCategoryType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) else {
            fatalError("error")
        }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])

        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) {
            _, results, error in
            if let error = error {
                print(error.localizedDescription)
            }
            self.sleepTime(withData: results as? [HKCategorySample] ?? [])
        }
        store.execute(query)
    }

    func sleepTime(withData: [HKCategorySample]) {
        let dataF = DateFormatter()
        dataF.dateFormat = "yyyy-MM-dd HH:mm"

        var dic: [Double: Double] = [:]
        for item in withData {
            let startTimeString = dataF.string(from: item.startDate)
            let endTimeString = dataF.string(from: item.endDate)
            let result = "StartTime:" + startTimeString + "到" + endTimeString
            let type = HKCategoryValueSleepAnalysis(rawValue: item.value)
            switch type! {
            case .inBed:
                let startTime = item.startDate.timeIntervalSince1970
                let endTime = item.endDate.timeIntervalSince1970

                if let tempEndTime = dic[startTime] {
                    if tempEndTime < endTime {
                        dic[startTime] = endTime
                    }
                } else {
                    dic[startTime] = endTime
                }

            case .asleep:
//                print(result + " 睡着了")
                break
            case .awake:
//                print(result + " 醒着的")
                break
            }
        }

        // Test
        var sleepDatas: [HKCategorySample] = []
        for (key, value) in dic {
            let startDate = Date(timeIntervalSince1970: key)
            let endDate = Date(timeIntervalSince1970: value)
            let startTime = dataF.string(from: startDate)
            let endTime = dataF.string(from: endDate)
            let sampe = HKCategorySample(type: HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!, value: HKCategoryValueSleepAnalysis.inBed.rawValue, start: startDate, end: endDate)
            sleepDatas.append(sampe)

            CalendarManager.shared.createEvent(fromTime: startDate, toTime: endDate, eventName: "Sleeping")
        }
    }
}

extension HKCategorySample {
    func sleepDataPrint() {
        let dataF = DateFormatter()
        dataF.dateFormat = "yyyy-MM-dd HH:mm"
    }
}
