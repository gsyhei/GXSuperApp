//
//  GXMoyaProvider+Add.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/29.
//

import Foundation
import PromiseKit
import Moya
import HXPhotoPicker

extension GXMoyaProvider {
    
    /// 获取用户信息
    func login_requestUserInfo() -> Promise<GXUserModel> {
        let api = GXApi.normalApi(Api_auth_user_profile, [:], .get)
        return Promise { seal in
            self.gx_request(api, type: GXUserModel.self, success: { model in
                GXUserManager.shared.user = model.data
                seal.fulfill(model)
            }, failure: { error in
                seal.reject(error)
            })
        }
    }
    
    func login_request<T: GXBaseModel>(_ target: GXApi, type: T.Type, success:@escaping GXSuccess<T>, failure:@escaping GXFailure) {
        if GXUserManager.shared.isLogin && GXUserManager.shared.user == nil && !GXUserManager.shared.isGetUser {
            GXUserManager.shared.isGetUser = true
            firstly {
                self.login_requestUserInfo()
            }.done { model in
                self.gx_request(target, type: type, success: success, failure: failure)
                GXUserManager.shared.isGetUser = false
            }.catch { error in
                failure(error as! CustomNSError)
                GXUserManager.shared.isGetUser = false
            }
        }
        else {
            self.gx_request(target, type: type, success: success, failure: failure)
        }
    }
    
    
    /// 上传图片
    func login_requestUpload(asset: PhotoAsset) -> Promise<GXBaseDataModel?> {
        return Promise { seal in
            guard (asset.networkImageAsset == nil) else {
                seal.fulfill(nil); return
            }
            asset.getImage() { image in
                guard let data = image?.dataForCompression(to: SCREEN_SIZE, resizeByte: 1024 * 1024 * 2, isDichotomy: true) else {
                    let error = GXError(code: -1000, info: "image error!")
                    seal.reject(error); return
                }
                let formData = MultipartFormData(provider: .data(data), name: "file", fileName: "image.jpg", mimeType: "image/jpg")
                let api = GXApi.uploadApi(Api_file_upload, [formData], [:])
                self.login_request(api, type: GXBaseDataModel.self, success: { model in
                    /// 资源设置
                    asset.networkImageAsset = NetworkImageAsset(thumbnailURL: nil, originalURL: nil)
                    seal.fulfill(model)
                }) { error in
                    seal.reject(error)
                }
            }
        }
    }
    
}
