//
//  ImageCollectionViewCell.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 31/03/5 Reiwa.
//

import UIKit
import SnapKit
import ProgressHUD
class ImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imv: UIImageView!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var lbDuration: UILabel!
    var url: String?
    var actionSelectImage: ((String) -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setUpView()
    }
    
    override func prepareForReuse() {
        self.url = nil
    }
    
    func setUpView() {
        self.imv.addConnerRadius(radius: 5)
        imv.contentMode = .scaleAspectFill
        imv.isUserInteractionEnabled = true
        imv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapSelect)))
        btnPlay.circleClip()
        lbDuration.setPadding(UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        lbDuration.backgroundColor = .darkGray.withAlphaComponent(0.6)
        lbDuration.addConnerRadius(radius: 5)
        btnPlay.backgroundColor = .darkGray.withAlphaComponent(0.6)
    }
    
    deinit {
        imv.sd_cancelCurrentImageLoad()
    }
    
    func configure(item: String, message: MessageModel) {
        self.url = message.type == .video ? message.fileURL : item
        self.imv.setImage(urlString: item, placeHolder: Constants.Image.defaultImage)
        btnPlay.isHidden = !(message.type == .video)
        lbDuration.isHidden = !(message.type == .video)
        lbDuration.text = " " + Utilitis.shared.convertDurationToTime(duration: message.duration ?? 0.0) + " "
        
    }

    @objc func tapSelect() {
        guard let url = self.url, let actionSelectImage = self.actionSelectImage else {
            print("return")
            return
        }
        actionSelectImage(url)
    }
    
    @IBAction func btnPlayTapped(_ sender: Any) {
        tapSelect()
    }
}
