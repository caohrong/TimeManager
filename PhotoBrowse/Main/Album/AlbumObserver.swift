//
//  Okay.swift
//  PhotoBrowse
//
//  Created by Huanrong Cao on 2023/3/26.
//

import Photos
import UIKit

class AlbumObserver: NSObject, PHPhotoLibraryChangeObserver {
    let albumIdentifier: String
    
    var alumbUpdate:(()->())?
    
    init(albumIdentifier: String) {
        self.albumIdentifier = albumIdentifier
        super.init()
        
        PHPhotoLibrary.shared().register(self)
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        print("🌵--- Add new1")
        DispatchQueue.main.async {
            self.alumbUpdate?()
//            if let window = UIApplication.shared.windows.first {
//                window.makeToast("Update photos", duration: 3.0, position: .top)
//            }
        }
//        guard let first = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [albumIdentifier], options: nil).firstObject,
//              let _ = changeInstance.changeDetails(for: first) else {
//            return
//        }
//        print("🌵--- Add new2")
//        self.alumbUpdate?()
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
}
