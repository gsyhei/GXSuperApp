//
//  GXMinePtOtherVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/8.
//

import UIKit
import GXRefresh
import MBProgressHUD
import HXPhotoPicker

class GXMinePtOtherVC: GXBaseViewController {
    private lazy var tableView: GXBaseTableView = {
        return GXBaseTableView(_frame: self.view.bounds, _style: .plain).then {
            $0.backgroundColor = .white
            $0.placeholder = "暂⽆发布的活动"
            $0.dataSource = self
            $0.delegate = self
            $0.rowHeight = 170.0
            $0.register(cellType: GXPrCalendarActivityPageCell.self)
        }
    }()

    private lazy var backButton: UIButton = {
        return UIButton(type: .custom).then {
            $0.setImage(UIImage(named: "w_back"), for: .normal)
            $0.addTarget(self, action: #selector(self.backBarButtonItemTapped), for: .touchUpInside)
        }
    }()

    private lazy var headerView: GXMinePtOtherHeaderView = {
        return GXMinePtOtherHeaderView.xibView().then {
            $0.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 306)
            $0.backgroundColor = .red
            $0.avatarAction = {[weak self] in
                self?.showAvatar()
            }
            $0.attentionAction = {[weak self] in
                self?.requestFollowUser()
            }
        }
    }()

    private lazy var viewModel: GXMinePtOtherViewModel = {
        return GXMinePtOtherViewModel()
    }()

    class func push(fromVC: UIViewController, userId: String) {
        let vc = GXMinePtOtherVC(userId: userId)
        vc.hidesBottomBarWhenPushed = true
        fromVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    required init(userId: String) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel.userId = userId
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestRefreshData()
    }

    override func setupViewController() {
        self.view.backgroundColor = .white
        self.view.addSubview(self.headerView)
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.backButton)
        self.headerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalTo(self.view.safeAreaLayoutGuide.snp.left)
            make.right.equalTo(self.view.safeAreaLayoutGuide.snp.right)
            make.height.equalTo(306)
        }
        self.tableView.snp.makeConstraints { make in
            make.top.equalTo(self.headerView.snp.bottom)
            make.left.equalTo(self.view.safeAreaLayoutGuide.snp.left)
            make.right.equalTo(self.view.safeAreaLayoutGuide.snp.right)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
        self.backButton.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.left.equalTo(self.view.safeAreaLayoutGuide.snp.left)
            make.size.equalTo(CGSize(width: 52, height: 44))
        }
        
        if GXUserManager.shared.roleType == .publisher {
            self.tableView.placeholder = nil
        } else {
            self.tableView.placeholder = "暂⽆发布的活动"
        }
        self.tableView.gx_header = GXRefreshNormalHeader(completion: { [weak self] in
            self?.requestData(isRefresh: true, isShowHud: false, completion: { isSucceed, isLastPage in
                self?.tableView.gx_header?.endRefreshing(isNoMore: isLastPage, isSucceed: isSucceed)
            })
        }).then({ header in
            header.updateRefreshTitles()
        })
        self.tableView.gx_footer = GXRefreshNormalFooter(completion: { [weak self] in
            self?.requestData(isRefresh: false, isShowHud: false, completion: { isSucceed, isLastPage in
                self?.tableView.gx_footer?.endRefreshing(isNoMore: isLastPage)
            })
        }).then { footer in
            footer.updateRefreshTitles()
        }
    }
}

extension GXMinePtOtherVC {
    func updateShowUser() {
        self.headerView.bindModel(model: self.viewModel.data)
        let height = GXMinePtOtherHeaderView.getHeaderHeight(text: self.viewModel.data?.personalIntroduction)
        self.headerView.snp.updateConstraints { make in
            make.height.equalTo(height)
        }
        self.tableView.gx_reloadData()
    }
    func showAvatar() {
        guard let image = self.headerView.avatarButton.image(for: .normal) else { return }
        HXPhotoPicker.PhotoBrowser.show(pageIndex: 0, transitionalImage: image) {
            return 1
        } assetForIndex: {_ in
            return PhotoAsset(localImageAsset: LocalImageAsset(image: image))
        } transitionAnimator: { index in
            return self.headerView.avatarButton
        }
    }
}

extension GXMinePtOtherVC {
    func requestData(isRefresh: Bool, isShowHud: Bool, completion: ((Bool, Bool) -> (Void))? = nil) {
        if isShowHud {
            MBProgressHUD.showLoading(to: self.view)
        }
        self.viewModel.requestGetAllUserHomepage(refresh: isRefresh, success: {[weak self] isLastPage in
            MBProgressHUD.dismiss(for: self?.view)
            self?.updateShowUser()
            completion?(true, isLastPage)
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
            completion?(false, false)
        })
    }
    func requestRefreshData() {
        self.requestData(isRefresh: true, isShowHud: true) { [weak self] isSucceed, isLastPage in
            self?.tableView.gx_footer?.endRefreshing(isNoMore: isLastPage)
        }
    }
    func requestFollowUser() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestFollowUser {[weak self] in
            MBProgressHUD.dismiss(for: self?.view)
            self?.updateShowUser()
        } failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        }
    }
}

extension GXMinePtOtherVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.list.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GXPrCalendarActivityPageCell = tableView.dequeueReusableCell(for: indexPath)
        let model = self.viewModel.list[indexPath.row]
        cell.bindCell(model: model)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let model = self.viewModel.list[indexPath.row]
        let vc = GXParticipantActivityDetailVC.createVC(activityId: model.id)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
