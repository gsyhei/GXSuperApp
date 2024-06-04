//
//  GXConfigTableModel.swift
//  GXConfigTableViewVCSample
//
//  Created by Gin on 2023/10/31.
//

import UIKit
import RxCocoa

open class GXConfigTableRowDefaultModel: NSObject {
    /// cell reuseIdentifier
    public var reuseIdentifier: String { return "DefaultCell" }
    /// cell style, default is default.
    public var style: UITableViewCell.CellStyle = .value1
    /// cell backgroundColor, default is white.
    public var backgroundColor: UIColor = .white
    /// cell height, default is 50.0.
    public var rowHeight: CGFloat = 50.0
    /// cell content margin, default is 16.0.
    public var contentMargin: CGFloat = 16.0
    /// cell selectedColor, default is nil.
    public var selectedColor: UIColor? = nil
    /// cell separatorInset, default is zero.
    public var separatorInset: UIEdgeInsets = .zero
    /// cell title, default is nil.
    public var title = BehaviorRelay<String?>(value: nil)
    /// cell detail, default is nil.
    public var detail = BehaviorRelay<String?>(value: nil)
    /// cell image, default is nil.
    public var image = BehaviorRelay<UIImage?>(value: nil)
    /// cell title font, default is nil.
    public var titleFont: UIFont? = nil
    /// cell detail font, default is nil.
    public var detailFont: UIFont? = nil
    /// cell title color, default is nil.
    public var titleColor: UIColor? = nil
    /// cell detail color, default is nil.
    public var detailColor: UIColor? = nil
    /// cell title numberOfLines, default is 1.
    public var titleNumberOfLines: Int = 1
    /// cell detail numberOfLines, default is 1.
    public var detailNumberOfLines: Int = 1
    /// cell didSelectAtRow action.
    public var action: (() -> Void)?
}

public class GXConfigTableRowCustomModel: GXConfigTableRowDefaultModel {
    /// cell reuseIdentifier
    public override var reuseIdentifier: String { return "CustomCell" }
}

public class GXConfigTableRowButtonModel: GXConfigTableRowDefaultModel {
    /// cell reuseIdentifier
    public override var reuseIdentifier: String { return "ButtonCell" }
}

public class GXConfigTableRowAvatarModel: GXConfigTableRowDefaultModel {
    /// cell reuseIdentifier
    public override var reuseIdentifier: String { return "AvatarCell" }
    /// cell avatar, default is nil.
    public var avatarImage = BehaviorRelay<UIImage?>(value: nil)
    /// cell avatar size, default is nil.
    public var avatarSize: CGSize = .zero
    /// cell avatar layer.cornerRadius, default is 0.
    public var cornerRadius: CGFloat = 0
}

public class GXConfigTableRowInputModel: GXConfigTableRowDefaultModel {
    /// cell reuseIdentifier
    public override var reuseIdentifier: String { return "InputCell" }
    /// cell input, default is nil.
    public var input = BehaviorRelay<String?>(value: nil)
    /// cell input size, default is nil.
    public var inputSize: CGSize = .init(width: 100, height: 40)
    /// cell input placeholder size, default is nil.
    public var inputPlaceholder: String? = nil
    /// cell input keyboardType, default is nil.
    public var keyboardType: UIKeyboardType = .default
}

public class GXConfigTableRowSwitchModel: GXConfigTableRowDefaultModel {
    /// cell reuseIdentifier
    public override var reuseIdentifier: String { return "SwitchCell" }
    /// cell switch.isOn, default is false.
    public var isOn = BehaviorRelay(value: false)
    /// cell switch.onTintColor
    public var onTintColor: UIColor? = .systemBlue
    /// cell input size, default is nil.
    public var switchSize: CGSize = .init(width: 51, height: 31)
    /// cell didSelectAtRow switch action.
    public var switchAction: ((Bool) -> Void)?
}

public class GXConfigTableSectionViewModel: NSObject {
    /// header/foote reuseIdentifier
    public var reuseIdentifier: String { return "HeaderFooterView" }
    /// header/foote content margin, default is 16.0.
    public var contentMargin: CGFloat = 16.0
    /// header/foote title, default is nil.
    public var title: String? = nil
    /// header/foote detail, default is nil.
    public var detail: String? = nil
    /// header/foote title font, default is nil.
    public var titleFont: UIFont? = nil
    /// header/foote detail font, default is nil.
    public var detailFont: UIFont? = nil
    /// header/foote title color, default is nil.
    public var titleColor: UIColor? = nil
    /// header/foote detail color, default is nil.
    public var detailColor: UIColor? = nil
    /// header/foote title numberOfLines, default is 1.
    public var titleNumberOfLines: Int = 1
    /// header/foote height, default is leastNormalMagnitude.
    public var height: CGFloat = CGFloat.leastNormalMagnitude
}

public class GXConfigTableSectionModel: NSObject {
    /// header model
    public var header: GXConfigTableSectionViewModel?
    /// footer model
    public var footer: GXConfigTableSectionViewModel?
    /// section row cell model list.
    public var rowList: Array<GXConfigTableRowDefaultModel> = []
}

public class GXConfigTableModel: NSObject {
    /// table type, default is insetGrouped.
    public var style: UITableView.Style = .insetGrouped
    /// table backgroundColor, default is white.
    public var backgroundColor: UIColor = .white
    /// table section model  list.
    public var sectionList: Array<GXConfigTableSectionModel> = []
}


