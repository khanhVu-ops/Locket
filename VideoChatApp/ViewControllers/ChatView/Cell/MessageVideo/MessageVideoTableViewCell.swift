//
//  MessageVideoTableViewCell.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 09/04/5 Reiwa.
//

import UIKit

class MessageVideoTableViewCell: UITableViewCell {

    @IBOutlet weak var vContent: UIView!
    @IBOutlet weak var lbDuration: UILabel!
    @IBOutlet weak var imvThumbnail: UIImageView!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var lbStatus: UILabel!
    @IBOutlet weak var stv: UIStackView!
    @IBOutlet weak var imvAvata: UIImageView!
    
    weak var delegate: DetailImageProtocol?
    var videoURL: String?
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setUpView()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpView() {
        self.vContent.addConnerRadius(radius: 10)
        self.lbTime.backgroundColor = UIColor(hexString: "#F1F1F1")
        self.lbTime.addConnerRadius(radius: 8)
    }
    
    func configure(item: MessageModel) {
        
//        if item.senderID != UserDefaultManager.shared.getID() {
//            self.stv.alignment = .leading
//        } else {
//            self.stv.alignment = .trailing
//        }
//        if let imageUrl = URL(string: item.thumbVideo ?? "") {
//            self.imvThumbnail.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "library"))
//            self.videoURL = item.videoURL
//        } else {
//            self.imvThumbnail.image = UIImage(named: "library")
//            print("Invalid URL")
//        }
//        self.lbTime.text = Utilitis.shared.convertToString(timestamp: item.created!)
//        if let duration = item.duration {
//            let minutes = Int(duration / 60)
//            let seconds = Int(duration.truncatingRemainder(dividingBy: 60))
//            self.lbDuration.text = String(format: "%02d:%02d", minutes, seconds)
//        }
        
    }
    @IBAction func btnPlayTapped(_ sender: Any) {
        guard let videoURL = videoURL else {
            return
        }
        self.delegate?.didSelectDetailImage(url: videoURL)
    }
    
}
