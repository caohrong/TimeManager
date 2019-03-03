//
//  DatabaseMamager.swift
//  TimeManager
//
//  Created by Huanrong on 2/27/19.
//  Copyright © 2019 Huanrong. All rights reserved.
//

import UIKit
import SQLite

class DatabaseMamager {
    var db:Connection?
    static var shared:DatabaseMamager = DatabaseMamager()
    private init() {
        let fileManager = FileManager.default;
        if var path = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            path.appendPathComponent("db.sqlite3")
            print(path.absoluteURL)
            self.db = try? Connection(path.absoluteString)
//            create_table()
        }
    }
    
    private func create_table() {
        create_location_table()
    }
}
