//
//  GXMusicWindow.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/6.
//

import UIKit
import XCGLogger
import RxSwift
import MediaPlayer
import Kingfisher

class GXMusicWindow: UIWindow {
    private let disposeBag = DisposeBag()
    private var currentPoint: CGPoint = .zero

    private lazy var leftView: UIView = {
        return UIView(frame: CGRect(x: 0, y: 0, width: 84, height: 40)).then {
            $0.backgroundColor = .white
            $0.layer.masksToBounds = true
        }
    }()

    private lazy var rightView: UIView = {
        return UIView(frame: CGRect(x: 20, y: 0, width: 84, height: 40)).then {
            $0.backgroundColor = .white
            $0.layer.masksToBounds = true
        }
    }()

    private lazy var iconImageView: UIImageView = {
        return UIImageView(frame: CGRect(x: 20, y: 0, width: 32, height: 32)).then {
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 16.0
        }
    }()

    private lazy var playButton: UIButton = {
        return UIButton(type: .custom).then {
            $0.frame = CGRect(x: 0, y: 0, width: 24, height: 40)
            $0.setImage(UIImage(named: "pr_dtwin_play"), for: .normal)
            $0.setImage(UIImage(named: "pr_dtwin_pause"), for: .selected)
            $0.addTarget(self, action: #selector(self.playButtonClicked(_:)), for: .touchUpInside)
        }
    }()

    private lazy var closeButton: UIButton = {
        return UIButton(type: .custom).then {
            $0.frame = CGRect(x: 0, y: 0, width: 24, height: 40)
            $0.setImage(UIImage(named: "pr_dtwin_close"), for: .normal)
            $0.addTarget(self, action: #selector(self.closeButtonClicked(_:)), for: .touchUpInside)
        }
    }()

    private lazy var animation: CABasicAnimation = {
        return CABasicAnimation(keyPath: "transform.rotation").then {
            $0.fromValue = 0
            $0.toValue = (Double.pi * 2)
            $0.duration = 5.0
            $0.isRemovedOnCompletion = false
            $0.repeatCount = Float(Int.max)
            $0.autoreverses = false
        }
    }()

    static let shared: GXMusicWindow = {
        let instance = GXMusicWindow(frame: CGRect(x: 100, y: 100, width: 104, height: 40))
        instance.windowLevel = .alert
        instance.backgroundColor = .clear
        instance.setLayerShadow(color: .gx_lightGray, offset: .zero, radius: 4.0)
        
        return instance
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubview(self.leftView)
        self.addSubview(self.rightView)
        self.leftView.layer.cornerRadius = 20.0

        self.addSubview(self.iconImageView)
        self.addSubview(self.playButton)
        self.addSubview(self.closeButton)
        self.iconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4.0)
            make.left.equalToSuperview().offset(4.0)
            make.bottom.equalToSuperview().offset(-4.0)
            make.width.equalTo(32.0)
        }
        self.playButton.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(self.iconImageView.snp.right).offset(8.0)
            make.width.equalTo(24.0)
        }
        self.closeButton.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(self.playButton.snp.right).offset(4.0)
            make.width.equalTo(24.0)
        }

        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.panGestureAction(pan:)))
        self.addGestureRecognizer(pan)

        self.configRemoteCommandCenter()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GXMusicWindow {
    func showWindow(isLoad: Bool) {
        var edge: UIEdgeInsets = .zero
        if let rootVc = GXAppDelegate?.window?.rootViewController {
            edge = rootVc.view.safeAreaInsets
        } else {
            edge = GXAppDelegate?.window?.safeAreaInsets ?? .zero
        }
        var frame = self.frame
        frame.origin.x = SCREEN_WIDTH - frame.width
        frame.origin.y = SCREEN_HEIGHT - edge.bottom - 60.0 - frame.height

        if isLoad {
            self.frame = frame
            self.makeKeyAndVisible()
            self.isHidden = true
        }
        else if self.isHidden {
            self.frame = frame
            self.leftView.layer.cornerRadius = 20.0
            self.rightView.layer.cornerRadius = 0.0
            self.isHidden = false
        }
    }
    func hideWindow() {
        guard !self.isHidden else { return }
        self.isHidden = true
        GXMusicPlayerManager.shared.closeMusicPlayer()
        DispatchQueue.main.async {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        }
    }

    func updateMusicPlay(model: GXPtHomeGetMusicStationsItem, isPlay: Bool) {
        self.iconImageView.kf.setImage(with: URL(string: model.coverPic))
        self.playButton.isSelected = isPlay

        if isPlay {
            self.showWindow(isLoad: false)
            self.iconImageView.layer.add(self.animation, forKey: "isPlay")
        }
        else {
            self.iconImageView.layer.removeAllAnimations()
        }
        self.showPlayingInfo(item: model)
    }
}

private extension GXMusicWindow {

