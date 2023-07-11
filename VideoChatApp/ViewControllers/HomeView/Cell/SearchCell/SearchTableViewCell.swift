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
    @IBOutlet weak var vActive: UIView!
    
    var actionSelectRow: ((String, UserModel) -> Void)?
    var uid2: String?
    var user: UserModel?
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
        self.imvAvata.addConnerRadius(radius: 30)
        self.imvAvata.addBorder(borderWidth: 1, borderColor: Constants.Color.mainColor)
        self.vActive.circleClip()
        self.vActive.addBorder(borderWidth: 1, borderColor: .white)
    }
    
    func configure(item: UserModel) {
        self.uid2 = item.id
        self.user = item
        if let url = URL(string: item.avataURL!) {
            self.imvAvata.sd_setImage(with: url, placeholderImage: Constants.Image.defaultAvata)
        } else {
            self.imvAvata.image = Constants.Image.defaultAvata
        }
        self.vActive.backgroundColor = item.isActive! ? .green : .gray
        self.lbUsername.text = item.username
    }
    @IBAction func btnSelectRowTapped(_ sender: Any) {
        guard let uid2 = uid2, let user = user, let actionSelectRow = actionSelectRow else {
            print("return")
            return
        }
        actionSelectRow(uid2, user)
    }
}
