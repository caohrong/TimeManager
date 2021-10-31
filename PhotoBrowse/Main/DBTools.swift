//
//  DBTools.swift
//  PhotoBrowse
//
//  Created by Huanrong on 10/31/21.
//

import Foundation
import Photos
import FMDB

class DBTools : NSObject {
    fileprivate var db:FMDatabase!
    
    override init() {
        var fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        fileURL.appendPathComponent("db.sqlite3")
        db = FMDatabase(url: fileURL)
    }
    
    func saveAllPhotosResult(fetchResult: PHFetchResult<PHAsset>) {
        guard db.open() else {
            print("Unable to open database")
            return
        }

        do {
            try db.executeUpdate("create table if not exists Photos(id integer primary key autoincrement, identifier test, checkDate text)", values: nil)
            
            //TODO
            //确定是否需要更新
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dateString = formatter.string(from: Date())
            
//            for i in 0..<fetchResult.count {
//                let asset:PHAsset = fetchResult.object(at: i)
//                try db.executeUpdate("insert into Photos (identifier, checkDate) values (?, ?)", values: [asset.localIdentifier, dateString])
//            }
            
            let rs = try db.executeQuery("select count(*) from Photos", values: nil)
            while (rs.next()) {
                print(rs.int(forColumn: "count"))
            }
        } catch {
            print("报错: \(error.localizedDescription)")
        }

        db.close()
    }
    
//    func saveAllPhotosResult(fetchResult: PHFetchResult<PHAsset>) {
//        print("saveAllPhotosResult")
//        var dburl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        dburl.appendPathComponent("db.sqlite3")
//        print(dburl.absoluteString)
//
//        do {
//            db = try Connection(dburl.absoluteString)
//        } catch {
//            print(error)
//        }
//
//        //Create Table
//        let t_photos = Table("Photos")
//        let id = Expression<String>("id")
//        let checkDate = Expression<String?>("checkDate")
//
//        do {
////            try db.run(t_photos.create { t in
////            t.column(id, primaryKey: true)
////            t.column(checkDate)
////            })
//
//            for i in 0..<fetchResult.count {
//                let asset:PHAsset = fetchResult.object(at: i)
//                let insert = t_photos.insert(id <- asset.localIdentifier, checkDate <- "20211031")
//                let rowid = try db.run(insert)
//                print(rowid)
//    //            if let location = asset.location {
//    //                print(location)
//    //            }
//            }
//        } catch {
//            print(error)
//        }
//    }
    
    func addLocationInfoLabel(asset:PHAsset) {
        
    }
}


