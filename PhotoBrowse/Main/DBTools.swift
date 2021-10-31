//
//  DBTools.swift
//  PhotoBrowse
//
//  Created by Huanrong on 10/31/21.
//

import Foundation
import Photos
import SQLite

class DBTools : NSObject {
    fileprivate var db:Connection!
    
    override init() {
        
    }
    
    func saveAllPhotosResult(fetchResult: PHFetchResult<PHAsset>) {
        print("saveAllPhotosResult")
        var dburl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        dburl.appendPathComponent("db.sqlite3")
        print(dburl.absoluteString)
        
        do {
            db = try Connection(dburl.absoluteString)
        } catch {
            print(error)
        }
        
        //Create Table
        let t_photos = Table("Photos")
        let id = Expression<String>("id")
        let checkDate = Expression<String?>("checkDate")

        do {
//            try db.run(t_photos.create { t in
//            t.column(id, primaryKey: true)
//            t.column(checkDate)
//            })
            
            for i in 0..<fetchResult.count {
                let asset:PHAsset = fetchResult.object(at: i)
                let insert = t_photos.insert(id <- asset.localIdentifier, checkDate <- "20211031")
                let rowid = try db.run(insert)
                print(rowid)
    //            if let location = asset.location {
    //                print(location)
    //            }
            }
        } catch {
            print(error)
        }
    }
    
    func addLocationInfoLabel(asset:PHAsset) {
        
    }
}


