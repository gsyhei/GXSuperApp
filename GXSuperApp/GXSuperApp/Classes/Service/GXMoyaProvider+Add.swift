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
    func login_requestUpload(asset: PhotoAsset) -> Promise<GXUploadFileModel?> {
        return Promise { seal in
            guard (asset.networkImageAsset == nil) else {
                seal.fulfill(nil); return
            }
            asset.getImage() { image in
                guard let image = image else {
                    let error = GXError(code: -1000, info: "image error!")
                    seal.reject(error); return
                }
                let widthScale = image.size.width / SCREEN_SIZE.width
                let heightScale = image.size.height / SCREEN_SIZE.height
                let scale = min(widthScale, heightScale)
                let changeSize = CGSize(width: image.size.width/scale, height: image.size.height/scale)
                guard let data = image.dataForCompression(to: changeSize, resizeByte: 1024 * 1024 * 2, isDichotomy: true) else {
                    let error = GXError(code: -1000, info: "image data error!")
                    seal.reject(error); return
                }
                let formData = MultipartFormData(provider: .data(data), name: "file", fileName: "image.jpg", mimeType: "image/jpg")
                let api = GXApi.uploadApi(Api_file_upload, [formData], [:])
                self.login_request(api, type: GXUploadFileModel.self, success: { model in
                    if let data = model.data {
                        let url = URL(string: data.path)
                        asset.networkImageAsset = NetworkImageAsset(thumbnailURL: nil, originalURL: url)
                    }
                    seal.fulfill(model)
                }) { error in
                    seal.reject(error)
                }
            }
        }
    }
    
    /// 上传图片组，单传并行
    func login_requestUploadFiles(assets: [PhotoAsset]) -> Promise<[GXUploadFileModel?]> {
        var uploadList: [Promise<GXUploadFileModel?>] = []
        for item in assets {
            let uploadItem = self.login_requestUpload(asset: item)
            uploadList.append(uploadItem)
        }
        return when(fulfilled: uploadList)
    }
    
}
