/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Implements the view controller for browsing photos in a grid layout.
*/

import UIKit
import Photos
import PhotosUI

private extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}

class AssetGridViewController: UICollectionViewController {
    
    var fetchResult: PHFetchResult<PHAsset>!
    var assetCollection: PHAssetCollection!
    var availableWidth: CGFloat = 0
    var newcollection:PHAssetCollection?
    
    
    @IBOutlet var addButtonItem: UIBarButtonItem!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    fileprivate let imageManager = PHCachingImageManager()
    fileprivate var thumbnailSize: CGSize!
    fileprivate var previousPreheatRect = CGRect.zero
    
    // MARK: UIViewController / Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetCachedAssets()
        PHPhotoLibrary.shared().register(self)
        
        // Reaching this point without a segue means that this AssetGridViewController
        // became visible at app launch. As such, match the behavior of the segue from
        // the default "All Photos" view.
        if fetchResult == nil {
            let allPhotosOptions = PHFetchOptions()
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            fetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
        }
        
        //找到HR相册
        let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        for index in 0..<collections.count {
            let collection = collections.object(at: index)
            if collection.localizedTitle == "HR" {
                newcollection = collection
                print("-----找到相册", collection.localizedTitle!)
                break
            }
        }
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let width = view.bounds.inset(by: view.safeAreaInsets).width
        // Adjust the item size if the available width has changed.
        if availableWidth != width {
            availableWidth = width
            let columnCount = (availableWidth / 80).rounded(.towardZero)
            let itemLength = (availableWidth - columnCount - 1) / columnCount
            collectionViewFlowLayout.itemSize = CGSize(width: itemLength, height: itemLength)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Determine the size of the thumbnails to request from the PHCachingImageManager.
        let scale = UIScreen.main.scale
        let cellSize = collectionViewFlowLayout.itemSize
        thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
        
        // Add a button to the navigation bar if the asset collection supports adding content.
        if assetCollection == nil || assetCollection.canPerform(.addContent) {
            navigationItem.rightBarButtonItem = addButtonItem
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCachedAssets()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? AssetViewController else { fatalError("Unexpected view controller for segue") }
        guard let collectionViewCell = sender as? UICollectionViewCell else { fatalError("Unexpected sender for segue") }
        
        let indexPath = collectionView.indexPath(for: collectionViewCell)!
        destination.asset = fetchResult.object(at: indexPath.item)
        destination.assetCollection = assetCollection
    }
    
    // MARK: UICollectionView
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }
    /// - Tag: PopulateCell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = fetchResult.object(at: indexPath.item)
        // Dequeue a GridViewCell.
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridViewCell", for: indexPath) as? GridViewCell
            else { fatalError("Unexpected cell in collection view") }
        
        // Add a badge to the cell if the PHAsset represents a Live Photo.
        if asset.mediaSubtypes.contains(.photoLive) {
            cell.livePhotoBadgeImage = PHLivePhotoView.livePhotoBadgeImage(options: .overContent)
        }
        
