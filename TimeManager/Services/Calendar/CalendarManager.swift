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
    let calenderName = "Useless"
    private init() {
        required()
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
    
    func checkCalenderExist() {
        if calenderInSystem(name: calenderName) == nil {
            
        }
    }
    
    func calenderInSystem(name:String) -> EKCalendar? {
        for calendar in store.calendars(for: .event) {
            print("▬▬▬▬▬▬▬▬▬▬ஜ۩۞۩ஜ▬▬▬▬▬▬▬▬▬▬▬▬▬▬"+calendar.title)
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
    
    func deletedEvent(name:String) {
        guard let calender = calenderInSystem(name: "Useless") else {
            return
        }
        do {
            try store.removeCalendar(calender, commit: true)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getEvent(from name:String, fromDate:Date, toDate:Date) -> [String:Double]? {
        guard let calender = calenderInSystem(name: name) else {
            return nil
        }
        var predicat = store.predicateForEvents(withStart: fromDate, end: toDate, calendars: [calender])
        // Fetch all events that match the predicate.
        let events: [EKEvent]? =  store.events(matching: predicat)
        guard let temp_events = events else {
            return nil
        }
        var time_count:[String:Double] = [:]
        for event in temp_events {
//            print(event.eventIdentifier)
            guard let startDate = event.startDate, let endDate = event.endDate else {
                return nil
            }
            if event_in_twoday(fromData: startDate, endDate: endDate) {
            } else {
                let time_long = endDate.timeIntervalSince1970 - startDate.timeIntervalSince1970
                if let value = time_count[date_to_string(date: startDate)] {
                    time_count[date_to_string(date: startDate)] = value + time_long
                } else {
                    time_count[date_to_string(date: startDate)] = time_long
                }
            }
        }
        for value in time_count {
            print("\(value.key) -- \(value.value/3600)小时")
        }
        return time_count;
    }
    
    func event_in_twoday(fromData:Date, endDate:Date) -> Bool {
        
        return false
    }
    
    func date_to_string(date:Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from:date)
    }
}
