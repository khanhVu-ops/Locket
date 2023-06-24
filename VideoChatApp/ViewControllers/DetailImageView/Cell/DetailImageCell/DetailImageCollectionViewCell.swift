//
//  DetailImageCollectionViewCell.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 31/03/5 Reiwa.
//

import UIKit
import AVFoundation
import SnapKit
import AVKit
class DetailImageCollectionViewCell: UICollectionViewCell {
    private lazy var imvDetail: UIImageView = {
        let imv = UIImageView()
        imv.contentMode = .scaleAspectFit
        return imv
    }()
    var scrollView: ImageScrollView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addSubview(self.imvDetail)
        self.imvDetail.addConnerRadius(radius: 20)
        scrollView = ImageScrollView()
        self.addSubview(scrollView)
        // Initialization code
    }
    
    override func prepareForReuse() {
        print("Reuse detail image")
        
    }
    
    func loadImage(url: String, frameScroll: CGRect, cellSize: CGSize) {
        self.scrollView.frame = frameScroll
        let imgSize = CGSize(width: cellSize.width - 20, height: cellSize.height)
        self.scrollView.cellSize = imgSize
        if let imageUrl = URL(string: url) {
            self.imvDetail.sd_setImage(with: imageUrl, completed: { (image, error, cacheType, url) in
                if let image = image {
                    self.scrollView.set(image: image)
                } else {
                    self.scrollView.set(image: Constants.Image.imageDefault)
                }
            })
        } else {
            self.scrollView.set(image: Constants.Image.imageDefault)
            print("Invalid URL")
        }
    }
}
