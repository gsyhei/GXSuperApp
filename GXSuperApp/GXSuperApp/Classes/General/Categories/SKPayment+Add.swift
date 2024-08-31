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
import MBProgressHUD

private let Box_verifyReceiptUrl = "https://sandbox.itunes.apple.com/verifyReceipt"
private let Buy_verifyReceiptUrl = "https://buy.itunes.apple.com/verifyReceipt"

extension SKPayment {
    
    public func gx_promise() -> Promise<SKPaymentTransaction> {
        return GXPaymentObserver(payment: self).promise
    }
    
    class func gx_paymentPromise(response: SKProductsResponse) -> Promise<SKPaymentTransaction> {
        return Promise { seal in
            guard let product = response.products.first(where: {$0.productIdentifier == GX_PRODUCT_ID}) else {
                let error = GXError(code: -101, info: "No products were acquired")
                seal.reject(error); return
            }
            let payment = SKMutablePayment(product: product)
            payment.applicationUsername = GXUserManager.shared.user?.uuid
            payment.gx_promise().done { transaction in
                seal.fulfill(transaction)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    class func validateReceipt(completion: GXActionBlockItem<GXReceiptInfoItemModel?>? = nil) {
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
                let latest_info = latest_receipt_info?.first as? [String: Any]
                XCGLogger.info("validateReceipt latest_receipt_info = \(latest_info?.jsonStringEncoded(options: .prettyPrinted) ?? "")")
                let model = GXReceiptInfoItemModel.deserialize(from: latest_info)
                DispatchQueue.main.async { completion?(model) }
            }
            else {
                DispatchQueue.main.async { completion?(nil) }
            }
        }
        task.resume()
    }
    
}

private class GXPaymentObserver: NSObject, SKPaymentTransactionObserver {
    let (promise, seal) = Promise<SKPaymentTransaction>.pending()
    let payment: SKPayment
    var retainCycle: GXPaymentObserver?
    
    init(payment: SKPayment) {
        self.payment = payment
        super.init()
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(payment)
        retainCycle = self
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        guard let transaction = transactions.first(where: { $0.payment.productIdentifier == payment.productIdentifier }) else {
            return
        }
        switch transaction.transactionState {
        case .purchased, .restored:
            queue.finishTransaction(transaction)
            seal.fulfill(transaction)
            queue.remove(self)
            retainCycle = nil
        case .failed:
            let error = transaction.error ?? PMKError.cancelled
            queue.finishTransaction(transaction)
            seal.reject(error)
            queue.remove(self)
            retainCycle = nil
            MBProgressHUD.dismiss()
        default:
            break
        }
    }
}