        // Request an image for the asset from the PHCachingImageManager.
        cell.representedAssetIdentifier = asset.localIdentifier
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            // UIKit may have recycled this cell by the handler's activation time.
            // Set the cell's thumbnail image only if it's still showing the same asset.
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.thumbnailImage = image
            }
        })
        
        changeSomething(asset)
        findLocationInfo(asset)
        
        return cell
    }
    
    func changeSomething(_ asset: PHAsset) {
        let result = needChangeDataTime(asset)
        guard result.0 else {
            return
        }
        
        let new = result.1?.timeIntervalSince1970 ?? 0
        let old = asset.creationDate?.timeIntervalSince1970 ?? 0
        
        if (abs(new - old) > 100) {
            changeImageCreateTime(asset, result.1!)
        }
        
        
    }
    
    func findLocationInfo (_ asset: PHAsset) {
        guard let location = asset.location else {
            return
        }
        
        guard let imageOriginalName = asset.value(forKey: "originalFilename") as? String else {
            return
        }
        
        print(imageOriginalName, location)
        let address = CLGeocoder()
        print("---------")
        address.reverseGeocodeLocation(location) { addressMarks, error in
            guard let marks = addressMarks, marks.count > 0 else { return }
            print(marks[0])
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
        var nameDate:Date?
        
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
        nameDate = dateFormatter.date(from:(imageOriginalName as NSString).substring(with: matchs[0].range))
        
        if let temp = nameDate {
            print("🌵找到格式:", temp, imageOriginalName)
            return (true, nameDate)
        }
        
        print("-----❌无法识别:", String(imageOriginalName), "--",asset.creationDate!)
        return (false, nil)
    }
    
    func changeImageCreateTime(_ asset: PHAsset, _ newData: Date) {
        PHPhotoLibrary.shared().performChanges({
            guard let imageOriginalName = asset.value(forKey: "originalFilename") as? String else {
                return
            }
            
            print("----------🏆修改:", imageOriginalName,"新时间:", newData, "原始时间:", asset.creationDate! )
            let creationRequest = PHAssetChangeRequest(for: asset)
            creationRequest.creationDate = newData
            
            if let assetCollection = self.newcollection {
                let addAssetRequest = PHAssetCollectionChangeRequest(for: assetCollection)
                addAssetRequest?.addAssets([creationRequest] as NSArray)
            }
            
        }, completionHandler: {success, error in
            if !success { print("-----❌Error creating the asset: \(String(describing: error))") }
        })
    }
    
    func saveEditImageInAblum(_ asset: PHAsset) {
        
    }
    
    // MARK: UIScrollView
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCachedAssets()
    }
    
    // MARK: Asset Caching
    
    fileprivate func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }
    /// - Tag: UpdateAssets
    fileprivate func updateCachedAssets() {
        // Update only if the view is visible.
        guard isViewLoaded && view.window != nil else { return }
        
        // The window you prepare ahead of time is twice the height of the visible rect.
        let visibleRect = CGRect(origin: collectionView!.contentOffset, size: collectionView!.bounds.size)
        let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)
        
        // Update only if the visible area is significantly different from the last preheated area.
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        guard delta > view.bounds.height / 3 else { return }
        
        // Compute the assets to start and stop caching.
        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        let addedAssets = addedRects
            .flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
            .map { indexPath in fetchResult.object(at: indexPath.item) }
        let removedAssets = removedRects
            .flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
            .map { indexPath in fetchResult.object(at: indexPath.item) }
        
        // Update the assets the PHCachingImageManager is caching.
        imageManager.startCachingImages(for: addedAssets,
                                        targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        imageManager.stopCachingImages(for: removedAssets,
                                       targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        // Store the computed rectangle for future comparison.
        previousPreheatRect = preheatRect
    }
    
    fileprivate func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                 width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                 width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                   width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                   width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }
    
    // MARK: UI Actions
    /// - Tag: AddAsset
    @IBAction func addAsset(_ sender: AnyObject?) {
        
        // Create a dummy image of a random solid color and random orientation.
        let size = (arc4random_uniform(2) == 0) ?
            CGSize(width: 400, height: 300) :
            CGSize(width: 300, height: 400)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            UIColor(hue: CGFloat(arc4random_uniform(100)) / 100,
                    saturation: 1, brightness: 1, alpha: 1).setFill()
            context.fill(context.format.bounds)
        }
        // Add the asset to the photo library.
        PHPhotoLibrary.shared().performChanges({
            let creationRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            if let assetCollection = self.assetCollection {
                let addAssetRequest = PHAssetCollectionChangeRequest(for: assetCollection)
                addAssetRequest?.addAssets([creationRequest.placeholderForCreatedAsset!] as NSArray)
            }
        }, completionHandler: {success, error in
            if !success { print("Error creating the asset: \(String(describing: error))") }
        })
    }
    
}

// MARK: PHPhotoLibraryChangeObserver
extension AssetGridViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        guard let changes = changeInstance.changeDetails(for: fetchResult)
            else { return }
        
        // Change notifications may originate from a background queue.
        // As such, re-dispatch execution to the main queue before acting
        // on the change, so you can update the UI.
        DispatchQueue.main.sync {
            // Hang on to the new fetch result.
            fetchResult = changes.fetchResultAfterChanges
            // If we have incremental changes, animate them in the collection view.
            if changes.hasIncrementalChanges {
                guard let collectionView = self.collectionView else { fatalError() }
                // Handle removals, insertions, and moves in a batch update.
                collectionView.performBatchUpdates({
                    if let removed = changes.removedIndexes, !removed.isEmpty {
                        collectionView.deleteItems(at: removed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    if let inserted = changes.insertedIndexes, !inserted.isEmpty {
                        collectionView.insertItems(at: inserted.map({ IndexPath(item: $0, section: 0) }))
                    }
                    changes.enumerateMoves { fromIndex, toIndex in
                        collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                to: IndexPath(item: toIndex, section: 0))
                    }
                })
                // We are reloading items after the batch update since `PHFetchResultChangeDetails.changedIndexes` refers to
                // items in the *after* state and not the *before* state as expected by `performBatchUpdates(_:completion:)`.
                if let changed = changes.changedIndexes, !changed.isEmpty {
                    collectionView.reloadItems(at: changed.map({ IndexPath(item: $0, section: 0) }))
                }
            } else {
                // Reload the collection view if incremental changes are not available.
                collectionView.reloadData()
            }
            resetCachedAssets()
        }
    }
}

