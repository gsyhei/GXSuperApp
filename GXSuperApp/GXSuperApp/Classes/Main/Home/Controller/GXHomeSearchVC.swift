//
//  GXHomeSearchVC.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/15.
//

import UIKit
import Hero

class GXHomeSearchVC: GXBaseViewController {
    let homeSearchVCHeroId = "GXHomeSearchBar"
    @IBOutlet weak var searchBar: UIView!
    @IBOutlet weak var searchTF: UITextField!

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
        
    }
    
}
