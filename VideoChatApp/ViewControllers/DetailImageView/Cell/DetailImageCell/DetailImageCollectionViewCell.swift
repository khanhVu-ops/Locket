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
        imv.addConnerRadius(radius: 10)
        return imv
    }()
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.addSubview(self.imvDetail)
        // Initialization code
    }
    override func prepareForReuse() {
        print("Reuse detail image")
    }
    
    func loadImage(url: String) {
        if let imageUrl = URL(string: url) {
            self.imvDetail.sd_setImage(with: imageUrl, completed: { (image, error, cacheType, url) in
                if let image = image {
                    // Lấy kích thước của hình ảnh và tính tỷ lệ
                    let ratio = image.size.height / image.size.width
                    print("Tỷ lệ của hình ảnh là: \(ratio)")
                    DispatchQueue.main.async {
                        self.imvDetail.snp.removeConstraints()
                        self.imvDetail.snp.makeConstraints { make in
                            if ratio < 2 {
                                make.leading.trailing.equalToSuperview().inset(20)
                                make.centerY.equalToSuperview()
                                make.height.equalTo(self.imvDetail.snp.width).multipliedBy(ratio)
                            } else {
                                make.top.bottom.equalToSuperview().inset(10)
                                make.centerX.equalToSuperview()
                                make.width.equalTo(self.imvDetail.snp.height).multipliedBy(1/ratio)
                            }
                        }
                        self.imvDetail.layer.cornerRadius = 20
                        self.imvDetail.layer.masksToBounds = true
                    }
                }
            })
        } else {
            self.imvDetail.image = UIImage(named: "library")
            print("Invalid URL")
        }
    }
}
