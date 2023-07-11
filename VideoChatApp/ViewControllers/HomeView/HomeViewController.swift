//
//  HomeViewController.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 18/06/5 Reiwa.
//

import UIKit
import RxSwift
import RxCocoa
class HomeViewController: BaseViewController {
    
    @IBOutlet weak var tbvListChats: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var vTitle: UIView!
    @IBOutlet weak var lbTitle: UILabel!
    let viewModel = HomeViewModel()
    
    private lazy var tbvSearch: UITableView = {
        let tbv = UITableView()
        tbv.allowsSelection = false
        return tbv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.handleWhenFinishSearch()
    }
    
    override func setUpUI() {
        
        self.view.addSubview(tbvSearch)
        self.tbvSearch.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.tbvSearch.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor),
            self.tbvSearch.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tbvSearch.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tbvSearch.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 10),
        ])
        
        self.tbvSearch.backgroundColor = .white
        self.tbvSearch.separatorStyle = .none
        self.tbvSearch.rowHeight = UITableView.automaticDimension
        self.tbvSearch.isHidden = true
        
        self.lbTitle.textColor = Constants.Color.mainColor
        
        self.searchBar.returnKeyType = .search
        self.searchBar.delegate = self
        self.searchBar.showsCancelButton = false
        
        self.tbvListChats.register(ListChatTableViewCell.nibClass, forCellReuseIdentifier: ListChatTableViewCell.nibNameClass)
        self.tbvListChats.register(ListFriendCell.nibClass, forCellReuseIdentifier: ListFriendCell.nibNameClass)
        self.tbvSearch.register(SearchTableViewCell.nibClass, forCellReuseIdentifier: SearchTableViewCell.nibNameClass)
        self.tbvListChats.delegate = self
        self.tbvListChats.dataSource = self
        self.tbvSearch.delegate = self
        self.tbvSearch.dataSource = self
    }
    
    override func bindViewModel() {
        Observable.combineLatest(self.viewModel.getListChats(), self.viewModel.getListUsers())
            .subscribe(onNext: { [weak self] chats, users in
                self?.viewModel.listChats.accept([ConverationModel()] + chats)
                self?.viewModel.listUsers.accept(users)
                self?.tbvListChats.reloadData()
            })
            .disposed(by: disposeBag)
        
        self.searchBar.rx.text
            .orEmpty
            .subscribe(onNext: { [weak self] searchText in
                self?.tbvSearch.isHidden = false
                self?.viewModel.handleQuery(query: searchText)
            })
            .disposed(by: disposeBag)
        
        self.viewModel.listSearchs
            .subscribe(onNext: { [weak self] users in
                self?.tbvSearch.reloadData()
            })
            .disposed(by: disposeBag)
        
        self.viewModel.isEnableSearch
            .subscribe(onNext: {[weak self] isEnable in
                self?.searchBar.showsCancelButton = isEnable
                self?.tbvSearch.isHidden = !isEnable
                self?.vTitle.isHidden = isEnable
            })
            .disposed(by: disposeBag)
    }
    
    func goToChatVC(conversationID: String, uid2: String, user: UserModel) {
        let chatVC = ChatViewController()
        chatVC.viewModel.uid2 = uid2
        chatVC.viewModel.conversationID.accept(conversationID)
        chatVC.viewModel.user.accept(user)
        self.push(chatVC)
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tbvListChats {
            return self.viewModel.listChats.value.count
        } else {
            return self.viewModel.listSearchs.value.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tbvListChats {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: ListFriendCell.nibNameClass) as! ListFriendCell
                cell.bindingToViewModel(viewModel: self.viewModel)
                cell.actionSelectCell = { [weak self] index, user in
                    self?.goToChatVC(conversationID: "", uid2: self?.viewModel.listUsers.value[index].id ?? "", user: user)
                }
                return cell
            } else {
                let element = self.viewModel.listChats.value[indexPath.row]
                let cell = tableView.dequeueReusableCell(withIdentifier: ListChatTableViewCell.nibNameClass, for: IndexPath(row: indexPath.row, section: 0)) as! ListChatTableViewCell
                cell.configure(viewModel: self.viewModel, item: element)
                cell.actionSelectRow = { [weak self] conversationID, uid2, user in
                    self?.goToChatVC(conversationID: conversationID, uid2: uid2, user: user)
                }
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.nibNameClass) as! SearchTableViewCell
            let item = self.viewModel.listSearchs.value[indexPath.row]
            cell.configure(item: item)
            cell.actionSelectRow = { [weak self] uid2, user in
                self?.goToChatVC(conversationID: "", uid2: uid2, user: user)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension HomeViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.handleWhenFinishSearch()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.viewModel.isEnableSearch.accept(true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.viewModel.isEnableSearch.accept(false)
    }
}

extension HomeViewController {
    func handleWhenFinishSearch() {
        self.searchBar.endEditing(true)
        self.searchBar.text = nil
        self.tbvSearch.isHidden = true
    }
}

