//
//  DatePrinter.swift
//  TimeManager
//
//  Created by Huanrong Cao on 7/10/19.
//  Copyright © 2019 Huanrong. All rights reserved.
//

import Foundation
import EventKit
protocol Printable {
    func printer() -> String
}

extension Date : Printable {
    func printer() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.string(from: self)
    }
}
extension EKEvent :Printable {
    func printer() -> String {
        let stringValue = "Event:【"+title+"】"+startDate.printer()+"_"+endDate.printer()
        print(stringValue)
        return stringValue
    }
}
