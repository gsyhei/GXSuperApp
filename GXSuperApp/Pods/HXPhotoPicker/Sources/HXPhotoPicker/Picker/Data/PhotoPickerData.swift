//
//  PhotoPickerData.swift
//  HXPhotoPicker
//
//  Created by Silence on 2023/9/28.
//  Copyright © 2023 Silence. All rights reserved.
//

import UIKit
import Photos

public protocol PhotoPickerDataDelegate: AnyObject {
    
    /// 将要选择Asset
    func pickerData(
        _ pickerData: PhotoPickerData,
        shouldSelectedAsset photoAsset: PhotoAsset,
        at index: Int
    ) -> Bool

    /// 即将选择 Asset 时调用
    func pickerData(
        _ pickerData: PhotoPickerData,
        willSelectAsset photoAsset: PhotoAsset,
        at index: Int
    )

    /// 选择了 Asset 之后调用
    func pickerData(
        _ pickerData: PhotoPickerData,
        didSelectAsset photoAsset: PhotoAsset,
        at index: Int
    )

    /// 即将取消选择 Asset
    func pickerData(
        _ pickerData: PhotoPickerData,
        willUnselectAsset photoAsset: PhotoAsset,
        at index: Int
    )

    /// 取消选择 Asset
    func pickerData(
        _ pickerData: PhotoPickerData,
        didUnselectAsset photoAsset: PhotoAsset,
        at index: Int
    )
    
    func pickerData(
        _ pickerData: PhotoPickerData,
        removeSelectedAssetWhenRemovingAssets photoAssets: [PhotoAsset]
    )
}

open class PhotoPickerData {
    
    public weak var delegate: PhotoPickerDataDelegate?
    
    /// 当前被选择的资源对应的 PhotoAsset 对象数组
    public var selectedAssets: [PhotoAsset] = []
    
    public func setSelectedAssets(_ assets: [PhotoAsset]) {
        if config.selectMode == .single {
            return
        }
        selectedAssets = assets
        for photoAsset in assets {
            if photoAsset.mediaType == .photo {
                selectedPhotoAssets.append(photoAsset)
                #if HXPICKER_ENABLE_EDITOR
                if let editedResult = photoAsset.editedResult {
                    photoAsset.initialEditedResult = editedResult
                }
                addedEditedPhotoAsset(photoAsset)
                #endif
            }else if photoAsset.mediaType == .video {
                if config.isSingleVideo {
                    if let index = selectedAssets.firstIndex(of: photoAsset) {
                        selectedAssets.remove(at: index)
                    }
                }else {
                    selectedVideoAssets.append(photoAsset)
                }
                #if HXPICKER_ENABLE_EDITOR
                if let editedResult = photoAsset.editedResult {
                    photoAsset.initialEditedResult = editedResult
                }
                addedEditedPhotoAsset(photoAsset)
                #endif
            }
        }
    }
    
    public var selectedPhotoAssets: [PhotoAsset] = []
    public var selectedVideoAssets: [PhotoAsset] = []
    
    /// 本地资源数组
    /// 创建本地资源的PhotoAsset然后赋值即可添加到照片列表，如需选中也要添加到selectedAssetArray中
    public var localAssets: [PhotoAsset] = []
    
    /// 相机拍摄存在本地的资源数组（通过相机拍摄的但是没有保存到系统相册）
    /// 可以通过 pickerControllerDidDismiss 得到上一次相机拍摄的资源，然后赋值即可显示上一次相机拍摄的资源
    public var localCameraAssets: [PhotoAsset] = []
    
    public let config: PickerConfiguration
    
    let requestAssetBytesQueue: OperationQueue
    let previewRequestAssetBytesQueue: OperationQueue
    
    public required init(config: PickerConfiguration) {
        self.config = config
        
        requestAssetBytesQueue = OperationQueue()
        requestAssetBytesQueue.maxConcurrentOperationCount = 1
        previewRequestAssetBytesQueue = OperationQueue()
        previewRequestAssetBytesQueue.maxConcurrentOperationCount = 1
    }
    
    #if HXPICKER_ENABLE_EDITOR
    var editedPhotoAssets: [PhotoAsset] = []
    #endif
    
