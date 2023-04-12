//
//  ListUserCollectionViewCell.swift
//  ChatApp
//
//  Created by Vu Khanh on 06/03/2023.
//

import UIKit
import SDWebImage
class ListUserCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var lbUsername: UILabel!
    @IBOutlet weak var imvAvata: UIImageView!
    @IBOutlet weak var vActive: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setUpView()
    }
    
    
    func setUpView() {
        self.imvAvata.addConnerRadius(radius: self.imvAvata.frame.width/2)
        self.vActive.addConnerRadius(radius: self.vActive.frame.width/2)
        self.vActive.addBorder(borderWidth: 1, borderColor: .white)
    }
    
    func configure(item: UserModel) {
        if let url = URL(string: item.avataURL ?? "") {
            self.imvAvata.sd_setImage(with: url)
        } else {
            self.imvAvata.image = Constants.Image.defaultAvata
        }
        self.vActive.backgroundColor = item.isActive! ? .green : .gray
        self.lbUsername.text = item.username
    }

}
