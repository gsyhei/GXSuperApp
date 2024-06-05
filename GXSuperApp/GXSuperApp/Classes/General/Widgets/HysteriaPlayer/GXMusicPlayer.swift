//
//  GXMusicPlayer.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/6.
//

import UIKit
import XCGLogger

class GXMusicPlayer: NSObject {
    private var timeObserver: Any?

    var model: GXPtHomeGetMusicStationsItem
    lazy var player: HysteriaPlayer = {
        return HysteriaPlayer().then {
            $0.delegate = self
        }
    }()

    init(model: GXPtHomeGetMusicStationsItem) {
        self.model = model
    }

    func updateMusic() {
        if self.model.sourceUrl.count > 0 {
            self.player.preActionUrlString(self.model.sourceUrl)
        } else {
            self.player.preActionUrlString(self.model.audioFile)
        }
        self.audioPlay(isPlay: false)
    }

    func audioPlay(isPlay: Bool) {
        if isPlay {
            self.player.isAutoPlay = true
            if !self.player.isPlaying() {
                self.player.play()
            }
        }
        else {
            self.player.isAutoPlay = false
            if self.player.isPlaying() {
                self.player.pause()
            }
        }
    }

    func deprecatePlayer() {
        if let observer = self.timeObserver {
            self.player.removeTimeObserver(observer)
        }
        self.player.deprecatePlayer()
        self.timeObserver = nil
    }

    func updateForLiveStreaming(isCache: Bool) {
        self.player.audioPlayer?.currentItem?.canUseNetworkResourcesForLiveStreamingWhilePaused = isCache
    }

}

extension GXMusicPlayer: HysteriaPlayerDelegate {

    func hysteriaPlayer(_ hysteriaPlayer: HysteriaPlayer, showAlertWithError error: Error) {
        GXUtil.showAlert(title: error.localizedDescription)
    }

    func hysteriaPlayer(_ hysteriaPlayer: HysteriaPlayer, didStallWith item: AVPlayerItem?) {
        if self.player.isAutoPlay {
            GXToast.showError(text: "当前网络卡顿，播放暂停！")
            GXMusicPlayerManager.shared.playMusicPlayer(isPlay: false)
        }
        XCGLogger.info("Player did stall item: \(item.debugDescription)")
    }

    func hysteriaPlayer(_ hysteriaPlayer: HysteriaPlayer, didReadyToPlayWithIdentifier identifier: HysteriaPlayerReadyToPlay) {
        if identifier == .player {
            timeObserver = hysteriaPlayer.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1000, timescale: 1000), queue: nil) {[weak self] time in
                let totalSecond = CMTimeGetSeconds(time)
                XCGLogger.info("current play seconds = \(Int(totalSecond))")
                if let asset = self?.player.audioPlayer?.currentItem?.asset as? AVURLAsset {
                    XCGLogger.verbose("current play URL = \(asset.url.absoluteString)")
                }
            }
        }
    }

    func hysteriaPlayer(_ hysteriaPlayer: HysteriaPlayer, didPreloadCurrentItemWith time: CMTime) {
        if self.player.isAutoPlay {
            let seconds = CMTimeGetSeconds(time)
            XCGLogger.info("current preload seconds = \(Int(seconds))")
            if let asset = hysteriaPlayer.audioPlayer?.currentItem?.asset as? AVURLAsset {
                XCGLogger.verbose("current preload URL = \(asset.url.absoluteString)")
            }
        } 
//        else {
//            let seconds = CMTimeGetSeconds(time)
//            XCGLogger.info("preload seconds = \(Int(seconds))")
//            if let asset = hysteriaPlayer.audioPlayer?.currentItem?.asset as? AVURLAsset {
//                XCGLogger.verbose("preload URL = \(asset.url.absoluteString)")
//            }
//        }
    }

    func hysteriaPlayerDidReachEnd(_ hysteriaPlayer: HysteriaPlayer) {
        XCGLogger.info("Player did reach end.")
        GXMusicPlayerManager.shared.playMusicPlayer(isPlay: false)
    }

    func hysteriaPlayer(_ hysteriaPlayer: HysteriaPlayer, rateDidChange rate: Float) {
        XCGLogger.info("Player changed rate: \(rate)")
    }

    func hysteriaPlayer(_ hysteriaPlayer: HysteriaPlayer, didFailWithIdentifier identifier: HysteriaPlayerFailed, error: Error) {
        XCGLogger.info("HysteriaPlayer didFailWithIdentifier:error: \(error)")
        GXMusicPlayerManager.shared.playMusicPlayer(isPlay: false)
        if self.player.isAutoPlay {
            GXToast.showError(text: error.localizedDescription)
        }
    }

    func hysteriaPlayer(_ hysteriaPlayer: HysteriaPlayer, didFailedWith item: AVPlayerItem?, toPlayToEndTimeWithError error: Error) {
        XCGLogger.info("player did failed:error: \(error)")
        GXMusicPlayerManager.shared.playMusicPlayer(isPlay: false)
        if self.player.isAutoPlay {
            GXToast.showError(text: error.localizedDescription)
        }
    }
}
