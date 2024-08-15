//
//  GXFontSegmentSlider.swift
//  GXSuperApp
//
//  Created by Gin on 2024/8/14.
//

import UIKit
import SnapKitExtend

class GXFontSegmentSlider: UIView {
    private let titles = ["0.9", "1.0", "1.1", "1.2", "1.3"]
    private lazy var slider: UISlider = {
        return UISlider().then {
            $0.minimumValue = 0
            $0.maximumValue = Float(self.titles.count - 1)
            $0.isUserInteractionEnabled = false
            $0.minimumTrackTintColor = .clear
            $0.maximumTrackTintColor = .clear
        }
    }()
    private var buttons: [UIButton] = []
    
    var selectIndex: Int = 0 {
        didSet {
            if selectIndex != oldValue {
                slider.setValue(Float(selectIndex), animated: true)
                action?(self, selectIndex)
            }
        }
    }
    var action: ((GXFontSegmentSlider, Int) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    private func setupView() {
        let hLineView = UIView()
        hLineView.backgroundColor = UIColor.systemGray
        self.addSubview(hLineView)
        
        for title in self.titles {
            let button = UIButton(type: .custom)
            button.isUserInteractionEnabled = false
            self.addSubview(button)
            self.buttons.append(button)
            
            let label = UILabel()
            label.textColor = UIColor.black
            label.font = UIFont.systemFont(ofSize: 16)
            label.textAlignment = .center
            label.text = title
            button.addSubview(label)
            
            label.snp.makeConstraints { make in
                make.centerX.equalTo(button)
                make.top.equalTo(button)
            }
            
            let lineView = UIView()
            lineView.backgroundColor = UIColor.systemGray
            self.addSubview(lineView)
            
            lineView.snp.makeConstraints { make in
                make.centerX.equalTo(button.snp.centerX)
                make.centerY.equalTo(hLineView.snp.centerY)
                make.size.equalTo(CGSize(width: 1.0, height: 10.0))
            }
        }
        self.buttons.snp.makeConstraints { make in
            make.bottom.equalTo(self).offset(-10)
            make.height.equalTo(54.0)
        }
        self.buttons.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 0, leadSpacing: 0, tailSpacing: 0)
        self.addSubview(self.slider)
        
        let itemWidth = UIScreen.main.bounds.width / CGFloat(titles.count)
        let margin = (itemWidth - 31) / 2
        self.slider.snp.makeConstraints { make in
            make.bottom.equalTo(self).offset(-10)
            make.left.equalTo(self).offset(margin)
            make.right.equalTo(self).offset(-margin)
        }
        
        hLineView.snp.makeConstraints { make in
            make.centerY.equalTo(self.slider.snp.centerY)
            make.left.equalTo(self.buttons.first!.snp.centerX)
            make.right.equalTo(self.buttons.last!.snp.centerX)
            make.height.equalTo(1)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        let currentPoint = CGPoint(x: point.x, y: self.slider.frame.origin.y + 10)
        if let index = self.buttons.firstIndex(where: { $0.frame.contains(currentPoint) }) {
            self.selectIndex = index
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        let currentPoint = CGPoint(x: point.x, y: self.slider.frame.origin.y + 10)
        if let index = self.buttons.firstIndex(where: { $0.frame.contains(currentPoint) }) {
            self.selectIndex = index
        }
    }
    
}
