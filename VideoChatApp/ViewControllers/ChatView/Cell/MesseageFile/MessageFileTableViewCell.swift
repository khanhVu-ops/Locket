//
//  MessageFileTableViewCell.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 14/04/5 Reiwa.
//

import UIKit

protocol MessageFileProtocol: NSObject {
    func didSelectOpenFile(fileURL: URL)
}

class MessageFileTableViewCell: UITableViewCell {

    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var stv: UIStackView!
    @IBOutlet weak var vContent: UIView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var btnOpenFile: UIButton!
    
    var fileURL: URL?
    
    weak var delegate: MessageFileProtocol?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setUpView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.fileURL = nil
    }
    
    func setUpView() {
        self.vContent.addConnerRadius(radius: 15)
        self.lbTime.backgroundColor = UIColor(hexString: "#F1F1F1")
        self.lbTime.addConnerRadius(radius: 8)
    }
    
    func configure(item: MessageModel) {
        if item.senderID != UserDefaultManager.shared.getID() {
            self.stv.alignment = .leading
        } else {
            self.stv.alignment = .trailing
        }
        guard let fileName = item.fileName else {
            return
        }
        self.lbName.text = fileName
        self.lbTime.text = convertToString(timestamp: item.created!)
        self.progressView.progress = Float((item.progress ?? 0.0)/100.0)
        if progressView.progress == 1 {
            self.progressView.isHidden = true
        } else {
            self.progressView.isHidden = false
        }
        guard let fileURL = URL(string: item.fileURL ?? "") else {
            self.vContent.backgroundColor = .lightGray.withAlphaComponent(0.5)
            self.btnOpenFile.isEnabled = false
            return
        }
        self.btnOpenFile.isEnabled = true
        self.vContent.backgroundColor = .lightGray
        self.fileURL = fileURL
        print("Path susses", fileURL)
        
    }
    @IBAction func didTapSelectOpenFile(_ sender: Any) {
        guard let fileURL = fileURL else {
            return
        }
        self.delegate?.didSelectOpenFile(fileURL: fileURL)
    }
}
