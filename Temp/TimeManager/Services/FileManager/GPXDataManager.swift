//
//  GPXDataLoader.swift
//  TimeManager
//
//  Created by Huanrong on 4/9/19.
//  Copyright © 2019 Huanrong. All rights reserved.
//

import CoreGPX
import Foundation

/// Load all GPX File From Document Folder
/// Support GPX or gpx format for now on.
class GPXDataManager {
    typealias finish = (GPXRoot?) -> Void
    static var shared: GPXDataManager = .init()
    var GPXData: GPXRoot?
    private let queue: DispatchQueue

    private init() {
        queue = DispatchQueue(label: "com.caohr.GPXDatamanager")
        notificationRegister()
        queue.async {
            self.GPXData = self.loadDataFromDocument()
        }
    }

    deinit {
        self.notificationUnRegister()
    }

    func loadData(finish: @escaping finish) {
        queue.async {
            DispatchQueue.main.sync {
                finish(self.GPXData)
            }
        }
    }
}

/// Data Loading
private extension GPXDataManager {
    func loadDataFromDocument() -> GPXRoot? {
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

private extension GPXDataManager {
    func notificationRegister() {
        NotificationCenter.default.addObserver(self, selector: #selector(memoryWarningAction), name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: nil)
    }

    func notificationUnRegister() {}

    @objc func memoryWarningAction() {
        print("▬▬▬▬▬▬▬▬▬▬ஜ۩۞۩ஜ▬▬▬▬▬▬▬▬▬▬▬▬▬▬内存告急")
    }
}

extension GPXRoot {
    func add(gpx: GPXRoot) {
        add(routes: gpx.routes)
        add(tracks: gpx.tracks)
        add(waypoints: gpx.waypoints)
    }
}
