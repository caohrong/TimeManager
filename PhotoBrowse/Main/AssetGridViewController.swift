/*
 See LICENSE folder for this sample’s licensing information.

 Abstract:
 Implements the view controller for browsing photos in a grid layout.
 */

import Photos
import PhotosUI
import Toast_Swift
import UIKit

private extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}

class AssetGridViewController: UICollectionViewController, UIGestureRecognizerDelegate {
    var availableWidth: CGFloat = 0
    var collectionViewFlowLayout: UICollectionViewFlowLayout!

    fileprivate var thumbnailSize: CGSize!
    fileprivate var previousPreheatRect = CGRect.zero

    var locationsInfo: Set = ["中国北京市"]

    var selectedLocation: CLLocation?
    
    init() {
        let layout = UICollectionViewFlowLayout()
        super.init(collectionViewLayout: layout)
        collectionViewFlowLayout = layout
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(GridViewCell.self, forCellWithReuseIdentifier: "GridViewCell")

        let items = ["All", "Photos", "Video", "location"]
        let segmented = UISegmentedControl(items: items)
        segmented.selectedSegmentIndex = 0
        segmented.backgroundColor = UIColor.gray
        segmented.addTarget(self, action: #selector(segmentedDidSeleted), for: UIControl.Event.valueChanged)
        view.addSubview(segmented)
        segmented.snp.makeConstraints { make in
            make.left.equalTo(view).offset(15)
            make.right.equalTo(view).offset(-15)
            make.height.equalTo(44)
            make.bottom.equalTo(view).offset(-100)
        }

        collectionView.allowsSelection = true
        setupLongGestureRecognizerOnCollection()
    }

    @objc func segmentedDidSeleted(segment: UISegmentedControl) {
        print("--- \(segment.selectedSegmentIndex)")
        if let type = PHAssetMediaType(rawValue: segment.selectedSegmentIndex) {
            switch segment.selectedSegmentIndex {
            case 1:
                PhotosManager.shared.fetchAssest(type: .image)
                collectionView.reloadData()
            case 2:
                PhotosManager.shared.fetchAssest(type: .video)
            case 3:
                PhotosManager.shared.fetchCollectionAssest()
            default:
                PhotosManager.shared.fetchAssest(type: .unknown)
            }
            collectionView.reloadData()
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let width = view.bounds.inset(by: view.safeAreaInsets).width
        if availableWidth != width {
            availableWidth = width

            let itemWidth = (view.frame.size.width - 4 * 3) / 5
            collectionViewFlowLayout.itemSize = CGSize(width: itemWidth, height: itemWidth)
            collectionViewFlowLayout.minimumLineSpacing = 3
            collectionViewFlowLayout.minimumInteritemSpacing = 3

            let scale = UIScreen.main.scale
            let cellSize = collectionViewFlowLayout.itemSize
            thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: false)
        tabBarController?.tabBar.isHidden = false
        // Determine the size of the thumbnails to request from the PHCachingImageManager.
        let scale = UIScreen.main.scale
        let cellSize = collectionViewFlowLayout.itemSize
        thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
    }

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        guard let destination = segue.destination as? AssetViewController else { fatalError("Unexpected view controller for segue") }
//        guard let collectionViewCell = sender as? UICollectionViewCell else { fatalError("Unexpected sender for segue") }
//
//        let indexPath = collectionView.indexPath(for: collectionViewCell)!
//        destination.asset = fetchResult.object(at: indexPath.item)
//        destination.assetCollection = assetCollection
//    }

    // MARK: UICollectionView

    override func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return PhotosManager.shared.fetchResult.count
    }

    /// - Tag: PopulateCell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = PhotosManager.shared.fetchResult.object(at: indexPath.item)
        // Dequeue a GridViewCell.
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridViewCell", for: indexPath) as? GridViewCell
        else { fatalError("Unexpected cell in collection view") }

        // Request an image for the asset from the PHCachingImageManager.
        cell.representedAssetIdentifier = asset.localIdentifier
        PhotosManager.shared.imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.thumbnailImage = image
            }
        })

        // public.heic,public.jpeg, com.apple.quicktime-movie
        if let imageType: String = asset.value(forKey: "uniformTypeIdentifier") as? String {
//            print(imageType)
            if imageType == "public.jpeg" {
//                print("public.jpeg")
            }
            if imageType == "com.apple.quicktime-movie" {}
        }

        let assets = PHAssetResource.assetResources(for: asset)
        if let result = assets.first?.value(forKey: "locallyAvailable") as? Bool, result == true {
        } else {
            print("🌵----不在本地🌵")
        }

        cell.contentView.backgroundColor = UIColor.lightGray

        cell.locationImageView.isHidden = asset.location == nil
        cell.videoImageView.isHidden = asset.mediaType != .video
        // Add a badge to the cell if the PHAsset represents a Live Photo.
        if asset.mediaSubtypes.contains(.photoLive) {
//            cell.livePhotoBadgeImage = PHLivePhotoView.livePhotoBadgeImage(options: .overContent)
        }

        return cell
    }

    override func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = AssetViewController()
        vc.asset = PhotosManager.shared.fetchResult.object(at: indexPath.row)
        navigationController?.pushViewController(vc, animated: true)
    }

    private func setupLongGestureRecognizerOnCollection() {
        let longPressedGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureRecognizer:)))
        longPressedGesture.minimumPressDuration = 0.5
        longPressedGesture.delegate = self
        longPressedGesture.delaysTouchesBegan = true
        collectionView?.addGestureRecognizer(longPressedGesture)
    }

    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        guard gestureRecognizer.state == .began else { return }
        
        let p = gestureRecognizer.location(in: collectionView)
        
        if let indexPath = collectionView?.indexPathForItem(at: p) {
            print("Long press at item: \(indexPath.row)")
            let asset = PhotosManager.shared.fetchResult.object(at: indexPath.row)
            if let location = asset.location {
                print("拷贝地址---")
                PhotosManager.shared.addressReverse(location: location) { address in
                    self.view.makeToast("😈拷贝地址:\(address)", duration: 3.0, position: .bottom)
                }
                selectedLocation = location
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            } else {
                guard let location = selectedLocation else { return }
                PhotosManager.shared.changeImageLocationTime(asset, location)
                print("粘贴地址---")
                PhotosManager.shared.addressReverse(location: location) { address in
                    self.view.makeToast("🌵粘贴地址:\(address)", duration: 3.0, position: .bottom)
                    self.collectionView.reloadData()
                }
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                
                PHPhotoLibrary.shared().performChanges {
                    if let collection = PhotosManager.shared.collectionDuplication {
                        PHAssetCollectionChangeRequest(for: collection)?.removeAssets([asset] as NSArray)
                    }
                } completionHandler: { _,_  in
                    
                }

//                PHPhotoLibrary.shared().performChanges({
//                        let request = PHAssetCollectionChangeRequest(for: self.assetCollection)!
//                        request.removeAssets([self.asset as Any] as NSArray)
//                    }, completionHandler: completion)
            }
        }
    }

    /// - Tag: UpdateAssets
