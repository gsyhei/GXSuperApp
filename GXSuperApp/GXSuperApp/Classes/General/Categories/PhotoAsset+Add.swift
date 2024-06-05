//
//  PhotoAsset+Add.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/23.
//

import HXPhotoPicker

extension PhotoAsset {
    
    class func gx_imageUrlsString(assets: [PhotoAsset]) -> String? {
        var picsArr: [String] = []
        assets.forEach { asset in
            if let urlStr = asset.networkImageAsset?.originalURL.absoluteString {
                picsArr.append(urlStr)
            }
        }
        return (picsArr.count > 0) ? picsArr.joined(separator: ",") : nil
    }

    class func gx_photoAssets(pics: String?) -> [PhotoAsset] {
        var photoAsset: [PhotoAsset] = []
        if let urls = pics?.components(separatedBy: ",") {
            for urlStr in urls {
                guard let url = URL(string: urlStr) else { continue }
                let networkImageAsset = NetworkImageAsset(thumbnailURL: url, originalURL: url)
                let asset = PhotoAsset(networkImageAsset: networkImageAsset)
                photoAsset.append(asset)
            }
        }
        return photoAsset
    }

}

