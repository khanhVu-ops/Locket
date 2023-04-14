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
    weak var viewModel: HomeViewModel?
    weak var homeVC: HomeViewController?
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
        self.cltvListUser.register(UINib(nibName: "ListUserCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ListUserCollectionViewCell")
    }
    
    func bindingToViewModel(viewModel: HomeViewModel?) {
        self.cltvListUser.delegate = nil
        self.cltvListUser.dataSource = nil
        self.viewModel = viewModel
        viewModel?.listUsers.bind(to: self.cltvListUser.rx.items(cellIdentifier: "ListUserCollectionViewCell", cellType: ListUserCollectionViewCell.self)) {row, item, cell in
            cell.configure(item: item)
        }.disposed(by: disposeBag)
        self.cltvListUser.rx.setDelegate(self).disposed(by: disposeBag)
    }
}

extension ListFriendCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 120)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let chatVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        chatVC.chatViewModel.uid2 = self.viewModel?.listUsers.value[indexPath.item].id
        self.homeVC?.navigationController?.pushViewController(chatVC, animated: true)
    }
}