    /// 添加根据本地资源生成的PhotoAsset对象
    /// - Parameter photoAsset: 对应的PhotoAsset对象
    public func addedLocalCamera(_ photoAsset: PhotoAsset) {
        photoAsset.localIndex = localCameraAssets.count
        localCameraAssets.append(photoAsset)
    }
    
    /// 添加PhotoAsset对象到已选数组
    /// - Parameter photoAsset: 对应的PhotoAsset对象
    /// - Returns: 添加结果
    @discardableResult
    public func append(
        _ photoAsset: PhotoAsset,
        isFilterEditor: Bool = false
    ) -> Bool {
        if config.isSingleVideo && photoAsset.mediaType == .video {
            return false
        }
        if config.selectMode == .single {
            // 单选模式不可添加
            return false
        }
        if selectedAssets.contains(photoAsset) {
            photoAsset.isSelected = true
            return false
        }
        let canSelect = canSelect(
            photoAsset,
            isShowHUD: true,
            isFilterEditor: isFilterEditor
        )
        if canSelect {
            delegate?.pickerData(self, willSelectAsset: photoAsset, at: selectedAssets.count)
            photoAsset.isSelected = true
            photoAsset.selectIndex = selectedAssets.count
            if photoAsset.mediaType == .photo {
                selectedPhotoAssets.append(photoAsset)
            }else if photoAsset.mediaType == .video {
                selectedVideoAssets.append(photoAsset)
            }
            selectedAssets.append(photoAsset)
            delegate?.pickerData(self, didSelectAsset: photoAsset, at: selectedAssets.count - 1)
        }
        return canSelect
    }
    
    public func canSelectPhoto(_ photoAsset: PhotoAsset) -> (Bool, String?) {
        var canSelect = true
        var text: String?
        if photoAsset.mediaType == .photo {
            if config.maximumSelectedPhotoFileSize > 0 {
                if photoAsset.fileSize > config.maximumSelectedPhotoFileSize {
                    text = "照片大小超过最大限制".localized + config.maximumSelectedPhotoFileSize.bytesString
                    canSelect = false
                }
            }
            if !config.allowSelectedTogether {
                if selectedVideoAssets.count > 0 {
                    text = "照片和视频不能同时选择".localized
                    canSelect = false
                }
            }
            if config.maximumSelectedPhotoCount > 0, selectedPhotoAssets.count >= config.maximumSelectedPhotoCount {
                text = String.init(format: "最多只能选择%d张照片".localized, arguments: [config.maximumSelectedPhotoCount])
                canSelect = false
            }else {
                if selectedAssets.count >= config.maximumSelectedCount && config.maximumSelectedCount > 0 {
                    text = String.init(format: "已达到最大选择数".localized, arguments: [config.maximumSelectedPhotoCount])
                    canSelect = false
                }
            }
        }
        return (canSelect, text)
    }
    
    public func canSelectVideo(
        _ photoAsset: PhotoAsset,
        isFilterEditor: Bool
    ) -> (Bool, String?) {
        var canSelect = true
        var text: String?
        if photoAsset.mediaType == .video {
            if config.maximumSelectedVideoFileSize > 0 {
                if photoAsset.fileSize > config.maximumSelectedVideoFileSize {
                    text = "视频大小超过最大限制".localized + config.maximumSelectedVideoFileSize.bytesString
                    canSelect = false
                }
            }
            if config.maximumSelectedVideoDuration > 0 {
                if round(photoAsset.videoDuration) > Double(config.maximumSelectedVideoDuration) {
                    #if HXPICKER_ENABLE_EDITOR
                    if !config.editorOptions.contains(.video) || isFilterEditor {
                        text = String(
                            format: "视频最大时长为%d秒，无法选择".localized,
                            arguments: [config.maximumSelectedVideoDuration]
                        )
                        canSelect = false
                    }else {
                        if config.maximumVideoEditDuration > 0 &&
                            round(photoAsset.videoDuration) > Double(config.maximumVideoEditDuration) {
                            text = String(
                                format: "视频可编辑最大时长为%d秒，无法编辑".localized,
                                arguments: [config.maximumVideoEditDuration]
                            )
                            canSelect = false
                        }
                    }
                    #else
                    text = String(
                        format: "视频最大时长为%d秒，无法选择".localized,
                        arguments: [config.maximumSelectedVideoDuration]
                    )
                    canSelect = false
                    #endif
                }
            }
            if config.minimumSelectedVideoDuration > 0 {
                if round(photoAsset.videoDuration) < Double(config.minimumSelectedVideoDuration) {
                    text = String(
                        format: "视频最小时长为%d秒，无法选择".localized,
                        arguments: [config.minimumSelectedVideoDuration]
                    )
                    canSelect = false
                }
            }
            if !config.allowSelectedTogether {
                if selectedPhotoAssets.count > 0 {
                    text = "视频和照片不能同时选择".localized
                    canSelect = false
                }
            }
            if config.maximumSelectedVideoCount > 0, selectedVideoAssets.count >= config.maximumSelectedVideoCount {
                text = String.init(format: "最多只能选择%d个视频".localized, arguments: [config.maximumSelectedVideoCount])
                canSelect = false
            }else {
                if selectedAssets.count >= config.maximumSelectedCount && config.maximumSelectedCount > 0 {
                    text = String.init(format: "已达到最大选择数".localized, arguments: [config.maximumSelectedPhotoCount])
                    canSelect = false
                }
            }
        }
        return (canSelect, text)
    }
    
