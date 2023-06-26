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
    let viewModel = HomeViewModel()
    
    private lazy var tbvSearch: UITableView = {
        let tbv = UITableView()
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
                print("users", users.count)
                self?.tbvListChats.reloadData()
            })
            .disposed(by: disposeBag)
        
        self.searchBar.rx.text
            .orEmpty
            .subscribe(onNext: { [weak self] searchText in
                self?.tbvSearch.isHidden = false
                self?.viewModel.handleQuery(query: searchText)
                self?.tbvSearch.reloadData()
                print(searchText)
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
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tbvListChats {
            print(self.viewModel.listChats.value.count)
            return self.viewModel.listChats.value.count
        } else {
            return self.viewModel.listSearchs.value.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tbvListChats {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ListFriendCell") as! ListFriendCell
                cell.homeVC = self
                cell.bindingToViewModel(viewModel: self.viewModel)
                return cell
            } else {
                let element = self.viewModel.listChats.value[indexPath.row]
                let cell = tableView.dequeueReusableCell(withIdentifier: "ListChatTableViewCell", for: IndexPath(row: indexPath.row, section: 0)) as! ListChatTableViewCell
                cell.configure(viewModel: self.viewModel, item: element)
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.nibNameClass) as! SearchTableViewCell
            let item = self.viewModel.listSearchs.value[indexPath.row]
            cell.configure(item: item)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let chatVC = ChatViewController()
        if tableView == tbvListChats {
            if indexPath.item > 0 {
                chatVC.viewModel.uid2 = self.viewModel.listChats.value[indexPath.row].uid2
                chatVC.viewModel.conversationID = self.viewModel.listChats.value[indexPath.row].conversationID ?? ""
            }
        } else {
            chatVC.viewModel.uid2 = self.viewModel.listSearchs.value[indexPath.item].id ?? ""
        }
        self.navigationController?.pushViewController(chatVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
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

