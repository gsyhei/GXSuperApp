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
                let data = try? JSONSerialization.jsonObject(with: response.data, options: .mutableContainers)
                guard let dataJSON = data as? Dictionary<String, Any>, let model:T = T.deserialize(from: dataJSON) else {
                    let dataStr = String(data: response.data, encoding: .utf8)
                    let error = GXError(code: response.statusCode, info: dataStr ?? response.description)
                    self.gx_logger(target: target, error: error, json: nil)
                    DispatchQueue.main.async { failure(error) }
                    return
                }
                switch response.statusCode {
                case 200: // 成功
                    if model.code == 200 {
                        self.gx_logger(target: target, error: nil, json: dataJSON)
                        DispatchQueue.main.async { success(model) }
                    } else {
                        let error = GXError(code: model.code, info: model.msg)
                        self.gx_logger(target: target, error: error, json: dataJSON)
                        DispatchQueue.main.async { failure(error) }
                    }
                case 401: // 无token或过期
                    let errorInfo = (dataJSON["error"] as? String) ?? response.description
                    let error = GXError(code: response.statusCode, info: errorInfo)
                    self.gx_logger(target: target, error: error, json: dataJSON)
                    DispatchQueue.main.async { failure(error) }
                default:
                    let errorInfo = (dataJSON["error"] as? String) ?? response.description
                    let error = GXError(code: response.statusCode, info: errorInfo)
                    self.gx_logger(target: target, error: error, json: dataJSON)
                    DispatchQueue.main.async { failure(error) }
                }
            case let .failure(error):
                self.gx_logger(target: target, error: error, json: nil)
                DispatchQueue.main.async { failure(error) }
            }
        }
    }
    
}

fileprivate extension GXMoyaProvider {
    func gx_logger(target: GXApi, error: CustomNSError?, json: Dictionary<String, Any>?) {
        DispatchQueue.global().sync {
            if let error = error {
                print("\n--------------------BEGIN-------------------->>")
                print("Request URL: \(target.baseURL)\(target.path)")
                print("Request Method: \(target.method.rawValue)")
                print("Request Params:\n\(target.parameters.jsonStringEncoded(options: .prettyPrinted) ?? "")")
                print("Request headers:\n\(target.headers?.jsonStringEncoded(options: .prettyPrinted) ?? "")")
                if let json = json, let dataString = json.jsonStringEncoded(options: .prettyPrinted) {
                    print("Response Data:\n\(dataString)")
                } else {
                    print("Request Error: \(error.localizedDescription)")
                }
                print("<<-------------------END-----------------------\n")
            }
            else {
                print("\n--------------------BEGIN-------------------->>")
                print("Request URL: \(target.baseURL)\(target.path)")
                print("Request Method: \(target.method.rawValue)")
                print("Request Params:\n\(target.parameters.jsonStringEncoded(options: .prettyPrinted) ?? "")")
                print("Request headers:\n\(target.headers?.jsonStringEncoded(options: .prettyPrinted) ?? "")")
                if let json = json, let dataString = json.jsonStringEncoded(options: .prettyPrinted) {
                    print("Response Data:\n\(dataString)")
                }
                print("<<-------------------END-----------------------\n")
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
