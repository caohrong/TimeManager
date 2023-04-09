//
//  PhotosAlbumViewController.swift
//  PhotoBrowse
//
//  Created by Huanrong Cao on 2023/3/25.
//

import UIKit

class PhotosAlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private var collectionView: UICollectionView!
    var collections:PHFetchResult<PHAssetCollection>!
    
    static var imageWidth:CGFloat {
//        let gap = 10
//        let width = CGFloat(UIScreen.main.bounds.size.width / numberInRow - (numberInRow + 1.0) * 10.0)
        return 100
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        collections = loadAlbum()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.title = "相册"
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.register(CustomCell.self, forCellWithReuseIdentifier: "CustomCell")
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
    
    func loadAlbum() -> PHFetchResult<PHAssetCollection> {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        return PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: options)
    }
    
    @objc private func refreshCollectionView(_ sender: UIRefreshControl) {
        // Perform your data loading or refreshing here
        // When finished, call endRefreshing() on the refresh control
        collections = loadAlbum()
        
        collectionView.reloadData()
        sender.endRefreshing()
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
        cell.setData(result: self.collections[indexPath.row])
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collections.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = PhotosAlbumViewController.imageWidth
        return CGSize(width: width, height: width + 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.navigationController?.pushViewController(AlbumGridViewController(collection: collections[indexPath.row]), animated: true)
    }
}

// Custom Cell Class
import UIKit
import Photos

class CustomCell: UICollectionViewCell {
    var imageView: UIImageView = UIImageView()
    var titleLabel: UILabel = UILabel()
    
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
    }
    
    func setData(result:PHAssetCollection) {
        self.titleLabel.text = result.localizedTitle
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIColor {
    static var randomColor:UIColor {
        let red = CGFloat.random(in: 0...1)
        let green = CGFloat.random(in: 0...1)
        let blue = CGFloat.random(in: 0...1)
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
