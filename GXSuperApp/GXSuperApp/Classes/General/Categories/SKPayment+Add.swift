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
import Alamofire
import XCGLogger

private let Box_verifyReceiptUrl = "https://sandbox.itunes.apple.com/verifyReceipt"
private let Buy_verifyReceiptUrl = "https://buy.itunes.apple.com/verifyReceipt"

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
    
    class func validateReceipt(completion: GXActionBlockItem<String?>? = nil) {
        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
              let receiptData = try? Data(contentsOf: appStoreReceiptURL) else {
            DispatchQueue.main.async { completion?(nil) }
            return
        }
        let receiptString = receiptData.base64EncodedString()
        let params: [String : Any] = [
            "receipt-data": receiptString,
            "password": "b3c497a6402441ef912b4ad78e341fcb",
            "exclude-old-transactions": true
        ]
        let requestData = try? JSONSerialization.data(withJSONObject: params, options: [])
        var request = URLRequest(url: URL(string: Box_verifyReceiptUrl)!)
        request.httpMethod = "POST"
        request.httpBody = requestData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                XCGLogger.info("validateReceipt error = \(error.localizedDescription)")
                DispatchQueue.main.async { completion?(nil) }
            }
            else if let data = data, let json = data.jsonValueDecoded() as? [String: Any] {
                let latest_receipt_info = json["latest_receipt_info"] as? [[String: Any]]
                let latest_info = latest_receipt_info?.first
                XCGLogger.info("validateReceipt latest_receipt_info = \(latest_info?.jsonStringEncoded(options: .prettyPrinted) ?? "")")
                let latestUUID = latest_info?["app_account_token"] as? String
                DispatchQueue.main.async { completion?(latestUUID) }
            }
            else {
                DispatchQueue.main.async { completion?(nil) }
            }
        }
        task.resume()
    }
    
}
