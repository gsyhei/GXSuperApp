//
//  PhotoAsset+Add.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/23.
//

import HXPhotoPicker

extension PhotoAsset {
    
    class func gx_imageUrlStrings(assets: [PhotoAsset]) -> [String] {
        var picsArr: [String] = []
        assets.forEach { asset in
            if let urlStr = asset.networkImageAsset?.originalURL?.absoluteString {
                picsArr.append(urlStr)
            }
        }
        return picsArr
    }

    class func gx_photoAssets(pics: [String]) -> [PhotoAsset] {
        var photoAsset: [PhotoAsset] = []
        for urlStr in pics {
            guard let url = URL(string: urlStr) else { continue }
            let networkImageAsset = NetworkImageAsset(thumbnailURL: url, originalURL: url)
            let asset = PhotoAsset(networkImageAsset: networkImageAsset)
            photoAsset.append(asset)
        }
        return photoAsset
    }

}

