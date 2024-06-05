//
//  GXPublishLocationSearchVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/17.
//

import UIKit
import RxCocoaPlus
import MBProgressHUD
import RxRelay
import Alamofire
import RxSwift
import GXRefresh

class GXPublishLocationSearchVC: GXBaseViewController {
    private let GX_TMAP_KEY = "1f60d7ca105290a2eb510888558fb4ff"
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: GXBaseTableView!

    var resultType: Int = 1
    var resultList: [GXPoisModel] = []
    var priorityCitys: [GXPrioritycitysModel] = []
    var selectedAction: GXActionBlockItem3<GXPoisModel, String, CLLocationCoordinate2D?>?
    
    private lazy var postModel: GXSearchPostStrModel = {
        return GXSearchPostStrModel()
    }()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !self.didGetNetworktLoad {
            self.searchTextField.becomeFirstResponder()
        }
        self.didGetNetworktLoad = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupViewController() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 0, right: 0)
        self.tableView.rowHeight = 148.0
        self.tableView.placeholder = "未搜索到相关地址"
        self.tableView.register(cellType: GXPublishLocationCell.self)

        self.searchTextField.rx.text.orEmpty.throttle(.milliseconds(500), scheduler: MainScheduler.instance).subscribe (onNext: {[weak self] string in
            guard let `self` = self else { return }
            guard self.searchTextField.markedTextRange == nil else { return }
            if self.postModel.keyWord != string {
                self.postModel.keyWord = string
                self.postModel.specify = nil
                self.searchKeywordRefreshData()
            }
        }).disposed(by: disposeBag)
        
        self.tableView.gx_footer = GXRefreshNormalFooter(completion: { [weak self] in
            self?.searchKeyword(isRefresh: false, isShowHud: false, completion: { isSucceed, isLastPage in
                self?.tableView.gx_footer?.endRefreshing(isNoMore: isLastPage)
            })
        }).then { footer in
            footer.updateRefreshTitles()
        }
    }
    
    func searchKeywordRefreshData() {
        self.searchKeyword(isRefresh: true, isShowHud: true) { [weak self] isSucceed, isLastPage in
            self?.tableView.gx_footer?.endRefreshing(isNoMore: isLastPage)
        }
    }

    func searchKeyword(isRefresh: Bool, isShowHud: Bool, completion: ((Bool, Bool) -> (Void))? = nil) {
        guard (self.postModel.keyWord?.count ?? 0) > 0 else {
            self.clearSearchResult()
            return
        }
        if isRefresh {
            self.postModel.start = 0
        } else {
            self.postModel.start += self.postModel.count
        }
        
        let postStr = self.postModel.toJSONString() ?? ""
        let urlString = "https://api.tianditu.gov.cn/v2/search?postStr=\(postStr)&type=query&tk=\(GX_TMAP_KEY)"
        if isShowHud {
            MBProgressHUD.showLoading()
        }
        AF.request(urlString, method: .get).responseString(completionHandler: {[weak self] response in
            guard let `self` = self else { return }
            MBProgressHUD.dismiss()
            switch response.result {
            case .success(let result):
                if let json = result.jsonValueDecoded() as? Dictionary<String, Any> {
                    let poiModel = GXSearchPoiModel.deserialize(from: json)
                    if poiModel?.resultType == 1 {
                        self.resultType = 1
                        if isRefresh {
                            self.resultList.removeAll()
                        }
                        let list = poiModel?.pois ?? []
                        self.resultList.append(contentsOf: list)
                        self.tableView.gx_reloadData()
                        completion?(true, list.count < self.postModel.count)
                    }
                    else if poiModel?.resultType == 2 {
                        self.resultType = 2
                        self.priorityCitys = poiModel?.statistics?.priorityCitys ?? []
                        self.tableView.gx_reloadData()
                        completion?(true, true)
                    }
                    else {
                        self.clearSearchResult()
                        completion?(false, true)
                    }
                }
                else {
                    self.clearSearchResult()
                    completion?(false, true)
                }
            case .failure(let error):
                MBProgressHUD.showError(text: error.localizedDescription)
                self.clearSearchResult()
                completion?(false, true)
            }
        })
    }
    
    func clearSearchResult() {
        self.resultList = []
        self.priorityCitys = []
        self.tableView.gx_reloadData()
    }
}

extension GXPublishLocationSearchVC {
    @IBAction func cancelButtonClicked(_ sender: UIButton) {
        self.searchTextField.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
}

extension GXPublishLocationSearchVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.resultType == 2 {
            return self.priorityCitys.count
        }
        else {
            return self.resultList.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GXPublishLocationCell = tableView.dequeueReusableCell(for: indexPath)
        if self.resultType == 2 {
            let model = self.priorityCitys[indexPath.row]
            cell.bindCountCell(model: model)
        }
        else {
            let model = self.resultList[indexPath.row]
            cell.bindCell(model: model)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if self.resultType == 2 {
            let model = self.priorityCitys[indexPath.row]
            self.postModel.specify = model.adminCode
            self.searchKeywordRefreshData()
        }
        else {
            self.dismiss(animated: true)
            let model = self.resultList[indexPath.row]
            let lonlatArray = model.lonlat.components(separatedBy: ",")
            var coordinate: CLLocationCoordinate2D?
            if lonlatArray.count == 2 {
                if let lon = Double(lonlatArray[0]), let lat = Double(lonlatArray[1]) {
                    coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                }
            }
            //let cityName: String = model.province + model.city
            let cityName: String = model.city.isEmpty ? model.province : model.city
            self.selectedAction?(model, cityName, coordinate)
        }
    }
}