//    fileprivate func updateCachedAssets() {
//        // Update only if the view is visible.
//        guard isViewLoaded, view.window != nil else { return }
//
//        // The window you prepare ahead of time is twice the height of the visible rect.
//        let visibleRect = CGRect(origin: collectionView!.contentOffset, size: collectionView!.bounds.size)
//        let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)
//
//        // Update only if the visible area is significantly different from the last preheated area.
//        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
//        guard delta > view.bounds.height / 3 else { return }
//
//        // Compute the assets to start and stop caching.
//        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
//        let addedAssets = addedRects
//            .flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
//            .map { indexPath in fetchResult.object(at: indexPath.item) }
//        let removedAssets = removedRects
//            .flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
//            .map { indexPath in fetchResult.object(at: indexPath.item) }
//
//        // Update the assets the PHCachingImageManager is caching.
//        imageManager.startCachingImages(for: addedAssets,
//                                        targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
//        imageManager.stopCachingImages(for: removedAssets,
//                                       targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
//        // Store the computed rectangle for future comparison.
//        previousPreheatRect = preheatRect
//    }

    // MARK: UIScrollView

    override func scrollViewDidScroll(_: UIScrollView) {
//        updateCachedAssets()
    }

    // MARK: Asset Caching

    fileprivate func resetCachedAssets() {
//        imageManager.stopCachingImagesForAllAssets()
//        previousPreheatRect = .zero
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
//    @IBAction func addAsset(_: AnyObject?) {
//        // Create a dummy image of a random solid color and random orientation.
//        let size = (arc4random_uniform(2) == 0) ?
//            CGSize(width: 400, height: 300) :
//            CGSize(width: 300, height: 400)
//        let renderer = UIGraphicsImageRenderer(size: size)
//        let image = renderer.image { context in
//            UIColor(hue: CGFloat(arc4random_uniform(100)) / 100,
//                    saturation: 1, brightness: 1, alpha: 1).setFill()
//            context.fill(context.format.bounds)
//        }
//        // Add the asset to the photo library.
//        PHPhotoLibrary.shared().performChanges({
//            let creationRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
//            if let assetCollection = self.assetCollection {
//                let addAssetRequest = PHAssetCollectionChangeRequest(for: assetCollection)
//                addAssetRequest?.addAssets([creationRequest.placeholderForCreatedAsset!] as NSArray)
//            }
//        }, completionHandler: { success, error in
//            if !success { print("Error creating the asset: \(String(describing: error))") }
//        })
//    }
}

// MARK: PHPhotoLibraryChangeObserver

// extension AssetGridViewController: PHPhotoLibraryChangeObserver {
//    func photoLibraryDidChange(_ changeInstance: PHChange) {
//        guard let changes = changeInstance.changeDetails(for: fetchResult)
//        else { return }
//
//        // Change notifications may originate from a background queue.
//        // As such, re-dispatch execution to the main queue before acting
//        // on the change, so you can update the UI.
//        DispatchQueue.main.sync {
//            // Hang on to the new fetch result.
//            fetchResult = changes.fetchResultAfterChanges
//            // If we have incremental changes, animate them in the collection view.
//            if changes.hasIncrementalChanges {
//                guard let collectionView = self.collectionView else { fatalError() }
//                // Handle removals, insertions, and moves in a batch update.
//                collectionView.performBatchUpdates({
//                    if let removed = changes.removedIndexes, !removed.isEmpty {
//                        collectionView.deleteItems(at: removed.map { IndexPath(item: $0, section: 0) })
//                    }
//                    if let inserted = changes.insertedIndexes, !inserted.isEmpty {
//                        collectionView.insertItems(at: inserted.map { IndexPath(item: $0, section: 0) })
//                    }
//                    changes.enumerateMoves { fromIndex, toIndex in
//                        collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
//                                                to: IndexPath(item: toIndex, section: 0))
//                    }
//                })
//                // We are reloading items after the batch update since `PHFetchResultChangeDetails.changedIndexes` refers to
//                // items in the *after* state and not the *before* state as expected by `performBatchUpdates(_:completion:)`.
//                if let changed = changes.changedIndexes, !changed.isEmpty {
//                    collectionView.reloadItems(at: changed.map { IndexPath(item: $0, section: 0) })
//                }
//            } else {
//                // Reload the collection view if incremental changes are not available.
//                collectionView.reloadData()
//            }
//            resetCachedAssets()
//        }
//    }
// }
