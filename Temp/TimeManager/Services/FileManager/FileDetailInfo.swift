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

struct FileDetailInfo {
    /// file URL
    let fileURL: URL

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
}
