//
//  ViewController.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/4.
//

import UIKit
import PromiseKit
import XCGLogger

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .red
       
        
//        firstly {
//            UIView.animate(.promise, duration: 1) {
//                XCGLogger.info("animate")
//            }
//        }.done {_ in 
//            XCGLogger.info("animate done")
//        }
//        
//        firstly {
//            NotificationCenter.default.observe(once: Notification.Name(rawValue: "Notice"))
//        }.done {_ in
//            XCGLogger.info("Notice done")
//        }
//        
//        UIView.animate(.promise, duration: 1) {
//            XCGLogger.info("animate")
//        }.done { finished in
//            
//        }
//        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Notice", style: .done, target: self, action: #selector(rightBarButtonItemClicked))
//        
//        Promise { seal in
//            seal.resolve("" as? Error)
//            seal.reject(("" as? Error)!)
//        }.done { asd in
//            
//        }.catch { error in
//            
//        }
//        
//        Promise<Any> { seal in
//            after(seconds: 5.0).done {
//                let err = NSError(domain: "error", code: 111)
//                seal.reject(err)
//            }
//        }.done { asd in
//            XCGLogger.info("done")
//        }.catch { error in
//            XCGLogger.info("error \(error.localizedDescription)")
//        }
    }

    @objc func rightBarButtonItemClicked() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "Notice"), object: nil)
        
        Promise<String> { seal in
            after(seconds: 1.0).done {
                let err = NSError(domain: "Domain", code: 111)
                seal.reject(err)
            }
        }.done { asd in
            XCGLogger.info("done")
        }.catch { error in
            XCGLogger.info("Error: \((error as NSError).domain)")
        }
    }

    
}

