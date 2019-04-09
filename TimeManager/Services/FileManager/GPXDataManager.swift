//
//  GPXDataLoader.swift
//  TimeManager
//
//  Created by Huanrong on 4/9/19.
//  Copyright © 2019 Huanrong. All rights reserved.
//

import Foundation
import CoreGPX

/// Load all GPX File From Document Folder
/// Support GPX or gpx format for now on.
class GPXDataManager {
    static var shared:GPXDataManager = GPXDataManager()
    var GPXData:GPXRoot?
    private let queue:DispatchQueue
    
    private init() {
        queue = DispatchQueue(label: "com.caohr.GPXDatamanager")
        self.notificationRegister()
        queue.async {
            self.GPXData = self.loadDataFromDocument()
        }
    }
    deinit {
        self.notificationUnRegister()
    }
}

///Data Loading
extension GPXDataManager {
    fileprivate func loadDataFromDocument() -> GPXRoot? {
        let fileList: [FileDetailInfo] = GPXFileManager.fileList
        let gpxs = GPXRoot()
        for file in fileList {
            if let gpx = GPXParser(withURL: file.fileURL)?.parsedData() {
                gpxs.add(gpx: gpx)
            }
        }
        print("Waypoints:\(gpxs.waypoints.count) Routes:\(gpxs.routes.count) Tracks:\(gpxs.tracks.count)")
        return gpxs
    }
}

extension GPXDataManager {
    fileprivate func notificationRegister() {
        NotificationCenter.default.addObserver(self, selector: #selector(memoryWarningAction), name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: nil)
    }
    
    fileprivate func notificationUnRegister() {
        
    }
    
    @objc fileprivate func memoryWarningAction() {
        print("▬▬▬▬▬▬▬▬▬▬ஜ۩۞۩ஜ▬▬▬▬▬▬▬▬▬▬▬▬▬▬内存告急")
    }
}

extension GPXRoot {
    func add(gpx:GPXRoot) {
        self.add(routes: gpx.routes)
        self.add(tracks: gpx.tracks)
        self.add(waypoints: gpx.waypoints)
    }
}
