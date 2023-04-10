//
//  SearchTableViewCell.swift
//  ChatApp
//
//  Created by Vu Khanh on 17/03/2023.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var imvAvata: UIImageView!
    @IBOutlet weak var lbUsername: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpView()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpView() {
        print("re", imvAvata.frame.width)
        self.imvAvata.addConnerRadius(radius: 30)
        self.imvAvata.addBorder(borderWidth: 1, borderColor: Constants.Color.mainColor)
    }
    
    func configure(item: UserModel) {
        if let url = URL(string: item.avataURL!) {
            self.imvAvata.sd_setImage(with: url, placeholderImage: Constants.Image.defaultAvata)
        } else {
            self.imvAvata.image = UIImage(named: "avata1")
        }
        self.lbUsername.text = item.username
    }
}