    /// 是否能够选择Asset
    /// - Parameters:
    ///   - photoAsset: 对应的PhotoAsset
    ///   - isShowHUD: 是否显示HUD
    /// - Returns: 结果
    public func canSelect(
        _ photoAsset: PhotoAsset,
        isShowHUD: Bool,
        isFilterEditor: Bool = false
    ) -> Bool {
        var canSelect = true
        let text: String?
        if photoAsset.mediaType == .photo {
            let result = canSelectPhoto(photoAsset)
            canSelect = result.0
            text = result.1
        }else {
            let result = canSelectVideo(photoAsset, isFilterEditor: isFilterEditor)
            canSelect = result.0
            text = result.1
        }
        if let shouldSelect = delegate?.pickerData(self, shouldSelectedAsset: photoAsset, at: selectedAssets.count) {
            if canSelect {
                canSelect = shouldSelect
            }
        }
        if let text = text, !canSelect, isShowHUD {
            DispatchQueue.main.async {
                ProgressHUD.showWarning(
                    addedTo: UIViewController.topViewController?.navigationController?.view,
                    text: text,
                    animated: true,
                    delayHide: 1.5
                )
            }
        }
        return canSelect
    }
    
    /// 移除已选的PhotoAsset对象
    /// - Parameter photoAsset: 对应PhotoAsset对象
    /// - Returns: 移除结果
    @discardableResult
    public func remove(_ photoAsset: PhotoAsset) -> Bool {
        guard let index = selectedAssets.firstIndex(of: photoAsset) else {
            return false
        }
        delegate?.pickerData(self, willUnselectAsset: photoAsset, at: index)
        photoAsset.isSelected = false
        if photoAsset.mediaType == .photo {
            selectedPhotoAssets.remove(
                at: selectedPhotoAssets.firstIndex(of: photoAsset)!
            )
        }else if photoAsset.mediaType == .video {
            selectedVideoAssets.remove(
                at: selectedVideoAssets.firstIndex(of: photoAsset)!
            )
        }
        selectedAssets.remove(at: index)
        for (index, asset) in selectedAssets.enumerated() {
            asset.selectIndex = index
        }
        delegate?.pickerData(self, didUnselectAsset: photoAsset, at: index)
        return true
    }
    
    public func move(fromIndex: Int, toIndex: Int) {
        let fromAsset = selectedAssets[fromIndex]
        selectedAssets.remove(at: fromIndex)
        selectedAssets.insert(fromAsset, at: toIndex)
        for (index, asset) in selectedAssets.enumerated() {
            asset.selectIndex = index
        }
    }
    
    
    /// 视频时长是否超过最大限制
    /// - Parameter photoAsset: 对应的PhotoAsset对象
    public func videoDurationExceedsTheLimit(_ photoAsset: PhotoAsset) -> Bool {
        photoAsset.mediaType == .video &&
           config.maximumSelectedVideoDuration > 0 &&
           round(photoAsset.videoDuration) > Double(config.maximumSelectedVideoDuration)
    }
    
