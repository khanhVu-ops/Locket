//
//  HomeViewController.swift
//  ChatApp
//
//  Created by Vu Khanh on 06/03/2023.
//

import UIKit
import RxSwift
import RxCocoa
class HomeViewController: UIViewController {
    @IBOutlet weak var tbvListChats: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var vTitle: UIView!
    @IBOutlet weak var topSearchBarConstraint: NSLayoutConstraint!
    private var disposeBag = DisposeBag()
    let homeViewModel = HomeViewModel()
    
    private lazy var tbvSearch: UITableView = {
        let tbv = UITableView()
        return tbv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.homeViewModel.updateData()
        setUpView()
    }
    
    func setUpView() {
        self.searchBar.returnKeyType = .search
        self.tbvListChats.register(UINib(nibName: "ListChatTableViewCell", bundle: nil), forCellReuseIdentifier: "ListChatTableViewCell")
        self.tbvListChats.register(UINib(nibName: "ListFriendCell", bundle: nil), forCellReuseIdentifier: "ListFriendCell")
        self.searchBar.delegate = self
        self.searchBar.showsCancelButton = false
        self.bindingToViewModel()
        
        self.view.addSubview(tbvSearch)
        self.tbvSearch.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.tbvSearch.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor),
            self.tbvSearch.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tbvSearch.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tbvSearch.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 10),
        ])
        
        self.tbvSearch.backgroundColor = .white
        self.tbvSearch.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchTableViewCell")
        self.tbvSearch.separatorStyle = .none
        self.tbvSearch.rowHeight = UITableView.automaticDimension
        self.tbvSearch.isHidden = true
    }
    
    func bindingToViewModel() {
        self.homeViewModel.listChatRooms
            .bind(to: self.tbvListChats.rx.items) { [weak self] (tableView, index, element) -> UITableViewCell in
                if index == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ListFriendCell") as! ListFriendCell
                    cell.homeVC = self
                    cell.bindingToViewModel(viewModel: self?.homeViewModel)
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ListChatTableViewCell", for: IndexPath(row: index, section: 0)) as! ListChatTableViewCell
                    cell.configure(item: element)
                    return cell
                }
            }
            .disposed(by: disposeBag)
        
        self.tbvListChats.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        self.homeViewModel.listSearchUsers
            .bind(to: self.tbvSearch.rx.items(cellIdentifier: "SearchTableViewCell", cellType: SearchTableViewCell.self)) { row, item, cell in
            cell.configure(item: item)
            }
            .disposed(by: disposeBag)
        
        self.tbvSearch.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        self.searchBar.rx.text
            .orEmpty
            .subscribe(onNext: { [weak self] searchText in
                self?.tbvSearch.isHidden = false
                self?.homeViewModel.handleQuery(query: searchText)
                print(searchText)
            })
            .disposed(by: disposeBag)
        
        self.homeViewModel.isEnableSearch
            .subscribe(onNext: {[weak self] isEnable in
                self?.searchBar.showsCancelButton = isEnable
                self?.tbvSearch.isHidden = !isEnable
                self?.vTitle.isHidden = isEnable
            })
            .disposed(by: disposeBag)
        
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let chatVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        if tableView == tbvListChats {
            if indexPath.item > 0 {
                chatVC.chatViewModel.uid2 = self.homeViewModel.getUid2FromUsers(users: self.homeViewModel.listChatRooms.value[indexPath.item].users!)
            }
        } else {
            chatVC.chatViewModel.uid2 = self.homeViewModel.listSearchUsers.value[indexPath.item].id
        }
        self.navigationController?.pushViewController(chatVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}
extension HomeViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
        self.searchBar.text = nil
        self.tbvSearch.isHidden = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.homeViewModel.isEnableSearch.accept(true)
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
            DispatchQueue.main.async {
                self.topSearchBarConstraint.constant = 0
            }
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.homeViewModel.isEnableSearch.accept(false)
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
            DispatchQueue.main.async {
                self.topSearchBarConstraint.constant = 40
            }
        }
    }
    
}
