//
//  ListFriendCell.swift
//  ChatApp
//
//  Created by Vu Khanh on 06/03/2023.
//

import UIKit
import RxSwift
import RxCocoa

class ListFriendCell: UITableViewCell {

    @IBOutlet weak var cltvListUser: UICollectionView!
    let disposeBag = DisposeBag()
    
    var actionSelectCell: ((Int, UserModel) -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setUpView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpView() {
        self.cltvListUser.register(ListUserCollectionViewCell.nibClass, forCellWithReuseIdentifier: ListUserCollectionViewCell.nibNameClass)
    }
    
    func bindingToViewModel(viewModel: HomeViewModel?) {
        self.cltvListUser.delegate = nil
        self.cltvListUser.dataSource = nil
        viewModel?.listUsers.bind(to: self.cltvListUser.rx.items(cellIdentifier: ListUserCollectionViewCell.nibNameClass, cellType: ListUserCollectionViewCell.self)) {row, item, cell in
            cell.configure(item: item)
            cell.actionSelectUser = { [weak self] in
                if let actionSelectCell = self?.actionSelectCell {
                    actionSelectCell(row, item)
                }
            }
        }.disposed(by: disposeBag)
        self.cltvListUser.rx.setDelegate(self).disposed(by: disposeBag)
    }
}

extension ListFriendCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: self.cltvListUser.frame.height)
    }
}
