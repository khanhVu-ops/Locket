//
//  ImageCollectionViewCell.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 31/03/5 Reiwa.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imv: UIImageView!
    
    var url: String?
    weak var delegate: DetailImageProtocol?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setUpView()
    }
    
    func setUpView() {
        self.imv.addConnerRadius(radius: 5)
    }
    
    deinit {
//        print("deinit")
        imv.sd_cancelCurrentImageLoad()
    }
    
    func configure(item: String) {
        if let imageUrl = URL(string: item) {
            imv.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "library"))
            self.url = item
            
        } else {
            self.imv.image = UIImage(named: "library")
            print("Invalid URL")
        }
    }

    @IBAction func btnSelectItemTapped(_ sender: Any) {
        guard let url = url else {
            return
        }
        self.delegate?.didSelectDetailImage(url: url)
    }
}
