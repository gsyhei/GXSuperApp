//
//  GXStripePaymentManager.swift
//  GXSuperApp
//
//  Created by Gin on 2024/8/4.
//

import UIKit
import StripeCore
import StripePaymentSheet
import PromiseKit

class GXStripePaymentManager: NSObject {
    /// 直接支付
    class func paymentSheetToPayment(data: GXStripePaymentData, fromVC: UIViewController) -> Guarantee<PaymentSheetResult> {
        return Guarantee {
            STPAPIClient.shared.publishableKey = data.publishableKey
            // MARK: Create a PaymentSheet instance
            var configuration = PaymentSheet.Configuration()
            configuration.merchantDisplayName = "MarsEnergy"
            configuration.customer = .init(id: data.customer, ephemeralKeySecret: data.ephemeralKey)
            configuration.allowsDelayedPaymentMethods = true
            let paymentShee = PaymentSheet(paymentIntentClientSecret: data.clientSecret, configuration: configuration)
            paymentShee.present(from: fromVC, completion: $0)
        }
    }
    
    /// 预授权支付
    class func paymentSheetToSetUp(data: GXStripePaymentData, fromVC: UIViewController) -> Guarantee<PaymentSheetResult> {
        return Guarantee {
            STPAPIClient.shared.publishableKey = data.publishableKey
            // MARK: Create a PaymentSheet instance
            var configuration = PaymentSheet.Configuration()
            configuration.merchantDisplayName = "MarsEnergy"
            configuration.customer = .init(id: data.customer, ephemeralKeySecret: data.ephemeralKey)
            configuration.allowsDelayedPaymentMethods = true
            let paymentShee = PaymentSheet(setupIntentClientSecret: data.clientSecret, configuration: configuration)
            paymentShee.present(from: fromVC, completion: $0)
        }
    }
    
}
