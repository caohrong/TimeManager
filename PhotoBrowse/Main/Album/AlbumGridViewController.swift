//
//  AlbumGridViewController.swift
//  PhotoBrowse
//
//  Created by Huanrong Cao on 2023/3/25.
//

import UIKit
import Photos

var locationHR:CLLocation?

class AlbumGridViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private var collectionView: UICollectionView!
    var collections1:[PHAsset] = []
    let collection: PHAssetCollection
    let observer:AlbumObserver
    
    static var imageWidth:CGFloat {
        let width = CGFloat(UIScreen.main.bounds.size.width / numberInRow - (numberInRow + 1.0) * 10.0)
//        print("🌵--- \(width)")
        return width > 100 ? 100 : width
    }
    static let numberInRow = 3.0
    
    init(collection: PHAssetCollection) {
        self.collection = collection
        observer = AlbumObserver(albumIdentifier: collection.localizedTitle ?? "")
        super.init(nibName: nil, bundle: nil)
        
        self.title = collection.localizedTitle
        self.view.backgroundColor = UIColor.white
        collections1 = fetchPhotosFromAlbum(albumName: collection.localizedTitle ?? "")
        
        observer.alumbUpdate = {
            self.collections1 = self.fetchPhotosFromAlbum(albumName: collection.localizedTitle ?? "")
            self.collectionView.reloadData()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fetchPhotosFromAlbum(albumName: String) -> [PHAsset] {
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "title = %@", albumName)
        let albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: options)
        
        guard let album = albums.firstObject else {
            return []
        }
        
        let assets = PHAsset.fetchAssets(in: album, options: nil)
        var photos: [PHAsset] = []
        assets.enumerateObjects { (asset, _, _) in
            photos.append(asset)
        }
        return photos
    }
    
    override func viewDidLoad() {
        self.title = "main"
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.register(CustomCell1.self, forCellWithReuseIdentifier: "CustomCell")
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let refreshControl = UIRefreshControl()
        collectionView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(refreshCollectionView(_:)), for: .valueChanged)
        collectionView.alwaysBounceVertical = true
        
        
    }
    
    @objc private func refreshCollectionView(_ sender: UIRefreshControl) {
        // Perform your data loading or refreshing here
        // When finished, call endRefreshing() on the refresh control
        collections1 = fetchPhotosFromAlbum(albumName: collection.localizedTitle ?? "")
        collectionView.reloadData()
        sender.endRefreshing()
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell1
        let asset = self.collections1[indexPath.row]
        cell.setData(asset: asset)
        cell.updateCell = {
            print("🌵--- Update")
            collectionView.reloadItems(at: [indexPath])
        }
        cell.removePhotos = {
            // Remove the photos from the album
            PHPhotoLibrary.shared().performChanges({
                let changeRequest = PHAssetCollectionChangeRequest(for: self.collection)
                changeRequest?.removeAssets([asset] as NSFastEnumeration)
            }, completionHandler: { success, error in
                if success {
                    print("Photos removed from album successfully")
                    DispatchQueue.main.async {
                        
                        self.collections1 = self.fetchPhotosFromAlbum(albumName: self.collection.localizedTitle ?? "")
                        self.collectionView.reloadData()
                    }
                } else {
                    print("Error removing photos from album: \(error?.localizedDescription ?? "Unknown error")")
                }
            })

        }
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collections1.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: AlbumGridViewController.imageWidth, height: AlbumGridViewController.imageWidth + 30)
    }
}

class CustomCell1: UICollectionViewCell {
    var updateCell:(()->())? = nil
    var removePhotos:(() -> ())?
    var imageView: UIImageView = UIImageView()
    var titleLabel: UILabel = UILabel()
    var representedAssetIdentifier = ""
    var asset:PHAsset?
    
    override init(frame: CGRect){
        super.init(frame: frame)
        
        imageView.backgroundColor = UIColor.randomColor
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        self.contentView.addSubview(imageView)
        self.contentView.addSubview(titleLabel)
        self.imageView.snp.makeConstraints { make in
            make.height.equalTo(contentView.snp.width)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
        }
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom)
            make.bottom.equalToSuperview()
        }
        self.imageView.layer.cornerRadius = 3
        self.imageView.layer.masksToBounds = true
        self.imageView.contentMode = .scaleAspectFill
        
        self.imageView.isUserInteractionEnabled = true
        self.imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapSelector)))
    }
    
    @objc func tapSelector() {
        if let location = asset?.location {
            locationHR = location
            PhotosManager.shared.addressReverse(location: location) { address in
                if let window = UIApplication.shared.windows.first {
                    window.makeToast("拷贝地址:\(address)", duration: 3.0, position: .top)
                }
            }
        } else {
            if let location = locationHR {
                PhotosManager.shared.changeImageLocationTime(asset!, location)
                self.removePhotos?()
                PhotosManager.shared.addressReverse(location: location) { address in
                    if let window = UIApplication.shared.windows.first {
                        window.makeToast("😈粘贴地址:\(address)", duration: 3.0, position: .top)
                    }
                }
            } else {
                let pasteboard = UIPasteboard.general
                if let string = pasteboard.string {
                    let location = string.components(separatedBy: ", ")
                    if let latitude = location.first, let longitude = location.last, location.count >= 2, let lat = Double(latitude), let long = Double(longitude) {
                        let temp = CLLocation(latitude: lat, longitude: long)
                        PhotosManager.shared.changeImageLocationTime(asset!, temp)
                        self.removePhotos?()
                        PhotosManager.shared.addressReverse(location: temp) { address in
                            if let window = UIApplication.shared.windows.first {
                                window.makeToast("😈粘贴地址:\(address)", duration: 3.0, position: .top)
                            }
                        }
                    } else {
                        
                    }
                } else {
                    print("剪切板为空")
                }
            }
        }
        
        self.updateCell?()
    }
    
    func setData(asset:PHAsset) {
        self.asset = asset
//        self.titleLabel.text = result.localizedTitle
        PhotosManager.shared.imageManager.requestImage(for: asset, targetSize: CGSizeMake(AlbumGridViewController.imageWidth, CGFloat(AlbumGridViewController.imageWidth)), contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            self.imageView.image = image
        })
        
        self.titleLabel.text = asset.location == nil ? "❤️" : "💚"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
