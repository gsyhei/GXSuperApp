//
//  GXMoyaProvider.swift
//  GXLearningManagement
//
//  Created by Gin on 2021/5/31.
//

import Moya
import XCGLogger
import HandyJSON

typealias GXSuccess<T:Any> = (T) -> Void
typealias GXFailure = (CustomNSError) -> Void

let GXNWProvider = GXMoyaProvider()
let GXCallbackQueue = DispatchQueue(label: "requestCallBack", attributes: DispatchQueue.Attributes.concurrent)
let GXNetWorkTimeOut: TimeInterval = 30.0

class GXMoyaProvider: MoyaProvider<GXApi> {
    
    init() {
        let requestClosure = { (endpoint: Endpoint, done: MoyaProvider.RequestResultClosure) in
            do {
                var request = try endpoint.urlRequest()
                request.timeoutInterval = GXNetWorkTimeOut
                done(.success(request))
            } catch let error {
                done(.failure(MoyaError.underlying(error, nil)))
            }
        }
        super.init(requestClosure: requestClosure)
    }
    
    @discardableResult
    func gx_request<T: GXBaseModel>(_ target: GXApi, type: T.Type, success:@escaping GXSuccess<T>, failure:@escaping GXFailure) -> Cancellable {
        return self.request(target, callbackQueue: GXCallbackQueue) { result in
            switch result {
            case let .success(response):
                GXServiceManager.updateSystemTime(response: response.response)
                if response.statusCode == 200 {
                    let data = try? JSONSerialization.jsonObject(with: response.data, options: .mutableContainers)
                    if let dataJSON = data as? Dictionary<String, Any>, let model:T = T.deserialize(from: dataJSON)
                    {
                        if model.code == 10000 {
                            self.gx_logger(target: target, error: nil, json: dataJSON)
                            DispatchQueue.main.async {
                                success(model)
                            }
                        }
                        else {
                            let error = GXError(code: model.code, info: model.message)
                            self.gx_logger(target: target, error: error, json: nil)
                            DispatchQueue.main.async {
                                failure(error)
                            }
                        }
                    }
                    else {
                        let dataStr = String(data: response.data, encoding: .utf8)
                        XCGLogger.debug("Request String: \(String(describing: dataStr))")
                        let error = MoyaError.jsonMapping(response)
                        self.gx_logger(target: target, error: error, json: nil)
                        DispatchQueue.main.async {
                            failure(error)
                        }
                    }
                }
                else if response.statusCode == 401 {
                    // 无token或过期
                    let error = GXError(code: response.statusCode, info: response.description)
                    self.gx_logger(target: target, error: error, json: nil)
                    DispatchQueue.main.async {
                        failure(error)
                        GXAppDelegate?.gotoLogin()
                    }
                }
                else {
                    let error = GXError(code: response.statusCode, info: response.description)
                    self.gx_logger(target: target, error: error, json: nil)
                    DispatchQueue.main.async {
                        failure(error)
                    }
                }
            case let .failure(error):
                self.gx_logger(target: target, error: error, json: nil)
                DispatchQueue.main.async {
                    failure(error)
                }
            }
        }
    }
    
}

fileprivate extension GXMoyaProvider {
    
    func gx_logger(target: GXApi, error: CustomNSError?, json: Dictionary<String, Any>?) {
        DispatchQueue.global().sync {
            if let err = error {
                XCGLogger.debug("")
                XCGLogger.debug("---------------BEGIN--------------->>")
                XCGLogger.debug("Request URL: \(target.baseURL)\(target.path)")
                XCGLogger.debug("Request Params: \(target.parameters.jsonStringEncoded() ?? "")")
                XCGLogger.debug("Request Method: \(target.method)")
                XCGLogger.debug("Request headers: \(target.headers ?? [:])")
                XCGLogger.debug("ErrorCode: \(err.errorCode), Description: \(err.localizedDescription)")
                // XCGLogger.debug("Error = \(err)")
                XCGLogger.debug("<<--------------END------------------")
                XCGLogger.debug("")
            }
            else {
                XCGLogger.debug("")
                XCGLogger.debug("---------------BEGIN--------------->>")
                XCGLogger.debug("Request URL: \(target.baseURL)\(target.path)")
                XCGLogger.debug("Request Params: \(target.parameters.jsonStringEncoded() ?? "")")
                XCGLogger.debug("Request Method: \(target.method)")
                XCGLogger.debug("Request headers: \(target.headers ?? [:])")
                if let dataJSON = json {
                    XCGLogger.debug("Response: \(dataJSON.unicodeDescription)")
//                    XCGLogger.debug("Response: \(String(describing: json))")
                }
                XCGLogger.debug("<<--------------END------------------")
                XCGLogger.debug("")
            }
        }
    }
}

class GXError: CustomNSError {
    var errorCode: Int = 0
    var errorInfo: String = ""
    
    init(code: Int, info: String) {
        self.errorCode = code
        self.errorInfo = info
    }
    public var errorUserInfo: [String: Any] {
        var userInfo: [String: Any] = [:]
        userInfo[NSLocalizedDescriptionKey] = errorInfo
        return userInfo
    }
}
