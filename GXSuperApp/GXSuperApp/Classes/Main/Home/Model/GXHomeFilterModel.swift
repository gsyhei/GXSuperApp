//
//  GXHomeFilterModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/25.
//

import UIKit
import HandyJSON
import CoreLocation

class GXHomeFilterModel: NSObject, GXCopyable, HandyJSON {
    /// 经度
    var lng: String = ""
    /// 纬度
    var lat: String = ""
    /// 查询半径，单位：千米；不传使用后台配置数据
    var distance: Int?
    /// 停车减免；true:是，false：所有
    var freeParking: Bool?
    /// 可用充电；true:是，false：所有
    var chargingAvailable: Bool?
    /// 场站服务id；多个用逗号分隔
    var aroundFacilities: String?
    /// 场站位置；LAND：地上，UNDERGROUND：地下
    var position: String?
    /// 收藏场站；true:是，false：所有
    var favorite: Bool?
    /// 排序方式；1：距离最近，2：低价优先
    var orderType: Int?
    /// 分页参数，起始页，从1开始
    var pageNum: Int = 1
    /// 分页参数，每页显示条数
    var pageSize: Int = 10000
    
    
    /// 设置经纬度
    func setSelectedCoordinate(_ coordinate: CLLocationCoordinate2D) {
        self.lng = String(coordinate.longitude)
        self.lat = String(coordinate.latitude)
    }
    /// 设置场站服务id；多个用逗号分隔
    func setSelectedAroundFacilities(list: [Int]?) {
        if let list = list, list.count > 0 {
            self.aroundFacilities = list.map { String($0) }.joined(separator: ",")
        }
        else {
            self.aroundFacilities = nil
        }
    }
    /// 设置场站位置；LAND：地上，UNDERGROUND：地下
    func setSelectedPosition(index: Int?) {
        if let index = index {
            self.position = index == 0 ? "LAND" : "UNDERGROUND"
        }
        else {
            self.position = nil
        }
    }
    /// 场站位置索引
    func getSelectedPositionIndex() -> Int? {
        if self.position == "LAND" {
            return 0
        }
        else if self.position == "UNDERGROUND" {
            return 1
        }
        else {
            return nil
        }
    }
    /// 获得场站服务id数组
    func getSelectedAroundFacilities() -> [Int] {
        let stringArr = self.aroundFacilities?.components(separatedBy: ",")
        return stringArr?.compactMap { Int($0) } ?? []
    }

    required override init() {}
}
