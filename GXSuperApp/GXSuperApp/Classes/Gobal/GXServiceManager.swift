//
//  GXUserManager.swift
//  GXLearningManagement
//
//  Created by Gin on 2021/7/14.
//

import UIKit
import XCGLogger
import GXCategories
import Alamofire

class GXServiceManager: NSObject {
    /// 是否有网络
    private(set) var networkStatus: NetworkReachabilityManager.NetworkReachabilityStatus = .unknown
    /// 服务器时间与本地时间差
    private(set) var timeDifference: TimeInterval = 0
    /// 网络监听管理器 www.google.com / www.baidu.com
    private let networkManager = NetworkReachabilityManager(host: "www.baidu.com")
    /// 当前时区差值
    private(set) lazy var currentTimeZoneValue: String = {
        let timeZoneDifference = TimeInterval(TimeZone.current.secondsFromGMT()) / 3600.0
        return String(format: "%.1f", timeZoneDifference)
    }()

    static let shared: GXServiceManager = {
        let instance = GXServiceManager()
        return instance
    }()

    deinit {
        networkManager?.stopListening()
    }
}

extension GXServiceManager {
    public var systemDate: Date {
        return Date(timeIntervalSinceNow: GXServiceManager.shared.timeDifference)
    }    
    class func updateSystemTime(response: HTTPURLResponse?) {
        guard GXServiceManager.shared.timeDifference == 0 else { return }
        if let allHeaderFields = response?.allHeaderFields {
            if let dateStr: String = allHeaderFields[AnyHashable("Date")] as? String {
                XCGLogger.debug("System Date: \(dateStr)")
                let format = "E, dd MMM yyyy HH:mm:ss zzz"
                let systemDate = Date.date(dateString: dateStr, format: format, locale: Locale(identifier: "US"))
                if let date = systemDate {
                    XCGLogger.debug("System Date: \(date.string(format: "yyyy-MM-dd HH:mm:ss"))")
                    GXServiceManager.shared.timeDifference = date.timeIntervalSinceNow
                }
            }
        }
    }
    class func startListening() {
        GXServiceManager.shared.networkManager?.startListening { status in
            DispatchQueue.main.async {
                GXServiceManager.shared.networkStatus = status
                NotificationCenter.default.post(name: GX_NotifName_NetworkStatus, object: nil)
            }
            switch status {
            case .notReachable:
                XCGLogger.info("GXServiceManager.startListening status: notReachable")
            case .unknown:
                XCGLogger.info("GXServiceManager.startListening status: unknown")
            case .reachable(.ethernetOrWiFi):
                XCGLogger.info("GXServiceManager.startListening status: ethernetOrWiFi")
            case .reachable(.cellular):
                XCGLogger.info("GXServiceManager.startListening status: cellular")
            }
        }
    }
    class func stopListening() {
        GXServiceManager.shared.networkManager?.stopListening()
    }
}
