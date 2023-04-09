//
//  PhotosManager.swift
//  PhotoBrowse
//
//  Created by Huanrong Cao on 2022/3/12.
//

import Foundation
import Photos
import PhotosUI
import Toast_Swift

class PhotosManager {
    static let shared = PhotosManager()

    var fetchResult: PHFetchResult<PHAsset>!
    var assetCollection: PHAssetCollection!
    var collectionHR: PHAssetCollection?
    var collectionDuplication: PHAssetCollection?
    let imageManager = PHCachingImageManager()
    let serialQueue = DispatchQueue(label: "com.leo.serialQueue")
    let db = DBTools()
    let address = CLGeocoder()

    private init() {
        if fetchResult == nil {
            fetchAssest(type: .unknown)
        }

        // 找到HR相册
        let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        for index in 0 ..< collections.count {
            let collection = collections.object(at: index)
            if collection.localizedTitle == "HR" {
                collectionHR = collection
                print("-----找到相册", collection.localizedTitle!)
            }

            if collection.localizedTitle == "Duplication" {
                collectionDuplication = collection
                print("-----找到相册", collection.localizedTitle!)
            }
        }

        UserDefaults.standard.set(["cn"], forKey: "AppleLanguages")
    }

    func fetchAssest(type: PHAssetMediaType) {
        let allPhotosOptions = PHFetchOptions()
        if type != .unknown {
            allPhotosOptions.predicate = NSPredicate(format: "mediaType = %d", type.rawValue)
        }
        var sorts = [NSSortDescriptor]()
//        if type == .video {
//            sorts.append(NSSortDescriptor(key: "size", ascending: true))
//        }
        sorts.append(NSSortDescriptor(key: "creationDate", ascending: false))
        allPhotosOptions.sortDescriptors = sorts
        fetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
    }

    func fetchCollectionAssest() {
        let allPhotosOptions = PHFetchOptions()
        var sorts = [NSSortDescriptor]()
        sorts.append(NSSortDescriptor(key: "creationDate", ascending: false))
        allPhotosOptions.sortDescriptors = sorts

        if let collectionDuplication = collectionDuplication {
            fetchResult = PHAsset.fetchAssets(in: collectionDuplication, options: nil)
        }
        print("----一共找到照片", fetchResult.count)
    }

    func taskBackground() {
        print("----一共找到照片", fetchResult.count)
        db.saveAllPhotosResult(fetchResult: fetchResult)

        return

        var pre: PHAsset = fetchResult.object(at: 0)
        pre.requestContentEditingInput(with: nil) { input, _ in
            print("---------1")
            guard let fileURL = input?.fullSizeImageURL, let fullImage = CIImage(contentsOf: fileURL)
            else { return }
            print(fullImage.properties)
        }

        for i in 1 ..< fetchResult.count {
            let asset = fetchResult.object(at: i)
            checkLocationInfo(asset)
            if asset.creationDate?.timeIntervalSince1970 == pre.creationDate?.timeIntervalSince1970,
               asset.pixelWidth == pre.pixelWidth,
               asset.pixelHeight == pre.pixelHeight
            {
                print("---------1", i)
                PHPhotoLibrary.shared().performChanges({
                    let creationRequest1 = PHAssetChangeRequest(for: pre)
                    let creationRequest2 = PHAssetChangeRequest(for: asset)
                    if let assetCollection = self.collectionDuplication {
                        let addAssetRequest = PHAssetCollectionChangeRequest(for: assetCollection)
                        addAssetRequest?.addAssets([creationRequest1, creationRequest2] as NSArray)
                    }

                }, completionHandler: { success, error in
                    if !success { print("-----❌Error creating the asset: \(String(describing: error))") }
                })
            }
            pre = asset
        }
    }

    func checkDuplicationPic() {}

    func doSomethingAtBackground() {
        serialQueue.async {
            self.taskBackground()
        }
    }

    func doSomethingWithCell(asset _: PHAsset) {
        serialQueue.async {
//            checkShootTimeInfo(asset)
//            self.checkLocationInfo(asset)
        }
    }

    func checkShootTimeInfo(_ asset: PHAsset) {
        let result = needChangeDataTime(asset)
        guard result.0 else {
            return
        }

        let new = result.1?.timeIntervalSince1970 ?? 0
        let old = asset.creationDate?.timeIntervalSince1970 ?? 0

        if abs(new - old) > 100 {
            changeImageCreateTime(asset, result.1!)
        }
    }

