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
        
        for i in 0..<40 {
            let asset:PHAsset = fetchResult.object(at: i);
            print(asset)
        }
        
    }
}


