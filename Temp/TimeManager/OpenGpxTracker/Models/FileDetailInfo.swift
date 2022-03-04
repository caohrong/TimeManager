//
//  GPXFileInfo.swift
//  OpenGpxTracker
//
//  Created by merlos on 23/09/2018.
//

import Foundation

///
/// A handy way of getting info of a GPX file.
///
/// It gets info like filename, modified date, filesize
///
///
class FileDetailInfo: NSObject {
    /// file URL
    var fileURL: URL = .init(fileURLWithPath: "")

    /// last time the file was modified
    var modifiedDate: Date {
        return try! fileURL.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate ?? Date.distantPast
    }

    //
    var modifiedDatetimeAgo: String {
        return modifiedDate.timeAgo(numericDates: true)
    }

    /// file size in bytes
    var fileSize: Int {
        return try! fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
    }

    ///
    var fileSizeHumanised: String {
        return fileSize.asFileSize()
    }

    /// The filename without extension
    var fileName: String {
        return fileURL.deletingPathExtension().lastPathComponent
    }

    ///
    /// Initializes the object with the URL of the file to get info.
    ///
    /// - Parameters:
    ///     - fileURL: the URL of the GPX file.
    ///
    init(fileURL: URL) {
        self.fileURL = fileURL
        super.init()
    }
}
