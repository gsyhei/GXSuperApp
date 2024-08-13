//
//  SKPaymentQueue+Add.swift
//  GXSuperApp
//
//  Created by Gin on 2024/8/13.
//

#if !PMKCocoaPods
import PromiseKit
#endif
import StoreKit

public extension SKPaymentQueue {
    func gx_restoreCompletedTransactions(_: PMKNamespacer) -> Promise<[SKPaymentTransaction]> {
        return GXPaymentObserver(self).promise
    }

    func gx_restoreCompletedTransactions(_: PMKNamespacer, withApplicationUsername username: String?) -> Promise<[SKPaymentTransaction]> {
        return GXPaymentObserver(self, withApplicationUsername: true, userName: username).promise
    }
}

private class GXPaymentObserver: NSObject, SKPaymentTransactionObserver {
    let (promise, seal) = Promise<[SKPaymentTransaction]>.pending()
    var retainCycle: GXPaymentObserver?
    var finishedTransactions = [SKPaymentTransaction]()

    //TODO:PMK7: this is weird, just have a `String?` parameter
    init(_ paymentQueue: SKPaymentQueue, withApplicationUsername: Bool = false, userName: String? = nil) {
        super.init()
        paymentQueue.add(self)
        withApplicationUsername ?
            paymentQueue.restoreCompletedTransactions() :
            paymentQueue.restoreCompletedTransactions(withApplicationUsername: userName)
        retainCycle = self
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions where transaction.transactionState == .restored {
            finishedTransactions.append(transaction)
        }
    }

    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        resolve(queue, nil)
    }

    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        resolve(queue, error)
    }

    func resolve(_ queue: SKPaymentQueue, _ error: Error?) {
        if let error = error {
            seal.reject(error)
        } else {
            seal.fulfill(finishedTransactions)
        }
        queue.remove(self)
        retainCycle = nil
    }
}

