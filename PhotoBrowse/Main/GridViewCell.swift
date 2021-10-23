/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Implements the collection view cell for displaying an asset in the grid view.
*/

import UIKit
import SnapKit

class GridViewCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    
    var representedAssetIdentifier: String!
    
    var thumbnailImage: UIImage! {
        didSet {
            imageView.image = thumbnailImage
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(self.contentView)
        }
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
