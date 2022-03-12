//
//  PhotosManager.swift
//  PhotoBrowse
//
//  Created by Huanrong Cao on 2022/3/12.
//

import Foundation

class PhotosManager {
    static let shared = PhotosManager()
    private init() {
        PHPhotoLibrary.shared().register(self)
        tabBarController?.tabBar.isHidden = true
    }
}
