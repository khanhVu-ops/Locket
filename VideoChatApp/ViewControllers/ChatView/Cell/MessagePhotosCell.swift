//
//  MessageImagesCell.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 27/06/5 Reiwa.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxCocoa
class MessagePhotosCell: BaseMessageTableViewCell {
    private lazy var cltvPhotos: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let cltv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cltv.showsVerticalScrollIndicator = false
        cltv.register(ImageCollectionViewCell.nibClass, forCellWithReuseIdentifier: ImageCollectionViewCell.nibNameClass)
        cltv.layer.masksToBounds = false
        cltv.dataSource = self
        cltv.delegate = self
        return cltv
    }()
    
    let spaceItem: CGFloat = 2
    var listPhotos = [String]()
    var message = MessageModel()
    var maxWidth: CGFloat = 0
    var maxHeight: CGFloat = 0
    var ratio: Double = 0
    var actionSelectImage: ((String) -> Void)?
    var widthCltvContraints: Constraint?
    var heightltvContraints: Constraint?
    override func setUpView() {
        super.setUpView()
        self.maxWidth = rounded(self.contentView.frame.size.width * 0.65)
        self.maxHeight = rounded(self.contentView.frame.size.width)
        self.heightltvContraints?.deactivate()
        self.widthCltvContraints?.deactivate()
        
        self.vContentMessage.addSubview(cltvPhotos)
        self.cltvPhotos.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    override func configure(item: MessageModel, user: UserModel, indexPath: IndexPath) {
        super.configure(item: item, user: user, indexPath: indexPath)
        guard let listMedia = item.imageURL else {
            return
        }
        self.listPhotos = listMedia
        self.message = item
//        print(listPhotos.count)
        self.ratio = item.ratioImage ?? 1
        self.checkSizeCltv()
        self.cltvPhotos.reloadData()
    }
    
    func checkItem() -> CGSize {
        let count = self.listPhotos.count
        if count == 2 || count == 4 {
            let width = rounded((maxWidth - spaceItem) / 2)
            return CGSize(width: width, height: width)
        } else if count == 1{
            return ratio < 3/4 ? CGSize(width: rounded(maxHeight * ratio), height: maxHeight) : CGSize(width: maxWidth, height: rounded(maxWidth * 1/ratio))
        } else {
            let width = rounded((maxWidth - spaceItem * 2) / 3)
            return CGSize(width: width, height: width)
        }
    }
    
    
    
    func checkSizeCltv() {
        let sizeItem = checkItem()
        let count = self.listPhotos.count
        self.heightltvContraints?.deactivate()
        self.widthCltvContraints?.deactivate()
        if count == 1 {
            self.cltvPhotos.snp.makeConstraints { make in
                heightltvContraints = make.height.equalTo(sizeItem.height).constraint
                widthCltvContraints = make.width.equalTo(sizeItem.width).constraint
            }
        } else if count == 2 || count == 4 {
            let row: CGFloat = CGFloat(ceil(Double(count/2)))
            self.cltvPhotos.snp.makeConstraints { make in
                heightltvContraints = make.height.equalTo(rounded(sizeItem.height * row + (row-1)*spaceItem)).constraint
                widthCltvContraints = make.width.equalTo(maxWidth).constraint
            }
        } else {
            let row: CGFloat = CGFloat(ceil(Double(count)/3))
            self.cltvPhotos.snp.makeConstraints { make in
                heightltvContraints = make.height.equalTo(rounded(sizeItem.height * row + (row-1)*spaceItem)).constraint
                widthCltvContraints = make.width.equalTo(maxWidth).constraint
            }
        }
        self.setNeedsLayout()
    }
    
    func rounded(_ a: CGFloat) -> CGFloat {
        return CGFloat(Double(a).rounded(toPlaces: 0))
    }
}

extension MessagePhotosCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.nibNameClass, for: indexPath) as! ImageCollectionViewCell
        cell.configure(item: listPhotos[indexPath.item], message: message)
        cell.actionSelectImage = { [weak self] url in
            guard let self = self, let actionSelectImage = self.actionSelectImage else {
                return
            }
            actionSelectImage(url)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return checkItem()
    }
}
