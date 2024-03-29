//
//  Calendar.swift
//  TimeManager
//
//  Created by Huanrong Cao on 3/3/19.
//  Copyright © 2019 Huanrong. All rights reserved.
//

import EventKit
import Foundation

struct CalendarManager {
    static var shared = CalendarManager()
    let store = EKEventStore()
    let calenderName = "Useless"
    private init() {
        required()
    }

    func required() {
        store.requestAccess(to: EKEntityType.event) { request, error in
            if let error = error {
                print(error.localizedDescription)
            }
            guard request else {
                print()
                return
            }
            print("有权限....")
        }
    }

    func checkCalenderExist() {
        if calenderInSystem(name: calenderName) == nil {}
    }

    func calenderInSystem(name: String) -> EKCalendar? {
        for calendar in store.calendars(for: .event) {
//            print("▬▬▬▬▬▬▬▬▬▬ஜ۩۞۩ஜ▬▬▬▬▬▬▬▬▬▬▬▬▬▬"+calendar.title)
            if calendar.title == name {
                return calendar
            }
        }
        return nil
    }

    // 修复睡眠时间不连续的问题
    func fixEventWith(fromTime: Date, toTime: Date, eventName _: String, calendarName: String) {
        guard let calender = calenderInSystem(name: calendarName) else { return }

        let fixableStartTime = Date(timeIntervalSince1970: fromTime.timeIntervalSince1970 - 7200)
        let fixableEndTime = Date(timeIntervalSince1970: toTime.timeIntervalSince1970 + 7200)

        var predicate = store.predicateForEvents(withStart: fromTime, end: fixableEndTime, calendars: [calender])
        let events = store.events(matching: predicate)

//        guard events.count > 1 else { return }

        let dataF = DateFormatter()
        dataF.dateFormat = "yyyy-MM-dd HH:mm"
        print("一共找到了\(events.count)个  " + dataF.string(from: fromTime) + dataF.string(from: toTime))
    }

    // 检查事件是不是已经创建
    func checkEventExitst(fromTime: Date, toTime: Date, eventName _: String, calendarName: String) -> Bool {
        guard let calender = calenderInSystem(name: calendarName) else { return false }

//        let fixableStartTime = Date(timeIntervalSince1970: fromTime.timeIntervalSince1970 - 3600)
//        let fixableEndTime = Date(timeIntervalSince1970: toTime.timeIntervalSince1970 + 3600)
//
        var predicate = store.predicateForEvents(withStart: fromTime, end: toTime, calendars: [calender])
        let events = store.events(matching: predicate)

        let dataF = DateFormatter()
        dataF.dateFormat = "yyyy-MM-dd HH:mm"

//        print("一共找到了\(events.count)个  " + dataF.string(from: fromTime) + dataF.string(from: toTime))
        if events.count >= 1, events.last?.title == "Sleeping" { return true } else { return false }
    }

    func deleteEventWithName(name: String, calendar: String, fromTime: Date, toTime: Date) {
        guard let calendar = calenderInSystem(name: calendar) else { return }

        let predicate = store.predicateForEvents(withStart: fromTime, end: toTime, calendars: [calendar])
        let events = store.events(matching: predicate)
        print("\(fromTime.printer()) + \(toTime.printer())")
        guard events.count > 1 else { return }

        let filterEvent = events.filter { event -> Bool in
            event.title == name ? true : false
        }
        print("筛选\(filterEvent.count)条记录")
        for event in filterEvent {
            try! store.remove(event, span: EKSpan.thisEvent)
            print(event)
        }
    }

    func createEvent(fromTime: Date, toTime: Date, eventName: String) {
        guard let calender = calenderInSystem(name: calenderName) else { return }
        guard !checkEventExitst(fromTime: fromTime, toTime: toTime, eventName: eventName, calendarName: calenderName) else { return }

        let event = EKEvent(eventStore: store)
        event.title = eventName
        event.startDate = fromTime
        event.endDate = toTime
        event.calendar = calender
        do {
            event.printer()
            try store.save(event, span: EKSpan.futureEvents)
        } catch {
            print(error.localizedDescription)
        }
    }

    func deletedEvent(name _: String, inCalender: String) {
        guard let calender = calenderInSystem(name: inCalender) else {
            return
        }
        do {
            try store.removeCalendar(calender, commit: true)
        } catch {
            print(error.localizedDescription)
        }
    }

    func getEvent(from name: String, fromDate: Date, toDate: Date) -> [String: Double]? {
        guard let calender = calenderInSystem(name: name) else {
            return nil
        }
        var predicat = store.predicateForEvents(withStart: fromDate, end: toDate, calendars: [calender])
        // Fetch all events that match the predicate.
        let events: [EKEvent]? = store.events(matching: predicat)
        guard let temp_events = events else {
            return nil
        }
        var time_count: [String: Double] = [:]
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
            print("\(value.key) -- \(value.value / 3600)小时")
        }
        return time_count
    }

    func event_in_twoday(fromData _: Date, endDate _: Date) -> Bool {
        return false
    }

    func date_to_string(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
