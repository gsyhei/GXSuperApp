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
            payment.gx_promise().done { transaction in
                seal.fulfill(transaction)
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    public func gx_promise() -> Promise<SKPaymentTransaction> {
        return GXPaymentObserver(payment: self).promise
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
            seal.fulfill(transaction)
            queue.remove(self)
            retainCycle = nil
        case .failed:
            let error = transaction.error ?? PMKError.cancelled
            queue.finishTransaction(transaction)
            seal.reject(error)
            queue.remove(self)
            retainCycle = nil
        default:
            break
        }
    }
}
