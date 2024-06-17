//
//  GXHomeSearchVC.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/15.
//

import UIKit
import Hero
import GXRefresh
import RxCocoaPlus
import XCGLogger
import RxSwift
import PromiseKit
import MBProgressHUD

class GXHomeSearchVC: GXBaseViewController {
    let homeSearchVCHeroId = "GXHomeSearchBar"
    @IBOutlet weak var searchBar: UIView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var tableView: GXBaseTableView!
    
    private lazy var viewModel: GXHomeSearchViewModel = {
        return GXHomeSearchViewModel()
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !self.didGetNetworktLoad {
            self.didGetNetworktLoad = true
            self.searchTF.becomeFirstResponder()
        }
    }
    
    override func loadView() {
        super.loadView()
        self.searchBar.hero.id = self.homeSearchVCHeroId
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Search"
        self.gx_addBackBarButtonItem()
    }

    override func setupViewController() {
        self.searchButton.setBackgroundColor(.gx_green, for: .normal)
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
        self.tableView.register(cellType: GXHomeSearchResultCell.self)
        self.tableView.register(cellType: GXHomeSearchHistoryCell.self)
        self.tableView.register(cellType: GXHomeSearchAutocompleteCell.self)
        self.tableView.register(cellType: GXHomeMarkerCell.self)

        self.tableView.gx_footer = GXRefreshNormalFooter(completion: {
            
        }).then { footer in
            footer.updateRefreshTitles()
        }
        
        self.searchTF.delegate = self
        (self.searchTF.rx.textInput <-> self.viewModel.searchWord).disposed(by: disposeBag)
        self.searchTF.rx.text.orEmpty.throttle(.milliseconds(500), scheduler: MainScheduler.instance).subscribe (onNext: { [weak self] text in
            guard let `self` = self else { return }
            if text.count == 0 {
                self.requestShowHistory()
            } else {
                self.requestAutocomplete()
            }
            XCGLogger.info("self.searchTF.rx.text.orEmpty = \(text)")
        }).disposed(by: disposeBag)
    }
    
    @IBAction func searchButtonClicked(_ sender: Any?) {
        self.requestSearchByText()
    }
    
    func requestShowHistory() {
        self.viewModel.searchType = .history
        self.tableView.backgroundColor = .white
        self.tableView.reloadData()
        self.tableView.gx_footer?.endRefreshing(isNoMore: true)
    }
    
    func requestAutocomplete() {
        firstly {
            self.viewModel.requestAutocomplete()
        }.done { results in
            self.viewModel.searchType = .autocomplete
            self.tableView.backgroundColor = .white
            self.tableView.reloadData()
            self.tableView.gx_footer?.endRefreshing(isNoMore: true)
        }.catch { error in
            XCGLogger.info("error = \(error.localizedDescription)")
        }
    }
    
    func requestSearchByText() {
        MBProgressHUD.showContentLoading()
        firstly {
            self.viewModel.requestSearchByText()
        }.done { results in
            self.viewModel.searchType = .result
            self.tableView.backgroundColor = .white
            self.tableView.reloadData()
            self.tableView.gx_footer?.endRefreshing(isNoMore: true)
            MBProgressHUD.dismiss()
        }.catch { error in
            XCGLogger.info("error = \(error.localizedDescription)")
            MBProgressHUD.dismiss()
            MBProgressHUD.showInfo(text: error.localizedDescription)
        }
    }
    
}

extension GXHomeSearchVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.viewModel.searchType {
        case .history:
            return 1
        case .autocomplete:
            return self.viewModel.autocompleteList.count
        case .result:
            return self.viewModel.placeResults.count
        case .data:
            return 1
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.viewModel.searchType {
        case .history:
            let cell: GXHomeSearchHistoryCell = tableView.dequeueReusableCell(for: indexPath)
            return cell
        case .autocomplete:
            let cell: GXHomeSearchAutocompleteCell = tableView.dequeueReusableCell(for: indexPath)
            let model = self.viewModel.autocompleteList[indexPath.row]
            cell.bindCell(model: model)
            return cell
        case .result:
            let cell: GXHomeSearchResultCell = tableView.dequeueReusableCell(for: indexPath)
            let model = self.viewModel.placeResults[indexPath.row]
            cell.bindCell(model: model)
            return cell
        case .data:
            let cell: GXHomeMarkerCell = tableView.dequeueReusableCell(for: indexPath)
            return cell
        }
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch self.viewModel.searchType {
        case .history:
            return 0
        case .autocomplete:
            return 44
        case .result:
            return 66
        case .data:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch self.viewModel.searchType {
        case .history:
            return 300
        case .autocomplete:
            return UITableView.automaticDimension
        case .result:
            return UITableView.automaticDimension
        case .data:
            return 133
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch self.viewModel.searchType {
        case .history: break
        case .autocomplete:
            let model = self.viewModel.autocompleteList[indexPath.row]
            self.searchTF.text = model.placeSuggestion?.attributedPrimaryText.string
            self.requestSearchByText()
        case .result: break
        case .data: break
        }
    }
}

extension GXHomeSearchVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard self.viewModel.searchWord.value?.count ?? 0 > 0 else {
            return true
        }
        self.requestSearchByText()
        return true
    }
}
