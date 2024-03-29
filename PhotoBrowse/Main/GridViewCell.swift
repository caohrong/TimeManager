/*
 See LICENSE folder for this sample’s licensing information.

 Abstract:
 Implements the collection view cell for displaying an asset in the grid view.
 */

import SnapKit
import UIKit

class GridViewCell: UICollectionViewCell {
    var imageView: UIImageView!
    var representedAssetIdentifier: String!
    var thumbnailImage: UIImage! {
        didSet {
            imageView.image = thumbnailImage
        }
    }

    var locationImageView: UIImageView!
    var videoImageView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)

        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(self.contentView)
        }

        locationImageView = UIImageView(image: UIImage(systemName: "location.fill"))
        contentView.addSubview(locationImageView)
        locationImageView.snp.makeConstraints { make in
            make.right.equalTo(self.contentView).offset(-2)
            make.bottom.equalTo(self.contentView).offset(-2)
            make.width.height.equalTo(15)
        }

        videoImageView = UIImageView(image: UIImage(systemName: "play.fill"))
        contentView.addSubview(videoImageView)
        videoImageView.snp.makeConstraints { make in
            make.center.equalTo(self.contentView)
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        imageView.frame = contentView.frame
    }
}
