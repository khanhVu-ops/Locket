//
//  ImageCollectionViewCell.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 31/03/5 Reiwa.
//

import UIKit
import RxSwift
import RxCocoa
class ImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imv: UIImageView!
    @IBOutlet weak var indicatorView: ProgressView!
    @IBOutlet weak var imvPlay: UIImageView!
    @IBOutlet weak var lbDuration: UILabel!
    
    var url: String?
    let disposeBag = DisposeBag()
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
        imv.contentMode = .scaleToFill
        imv.isUserInteractionEnabled = true
        imv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapSelect)))
    }
    
    deinit {
        imv.sd_cancelCurrentImageLoad()
    }
    
    func configure(item: String, message: MessageModel) {
        self.url = message.type == .video ? message.fileURL : item
        self.imv.setImage(urlString: item, placeHolder: Constants.Image.imageDefault)
        indicatorView.isAnimating = item == "Loading"
        indicatorView.isHidden = !(item == "Loading")
        imvPlay.isHidden = !(message.type == .video) && indicatorView.isHidden == true
        lbDuration.isHidden = !(message.type == .video)
        lbDuration.text = Utilitis.shared.convertDurationToTime(duration: message.duration ?? 0.0)
        
    }

    @objc func tapSelect() {
        guard let url = self.url, let actionSelectImage = self.actionSelectImage else {
            print("return")
            return
        }
        actionSelectImage(url)
    }
}
