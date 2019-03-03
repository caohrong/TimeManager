//
//  Calendar.swift
//  TimeManager
//
//  Created by Huanrong Cao on 3/3/19.
//  Copyright © 2019 Huanrong. All rights reserved.
//

import Foundation
import EventKit

struct CalendarManager {
    static var shared = CalendarManager()
    let store = EKEventStore()
    
    private init() {
        
    }

    func required() {
        store.requestAccess(to: EKEntityType.event) { (request, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            guard request else {
                print()
                return;
            }
            print("有权限....")
        }
    }
    
    func calenderInSystem(name:String) -> EKCalendar? {
        for calendar in store.calendars(for: .event) {
//            print(calendar.title)
            if calendar.title == name {
                return calendar
            }
        }
        return nil
    }
    
    func createEvent(fromTime:Date, toTime:Date, eventName:String) {
        guard let calender = calenderInSystem(name: "Useless") else {
            return
        }
        
        let event = EKEvent(eventStore: store)
        event.title = eventName
        event.startDate = fromTime
        event.endDate = toTime
        event.calendar = calender
        do {
            try store.save(event, span: EKSpan.futureEvents)
        } catch {
            print(error.localizedDescription)
        }
    }
}
