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
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setUpView()
    }
    
    func setUpView() {
        self.imvAvata.addConnerRadius(radius: self.imvAvata.frame.width/2)
        self.imvAvata.addBorder(borderWidth: 2, borderColor: .green)
    }
    
    func configure(item: UserModel) {
        if let url = URL(string: item.avataURL ?? "") {
            self.imvAvata.sd_setImage(with: url, placeholderImage: UIImage(systemName: "person.fill"))
        } else {
            self.imvAvata.image = Constants.Image.defaultAvata
        }
        
        self.lbUsername.text = item.username
    }

}
