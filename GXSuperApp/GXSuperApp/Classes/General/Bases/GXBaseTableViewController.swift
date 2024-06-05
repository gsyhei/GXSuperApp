//
//  GXBaseTableViewController.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/28.
//

import UIKit
import RxSwift

class GXBaseTableViewController: UITableViewController {
    let disposeBag = DisposeBag()
    weak var cancelViewModel: GXBaseViewModel?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let viewModel = self.cancelViewModel {
            viewModel.gx_cancellablesAll()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViewController()
    }

    public func setupViewController() {
        fatalError("Must Override.")
    }

    public func gx_addBackBarButtonItem(action: Selector = #selector(gx_backBarButtonItemTapped)) {
        let normalImage = UIImage(named: "l_back")?.withRenderingMode(.automatic)
        let leftBarButtonItem = UIBarButtonItem(image: normalImage, style: .plain, target: self, action: action)
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }

    @objc public func gx_backBarButtonItemTapped() {
        if (self.navigationController?.popViewController(animated: true) == nil) {
            self.dismiss(animated: true, completion: nil)
        }
    }

}
