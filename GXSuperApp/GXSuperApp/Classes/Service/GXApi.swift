//
//  GXApi.swift
//  GXLearningManagement
//
//  Created by Gin on 2021/5/31.
//

import Moya

enum GXApi {
    
    case normalApi(String, [String: Any], Moya.Method)
    
    case bodyApi(String, [String: Any])

    case uploadApi(String, [MultipartFormData], [String: Any])
    
}

extension GXApi: TargetType {
    
    var baseURL: URL {
        switch self {
        case .normalApi:
            return URL(string: Api_BaseUrl)!
        case .bodyApi:
            return URL(string: Api_BaseUrl)!
        case .uploadApi:
            return URL(string: Api_BaseUrl)!
        }
    }

    var path: String {
        switch self {
        case .normalApi(let api, _, _):
            return api
        case .bodyApi(let api, _):
            return api
        case .uploadApi(let api, _, _):
            return api
        }
    }

    var method: Moya.Method {
        switch self {
        case .normalApi(_, _, let method):
            return method
        case .bodyApi(_, _):
            return .post
        case .uploadApi(_, _, _):
            return .post
        }
    }

    var task: Task {
        switch self {
        case .normalApi(_, let params, let method):
            if method == .get {
                return .requestParameters(parameters: self.publicParameters(params: params), encoding: URLEncoding.default)
            }
            else {
                return .requestParameters(parameters: self.publicParameters(params: params), encoding: JSONEncoding.default)
            }
        case .bodyApi(_, let params):
            return .requestParameters(parameters: self.publicParameters(params: params), encoding: JSONEncoding.default)
        case .uploadApi(_, let data, let params):
            return .uploadCompositeMultipart(data, urlParameters: self.publicParameters(params: params))
        }
    }

    var headers: [String: String]? {
        if let token = GXUserManager.shared.token {
            return ["token": token]
        }
        return nil
    }
    
    var validationType: ValidationType {
        return .none
    }
    
    var parameters: Dictionary<String, Any> {
        switch self {
        case .normalApi(_, let params, _):
            return self.publicParameters(params: params)
        case .bodyApi(_, let params):
            return self.publicParameters(params: params)
        case .uploadApi(_, _, let params):
            return self.publicParameters(params: params)
        }
    }
    
    func publicParameters(params: [String: Any]) -> [String: Any] {
        var publicParams: [String: Any] = [:]
//        if let remark = GXUserManager.shared.clientRemark {
//            publicParams.updateValue(remark, forKey: "order_person")
//        }
        publicParams.merge(params) { (_, new) -> Any in new }
        
        return publicParams
    }
}
