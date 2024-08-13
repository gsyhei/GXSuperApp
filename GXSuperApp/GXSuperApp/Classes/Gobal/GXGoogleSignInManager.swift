//
//  GXGoogleSignInManager.swift
//  GXSuperApp
//
//  Created by Gin on 2024/8/13.
//

import UIKit
import FirebaseCore
import GoogleSignIn
import FirebaseAuth
import PromiseKit
import XCGLogger

class GXGoogleSignInManager: NSObject {
    static let shared: GXGoogleSignInManager = GXGoogleSignInManager()
    
    func signIn(_: PMKNamespacer, presenting: UIViewController) -> Promise<String> {
        return Promise { seal in
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                let error = GXError(code: -102, info: "Firebase clientID error")
                seal.reject(error); return
            }
            // Create Google Sign In configuration object.
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config
            // Start the sign in flow!
            GIDSignIn.sharedInstance.signIn(withPresenting: presenting) { (result, error) in
                guard error == nil else {
                    seal.reject(error!); return
                }
                guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                    let error = GXError(code: -104, info: "GIDSignIn idToken error")
                    seal.reject(error); return
                }
                XCGLogger.info("Google idToken: \(idToken)")
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
                Auth.auth().signIn(with: credential) { result1, error1 in
                    if let error1 = error1 {
                        seal.reject(error1)
                    }
                    else {
                        result1?.user.getIDToken(completion: { firebaseIdToken, error2 in
                            if let error2 = error2 {
                                seal.reject(error2)
                            }
                            else {
                                XCGLogger.info("Firebase idToken: \(firebaseIdToken ?? "")")
                                seal.fulfill(firebaseIdToken ?? "")
                            }
                        })
                    }
                }
            }
        }
    }
    
    func signOut() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
}
