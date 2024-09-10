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
import GooglePlaces

class GXHomeSearchVC: GXBaseViewController {
    let homeSearchVCHeroId = "GXHomeSearchBar"
    @IBOutlet weak var searchBar: UIView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var tableView: GXBaseTableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.register(headerFooterViewType: GXHomeSearchHeader.self)
            tableView.register(cellType: GXHomeSearchResultCell.self)
            tableView.register(cellType: GXHomeSearchHistoryCell.self)
            tableView.register(cellType: GXHomeSearchAutocompleteCell.self)
            tableView.register(cellType: GXHomeMarkerCell.self)
        }
    }
    var searchAction: GXActionBlockItem<GXPlace>?
    
    private lazy var viewModel: GXHomeSearchViewModel = {
        return GXHomeSearchViewModel()
    }()
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.searchTF.resignFirstResponder()
    }
    
    override func viewDidAppearForOnlyLoading() {
        self.searchTF.becomeFirstResponder()
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
        self.searchButton.setBackgroundColor(.gx_drakGreen, for: .highlighted)

        self.tableView.gx_footer = GXRefreshNormalFooter(completion: {
            
        }).then { footer in
            footer.updateRefreshTitles()
        }
        
        (self.searchTF.rx.text <-> self.viewModel.searchWord).disposed(by: disposeBag)
        self.searchTF.delegate = self
        self.searchTF.rx.text.orEmpty.distinctUntilChanged()
            .throttle(.milliseconds(100), scheduler: MainScheduler.instance)
            .subscribe (onNext: { [weak self] text in
                XCGLogger.info("self.searchTF.rx.text.orEmpty = \(text)")
                guard let `self` = self else { return }
                if text.count == 0 {
                    self.requestShowHistory()
                } 
                else {
                    guard !self.viewModel.isSearchResult else { return }
                    self.requestAutocomplete()
                }
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
        let searchWord = self.viewModel.searchWord.value
        firstly {
            self.viewModel.requestAutocomplete()
        }.done { results in
            self.viewModel.searchType = .autocomplete
            self.tableView.backgroundColor = .white
            if self.viewModel.searchWord.value == searchWord {
                self.tableView.reloadData()
                self.tableView.gx_footer?.endRefreshing(isNoMore: true)
            }
        }.catch { error in
            XCGLogger.info("error = \(error.localizedDescription)")
        }
    }
    
    func requestSearchByText(_ text: String? = nil) {
        MBProgressHUD.showLoading()
        self.viewModel.isSearchResult = true
        self.searchTF.resignFirstResponder()
        if let text = text {
            self.viewModel.searchWord.accept(text)
            self.searchTF.sendActions(for: .valueChanged)
        }
        firstly {
            self.viewModel.requestSearchByText()
        }.done { results in
            self.viewModel.searchType = .result
            self.tableView.backgroundColor = .white
            self.tableView.reloadData()
            self.tableView.gx_footer?.endRefreshing(isNoMore: true)
            self.viewModel.isSearchResult = false
            MBProgressHUD.dismiss()
        }.catch { error in
            XCGLogger.info("error = \(error.localizedDescription)")
            self.viewModel.isSearchResult = false
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
            cell.updateDataSource()
            cell.action = {[weak self] place in
                guard let `self` = self else { return }
                self.searchAction?(place)
                self.gx_backBarButtonItemTapped()
            }
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
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch self.viewModel.searchType {
        case .history:
            return 44
        case .autocomplete:
            return 0
        case .result:
            return 44
        case .data:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch self.viewModel.searchType {
        case .history: 
            let header = tableView.dequeueReusableHeaderFooterView(GXHomeSearchHeader.self)
            header?.updateHeader(name: "History", iconName: "search_list_ic_history", isShowButton: true)
            header?.deleteAction = {[weak self] in
                guard let `self` = self else { return }
                GXPlacesManager.shared.clearPlaces()
                self.tableView.reloadData()
            }
            return header
        case .autocomplete: return nil
        case .result:
            let header = tableView.dequeueReusableHeaderFooterView(GXHomeSearchHeader.self)
            header?.updateHeader(name: "Result", iconName: "search_list_ic_result", isShowButton: false)
            return header
        case .data: return nil
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch self.viewModel.searchType {
        case .history: break
        case .autocomplete:
            let model = self.viewModel.autocompleteList[indexPath.row]
            self.requestSearchByText(model.placeSuggestion?.attributedPrimaryText.string)
        case .result:
            let model = self.viewModel.placeResults[indexPath.row]
            let place = GXPlace(placeID: model.placeID, address: model.name, coordinate: model.coordinate)
            GXPlacesManager.shared.addPlaces(place: place)
            self.searchAction?(place)
            self.gx_backBarButtonItemTapped()
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
