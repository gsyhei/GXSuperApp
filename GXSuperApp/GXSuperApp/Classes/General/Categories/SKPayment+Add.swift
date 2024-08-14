//
//  SKPayment+Add.swift
//  GXSuperApp
//
//  Created by Gin on 2024/8/13.
//

#if !PMKCocoaPods
import PromiseKit
#endif
import StoreKit

extension SKPayment {
    
    class func gx_paymentPromise(response: SKProductsResponse) -> Promise<SKPaymentTransaction> {
        return Promise { seal in
            guard let product = response.products.first(where: {$0.productIdentifier == GX_PRODUCT_ID}) else {
                let error = GXError(code: -101, info: "No products were acquired")
                seal.reject(error); return
            }
            let payment = SKMutablePayment(product: product)
            payment.applicationUsername = GXUserManager.shared.user?.uuid
            payment.promise().done { transaction in
                seal.fulfill(transaction)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    @available(iOS 16.0, *)
    class func gx_verificationResult() async {
        do {
            let verificationResult = try await AppTransaction.shared
            switch verificationResult {
            case .verified(let appTransaction):
                // StoreKit verified that the user purchased this app and
                // the properties in the AppTransaction instance.
                // Add your code here.
                
                break
            case .unverified(let appTransaction, let verificationError):
                // The app transaction didn't pass StoreKit's verification.
                // Handle unverified app transaction information according
                // to your business model.
                // Add your code here.
                
                break
            }
        } catch {}
    }
    
}
