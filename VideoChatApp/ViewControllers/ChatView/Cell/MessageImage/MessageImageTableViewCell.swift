//
//  MessageImageTableViewCell.swift
//  ChatApp
//
//  Created by Vu Khanh on 14/03/2023.
//

import UIKit
import RxSwift
import RxCocoa

class MessageImageTableViewCell: UITableViewCell {

    @IBOutlet weak var cltvListImage: UICollectionView!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var stvImage: UIStackView!
    
    var listImage = BehaviorRelay<[String]>(value: [])
    let disposeBag = DisposeBag()
    weak var chatVC: ChatViewController?
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setUpView()
        // Initialization code
    }
    
    func setUpView() {
        self.cltvListImage.addConnerRadius(radius: 10)
        self.cltvListImage.register(UINib(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageCollectionViewCell")
        self.lbTime.backgroundColor = UIColor(hexString: "#F1F1F1")
        self.lbTime.addConnerRadius(radius: 8)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configure(item: MessageModel) {
        self.listImage.accept(item.imageURL ?? [])
        self.bindData()
        if item.senderID != UserDefaultManager.shared.getID() {
            self.stvImage.alignment = .leading
        } else {
            self.stvImage.alignment = .trailing
        }
        self.lbTime.text = self.convertToString(timestamp: item.created!)
        
    }
    
    func bindData() {
        self.cltvListImage.delegate = nil
        self.cltvListImage.dataSource = nil
        self.listImage.bind(to: self.cltvListImage.rx.items(cellIdentifier: "ImageCollectionViewCell", cellType: ImageCollectionViewCell.self)) { [weak self] index, value, cell in
            cell.configure(item: value)
            cell.delegate = self?.chatVC
        }.disposed(by: disposeBag)
        
        self.cltvListImage.rx.setDelegate(self).disposed(by: disposeBag)
    }
    
    func caculateSize() -> CGSize{
        let count = self.listImage.value.count
        if count > 1 {
            var spaceCol: CGFloat
            var numberItemOfRow: CGFloat
            if count == 2 || count == 4 {
                spaceCol = CGFloat(Constants.spaceImageMessage)
                numberItemOfRow = 2
            } else {
                spaceCol = CGFloat(Constants.spaceImageMessage) * 2
                numberItemOfRow = 3
            }
            let widthItem = (self.cltvListImage.frame.width - spaceCol)/numberItemOfRow
            return CGSize(width: widthItem, height: widthItem)
        } else {
            return CGSize(width: self.cltvListImage.frame.width, height: self.cltvListImage.frame.height)
        }
    }
}

extension MessageImageTableViewCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return caculateSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(Constants.spaceImageMessage)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}
