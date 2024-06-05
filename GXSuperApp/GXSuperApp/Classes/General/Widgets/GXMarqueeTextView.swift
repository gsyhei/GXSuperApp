//
//  GXMarqueeTextView.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/19.
//

import UIKit

class GXMarqueeTextView: UIView {
    public var text: String? {
        willSet {
            nameLabel?.text = newValue
            nameLabelNext?.text = newValue
            setNeedsLayout()
        }
    }

    public var textColor: UIColor = .gx_black {
        willSet {
            nameLabel?.textColor = newValue
            nameLabelNext?.textColor = newValue
        }
    }

    public var textFont: UIFont = .gx_font(size: 15) {
        willSet {
            nameLabel?.font = newValue
            nameLabelNext?.font = newValue
        }
    }

    private weak var displayLink: CADisplayLink?
    private let runSpacing = 30.0

    private var duration: TimeInterval = 0
    /// 设置滚动复位
    public var isZero : Bool? {
        didSet{
            if isZero == true {
                duration = 0
                scrollView?.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            }
        }
    }

    /// 是否向左滚动标记
    public var isLeft: Bool = true

    /// 是否需要滚动标记
    private var isCanRun: Bool = true

    private weak var nameLabel: UILabel?
    private weak var nameLabelNext: UILabel?
    private weak var scrollView: UIScrollView?

    convenience init(_frame: CGRect) {
        self.init(frame: _frame)
        backgroundColor = UIColor.clear
        initSubviews()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clear
        isUserInteractionEnabled = false
        initSubviews()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        displayLink?.isPaused = true
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isCanRun {
            displayLink?.isPaused = false
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isCanRun {
            displayLink?.isPaused = false
        }
    }

    deinit {
        self.displayLink?.invalidate()
        self.displayLink = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let textSize = self.textSize(text: nameLabel?.text ?? "", font: self.textFont, height: 18)
        scrollView?.frame = bounds

        duration = 0
        isCanRun = textSize.width > width
        displayLink?.isPaused = width >= textSize.width

        nameLabelNext?.isHidden = !isCanRun
        if isCanRun {
            let textRunWidth = textSize.width + runSpacing
            nameLabel?.frame = CGRect(x: 0, y: 0, width: textRunWidth, height: textSize.height)
            nameLabel?.centerY = scrollView?.centerY ?? .zero

            nameLabelNext?.frame = CGRect(x: textRunWidth, y: 0, width: textRunWidth, height: textSize.height)
            nameLabelNext?.centerY = scrollView?.centerY ?? .zero

            scrollView?.contentSize = CGSize(width: textRunWidth * 2, height: bounds.height)
        }
        else {
            nameLabel?.frame = CGRect(x: 0, y: 0, width: textSize.width, height: textSize.height)
            nameLabel?.centerY = scrollView?.centerY ?? .zero

            scrollView?.contentSize = CGSize(width: textSize.width, height: bounds.height)
        }
    }

    private func textSize(text: String,  font: UIFont, height: CGFloat) -> CGSize {
        return text.boundingRect(with:CGSize(width:CGFloat(MAXFLOAT), height: height), options: .usesLineFragmentOrigin, attributes: [.font:font], context:nil).size
    }

    private func initSubviews() {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.isUserInteractionEnabled = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        addSubview(scrollView)
        self.scrollView = scrollView

        let nameLabel = UILabel()
        nameLabel.backgroundColor = .clear
        nameLabel.textAlignment = .center
        nameLabel.font = textFont
        nameLabel.textColor = textColor
        scrollView.addSubview(nameLabel)
        self.nameLabel = nameLabel

        let nameLabelNext = UILabel()
        nameLabelNext.backgroundColor = .clear
        nameLabelNext.textAlignment = .center
        nameLabelNext.font = textFont
        nameLabelNext.textColor = textColor
        scrollView.addSubview(nameLabelNext)
        self.nameLabelNext = nameLabelNext

        let displayLink = CADisplayLink(target: self, selector: #selector(timerEvent))
        displayLink.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
        displayLink.isPaused = true
        self.displayLink = displayLink
    }

    private var isRunning = false
    @objc private func timerEvent() {
        if duration == 0 {
            if !isRunning {
                isRunning = true
                DispatchQueue.main.asyncAfter(deadline: .now()) { [self] in
                    runScroll()
                    isRunning = false
                }
            }
        } else {
            runScroll()
        }
    }

    /// 定时器事件
    private func runScroll() {
        let maxWith = (nameLabel?.width ?? 0)
        let scale: TimeInterval = 1.0
        if self.isLeft {
            if duration <= TimeInterval(maxWith) {
                duration += scale
            } else {
                duration = 0
            }
        }
        else {
            if !isLeft && duration > 0 {
                duration -= scale
            } else {
                duration = maxWith
            }
        }
        scrollView?.setContentOffset(CGPoint(x: duration, y: 0), animated: false)
    }
}