    @objc func panGestureAction(pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .began:
            self.currentPoint = self.center
            self.panBeginAnimation()
        case .changed:
            let movePoint = pan.translation(in: pan.view)
            self.currentPoint = CGPoint(x: self.currentPoint.x + movePoint.x , y: self.currentPoint.y + movePoint.y)
            self.updateSafeCurrentPoint()
            self.center = self.currentPoint
            pan.setTranslation(.zero, in: pan.view)
        case .ended:
            self.panEndAnimation()
        case .cancelled: break
        case .failed: break
        default: break
        }
    }

    func updateSafeCurrentPoint() {
        var edge: UIEdgeInsets = .zero
        if let rootVc = GXAppDelegate?.window?.rootViewController {
            edge = rootVc.view.safeAreaInsets
        } else {
            edge = GXAppDelegate?.window?.safeAreaInsets ?? .zero
        }

        var pointX = self.currentPoint.x, pointY = self.currentPoint.y
        let maxLeft = self.width/2 + edge.left
        if (self.currentPoint.x < maxLeft) {
            pointX = maxLeft
        }
        let maxRight = SCREEN_WIDTH - self.width/2 - edge.right
        if (self.currentPoint.x > maxRight) {
            pointX = maxRight
        }
        let maxTop = self.height/2 + edge.top;
        if (self.currentPoint.y < maxTop) {
            pointY = maxTop
        }
        let maxBottom = SCREEN_HEIGHT - self.width/2 - edge.bottom
        if (self.currentPoint.y > maxBottom) {
            pointY = maxBottom
        }
        self.currentPoint = CGPointMake(pointX, pointY)
    }

    func panBeginAnimation() {
        UIView.animate(withDuration: 0.25) {
            self.leftView.layer.cornerRadius = 20.0
            self.rightView.layer.cornerRadius = 20.0
        }
    }

    func panEndAnimation() {
        let isLeft: Bool = (self.center.x < SCREEN_WIDTH * 0.5)
        var frame = self.frame
        frame.origin.x = isLeft ? 0 : (SCREEN_WIDTH - frame.width)
        UIView.animate(withDuration: 0.25) {
            self.frame = frame
            if isLeft {
                self.leftView.layer.cornerRadius = 0.0
                self.rightView.layer.cornerRadius = 20.0
            }
            else {
                self.leftView.layer.cornerRadius = 20.0
                self.rightView.layer.cornerRadius = 0.0
            }
        }
    }

    @objc func playButtonClicked(_ sender: UIButton) {
        let isPlay = !sender.isSelected
        GXMusicPlayerManager.shared.playMusicPlayer(isPlay: isPlay)
    }

    @objc func closeButtonClicked(_ sender: UIButton) {
        self.hideWindow()
    }

}

extension GXMusicWindow {

    //MARK: - 媒体信息配置
    ///配置多媒体控制面板的显示页面
    func showPlayingInfo(item: GXPtHomeGetMusicStationsItem) {
        if let url = URL(string: item.coverPic) {
            KingfisherManager.shared.retrieveImage(with: url) { result in
                switch result {
                case .success(let image):
                    self.showPlayingInfo(item: item, image: image.image)
                case .failure(_):
                    self.showPlayingInfo(item: item, image: nil)
                }
            }
        }
        else {
            self.showPlayingInfo(item: item, image: nil)
        }
    }

    func showPlayingInfo(item: GXPtHomeGetMusicStationsItem, image: UIImage?) {
        //设置后台播放时显示的东西，例如歌曲名字，图片等
        var info : [String : Any] = [:]
        ///标题
        info[MPMediaItemPropertyTitle] = item.title
        if let letImage = image {
            ///封面
            let artWork = MPMediaItemArtwork(boundsSize: letImage.size, requestHandler: { (size) -> UIImage in return letImage })
            info[MPMediaItemPropertyArtwork] = artWork
        }
        if let player = GXMusicPlayerManager.shared.currentPlayer {
            // 当前播放进度 （会被自动计算出来，自动计算与MPNowPlayingInfoPropertyPlaybackRate设置的速率正相关)
            info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: player.player.playingItemCurrentTime())

            //调整外部显示的播放速率正常为1、一般都是根据内部播放器的播放速率作同步，一般不必修改
            //info[MPNowPlayingInfoPropertyPlaybackRate] = NSNumber(value: 1)

            // 播放总时间 由当前播放的资源提供
            let duration = player.player.playingItemDurationTime()
            info[MPMediaItemPropertyPlaybackDuration] = NSNumber(value: duration)
        }
        DispatchQueue.main.async {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = info
        }
    }

    func configRemoteCommandCenter() -> Void {
        let remoteCommandCenter = MPRemoteCommandCenter.shared()

        //播放事件
        let playCommand = remoteCommandCenter.playCommand
        playCommand.isEnabled = true
        playCommand.addTarget(self, action: #selector(playItem(_:)))

        //暂停事件
        let pauseCommand = remoteCommandCenter.pauseCommand
        pauseCommand.isEnabled = true
        pauseCommand.addTarget(self, action: #selector(pauseItem(_:)))

        //上一曲
        let previousTrackCommand = remoteCommandCenter.previousTrackCommand
        previousTrackCommand.isEnabled = true
        previousTrackCommand.addTarget(self, action: #selector(previousItem(_:)))

        //下一曲
        let nextTrackCommand = remoteCommandCenter.nextTrackCommand
        nextTrackCommand.isEnabled = true
        nextTrackCommand.addTarget(self, action: #selector(nextItem(_:)))
    }

    @objc func playItem(_ command : MPRemoteCommand) -> MPRemoteCommandHandlerStatus {
        DispatchQueue.main.async {
            GXMusicPlayerManager.shared.playMusicPlayer(isPlay: true)
        }
        return .success
    }
    @objc func pauseItem(_ command : MPRemoteCommand) -> MPRemoteCommandHandlerStatus {
        DispatchQueue.main.async {
            GXMusicPlayerManager.shared.playMusicPlayer(isPlay: false)
        }
        return .success
    }
    @objc func previousItem(_ command : MPRemoteCommand) -> MPRemoteCommandHandlerStatus {
        DispatchQueue.main.async {
            GXMusicPlayerManager.shared.palyMusicChange(isNext: false)
        }
        return .success
    }
    @objc func nextItem(_ command : MPRemoteCommand) -> MPRemoteCommandHandlerStatus {
        DispatchQueue.main.async {
            GXMusicPlayerManager.shared.palyMusicChange(isNext: true)
        }
        return .success
    }

}