    /// 选择数是否达到最大
    public var isFull: Bool {
        selectedAssets.count >= config.maximumSelectedCount && config.maximumSelectedCount > 0
    }
    
    /// 获取已选资源的总大小
    /// - Parameters:
    ///   - isPreview: 是否是预览界面获取
    ///   - completion: 大小
    public func requestSelectedAssetFileSize(
        isPreview: Bool,
        completion: @escaping (Int, String) -> Void
    ) {
        cancelRequestAssetFileSize(isPreview: isPreview)
        let operation = BlockOperation()
        let assets = selectedAssets
        operation.addExecutionBlock { [unowned operation] in
            var totalFileSize = 0
            for photoAsset in assets {
                if operation.isCancelled { return }
                if let fileSize = photoAsset.getPFileSize() {
                    totalFileSize += fileSize
                    continue
                }
                totalFileSize += photoAsset.fileSize
            }
            if operation.isCancelled { return }
            DispatchQueue.main.async {
                completion(
                    totalFileSize,
                    totalFileSize.bytesString
                )
            }
        }
        if isPreview {
            previewRequestAssetBytesQueue.addOperation(operation)
        }else {
            requestAssetBytesQueue.addOperation(operation)
        }
    }
    
    /// 取消获取资源文件大小
    /// - Parameter isPreview: 是否预览界面
    public func cancelRequestAssetFileSize(isPreview: Bool) {
        if isPreview {
            previewRequestAssetBytesQueue.cancelAllOperations()
        }else {
            requestAssetBytesQueue.cancelAllOperations()
        }
    }
    
    public func cancelRequestAssetFileSize() {
        previewRequestAssetBytesQueue.cancelAllOperations()
        requestAssetBytesQueue.cancelAllOperations()
    }
    
    #if HXPICKER_ENABLE_EDITOR
    func addedEditedPhotoAsset(_ photoAsset: PhotoAsset) {
        if editedPhotoAssets.contains(photoAsset) {
            return
        }
        editedPhotoAssets.append(photoAsset)
    }
    func removeAllEditedPhotoAsset() {
        if editedPhotoAssets.isEmpty {
            return
        }
        for photoAsset in editedPhotoAssets {
            photoAsset.initialEditedResult = nil
        }
        editedPhotoAssets.removeAll()
    }
    
    func resetEditedAssets() {
        editedPhotoAssets.forEach {
            $0.editedResult = $0.initialEditedResult
        }
        editedPhotoAssets.removeAll()
    }
    #endif
    
    deinit {
        cancelRequestAssetFileSize()
    }
}

public extension PhotoPickerData {
    
    struct SelectResult {
        public let photoAssets: [PhotoAsset]
        public let phAssets: [PHAsset]
    }
    
    var selectResult: SelectResult {
        var phAssets = [PHAsset]()
        var photoAssets: [PhotoAsset] = []
        var localIndex = -1
        for (index, photoAsset) in selectedAssets.enumerated() {
            photoAsset.selectIndex = index
            photoAsset.isSelected = true
            if let phAsset = photoAsset.phAsset {
                phAssets.append(phAsset)
                photoAssets.append(photoAsset)
            }else {
                let inLocal = localAssets
                    .contains {
                    if $0.isEqual(photoAsset) {
                        localAssets[localAssets.firstIndex(of: $0)!] = photoAsset
                        return true
                    }
                    return false
                }
                let inLocalCamera = localCameraAssets
                    .contains(where: {
                    if $0.isEqual(photoAsset) {
                        localCameraAssets[
                            localCameraAssets.firstIndex(of: $0)!
                        ] = photoAsset
                        return true
                    }
                    return false
                })
                if !inLocal && !inLocalCamera {
                    if photoAsset.localIndex > localIndex {
                        localIndex = photoAsset.localIndex
                        localAssets.insert(photoAsset, at: 0)
                    }else {
                        if localIndex == -1 {
                            localIndex = photoAsset.localIndex
                            localAssets.insert(photoAsset, at: 0)
                        }else {
                            localAssets.insert(photoAsset, at: 1)
                        }
                    }
                }
            }
        }
        return .init(photoAssets: photoAssets, phAssets: phAssets)
    }
}
