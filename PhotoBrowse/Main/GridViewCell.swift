/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Implements the collection view cell for displaying an asset in the grid view.
*/

import UIKit

class GridViewCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    var livePhotoBadgeImageView: UIImageView!
    
    var representedAssetIdentifier: String!
    
    var thumbnailImage: UIImage! {
        didSet {
            imageView.image = thumbnailImage
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        contentView.backgroundColor = UIColor.lightGray
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        imageView.frame = contentView.frame
    }
}