    func checkLocationInfo(_ asset: PHAsset) {
        guard let location = asset.location else {
            return
        }

        sleep(1)

        address.reverseGeocodeLocation(location) { addressMarks, error in
            guard let marks = addressMarks, marks.count > 0 else {
                if let errorInfo = error {
                    print(errorInfo.localizedDescription)
                    self.checkLocationInfo(asset)
                }
                return
            }
            let address: CLPlacemark = marks[0]

            let addressString = (address.country ?? "") + (address.administrativeArea ?? "") + (address.locality ?? "")
            print(addressString)
//            self.locationsInfo.insert(addressString)
        }
    }

    func addressReverse(location: CLLocation, completion: @escaping (String) -> Void) {
        address.reverseGeocodeLocation(location) { addressMarks, error in
            guard let marks = addressMarks, marks.count > 0 else {
                if let errorInfo = error {
                    print(errorInfo.localizedDescription)
                }
                return
            }
            let address: CLPlacemark = marks[0]

            let addressString = (address.administrativeArea ?? "") + (address.locality ?? "") + (address.subLocality ?? "") + (address.name ?? "")
            print(addressString)
            completion(addressString)
        }
    }

    func needChangeDataTime(_ asset: PHAsset) -> (Bool, Date?) {
        guard var imageOriginalName = asset.value(forKey: "originalFilename") as? String else {
            return (false, nil)
        }

        guard imageOriginalName.utf16.count >= 14 else {
            return (false, nil)
        }

        let dateFormatter = DateFormatter()
        var nameDate: Date?

        imageOriginalName = imageOriginalName.replacingOccurrences(of: " ", with: "")
        imageOriginalName = imageOriginalName.replacingOccurrences(of: "_", with: "")
        imageOriginalName = imageOriginalName.replacingOccurrences(of: ".", with: "")
        imageOriginalName = imageOriginalName.replacingOccurrences(of: "-", with: "")

        guard imageOriginalName.utf16.count >= 14 else {
            return (false, nil)
        }

        let regex = "(20[0-2][0-9])([0-1][0-9])([0-3][0-9])([0-2][0-9])([0-6][0-9])([0-6][0-9])"

        guard let RE = try? NSRegularExpression(pattern: regex, options: .caseInsensitive) else {
            return (false, nil)
        }

        let matchs = RE.matches(in: imageOriginalName, options: .reportProgress, range: NSRange(location: 0, length: imageOriginalName.utf16.count))

        guard matchs.count > 0 else {
            return (false, nil)
        }

        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        nameDate = dateFormatter.date(from: (imageOriginalName as NSString).substring(with: matchs[0].range))

        if let temp = nameDate {
            print("🌵找到格式:", temp, imageOriginalName)
            return (true, nameDate)
        }

        print("-----❌无法识别:", String(imageOriginalName), "--", asset.creationDate!)
        return (false, nil)
    }

    func changeImageCreateTime(_ asset: PHAsset, _ newData: Date) {
        PHPhotoLibrary.shared().performChanges({
            guard let imageOriginalName = asset.value(forKey: "originalFilename") as? String else {
                return
            }

            print("----------🏆修改:", imageOriginalName, "新时间:", newData, "原始时间:", asset.creationDate!)
            let creationRequest = PHAssetChangeRequest(for: asset)
            creationRequest.creationDate = newData

            if let assetCollection = self.collectionHR {
                let addAssetRequest = PHAssetCollectionChangeRequest(for: assetCollection)
                addAssetRequest?.addAssets([creationRequest] as NSArray)
            }

        }, completionHandler: { success, error in
            if !success { print("-----❌Error creating the asset: \(String(describing: error))") }
        })
    }

    func changeImageLocationTime(_ asset: PHAsset, _ location: CLLocation) {
        PhotosManager.shared.addressReverse(location: location) { address in
            print("😈Location:\(address)")
        }
        PHPhotoLibrary.shared().performChanges({
            let creationRequest = PHAssetChangeRequest(for: asset)
            creationRequest.location = location

            if let assetCollection = self.collectionHR {
                let addAssetRequest = PHAssetCollectionChangeRequest(for: assetCollection)
                addAssetRequest?.addAssets([creationRequest] as NSArray)
            }

        }, completionHandler: { success, error in
            if !success { print("-----❌Error creating the asset: \(String(describing: error))") }
        })
    }

    func saveEditImageInAblum(_: PHAsset) {}
}
