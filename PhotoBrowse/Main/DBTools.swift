//
//  DBTools.swift
//  PhotoBrowse
//
//  Created by Huanrong on 10/31/21.
//

import FMDB
import Foundation
import Photos

class DBTools: NSObject {
    fileprivate var db: FMDatabase!

    override init() {
        var fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        fileURL.appendPathComponent("db.sqlite3")
        print("🌵SQLite:\(fileURL.path)")
        db = FMDatabase(url: fileURL)
    }

    func saveAllPhotosResult(fetchResult: PHFetchResult<PHAsset>) {
        print(Thread.current)
        guard db.open() else {
            print("Unable to open database")
            return
        }
        do {
            try db.executeUpdate("create table if not exists Photos(id integer primary key autoincrement, identifier text, checkDate text)", values: nil)

            // TODO:
            // 确定是否需要更新

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dateString = formatter.string(from: Date())

            for i in 0 ..< fetchResult.count {
//                print(i)
                let asset: PHAsset = fetchResult.object(at: i)

                let rs = try db.executeQuery("select identifier checkDate from Photos", values: [asset.localIdentifier])

                if rs.hasAnotherRow() { continue }

                try db.executeUpdate("insert into Photos (identifier, checkDate) values (?, ?)", values: [asset.localIdentifier, dateString])
//                print("插入数据:\(i)")
            }
            print("🏆插入数据完成----------")
        } catch {
            print("报错: \(error.localizedDescription)")
        }

        db.close()
    }

    func addLocationInfoLabel(asset: PHAsset, name: String) {
        guard db.open() else {
            print("Unable to open database")
            return
        }
        do {
            try db.executeUpdate("create table if not exists locationLabel(id integer primary key autoincrement, identifier text, labelName text, latitude text, longitude text, speed text, altitude text, course text, date text)", values: nil)

            guard let location = asset.location else { return }

            try db.executeUpdate("insert into locationLabel (identifier, labelName, latitude, longitude, speed, altitude, course, date) values (?, ?, ?, ?, ?, ?, ?, ?)", values: [asset.localIdentifier, name, location.coordinate.latitude, location.coordinate.longitude, location.speed, location.altitude, location.course, location.timestamp.timeIntervalSince1970])
        } catch {
            print("报错: \(error.localizedDescription)")
        }

        db.close()
    }
}
