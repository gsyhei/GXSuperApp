//
//  GXMusicPlayerManager.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/6.
//

import UIKit
import RxSwift
import MediaPlayer
import Kingfisher

class GXMusicPlayerManager: NSObject {
    private let disposeBag = DisposeBag()
    private var musicPlayerList: [GXMusicPlayer] = []
    var currentPlayer: GXMusicPlayer? = nil

    static let shared: GXMusicPlayerManager = {
        let instance = GXMusicPlayerManager()
        return instance
    }()

    override init() {
        super.init()

        NotificationCenter.default.rx
            .notification(GX_NotifName_MusicPlay)
            .take(until: self.rx.deallocated)
            .subscribe(onNext: {[weak self] notifi in
                guard let playModel = notifi.userInfo?[GX_MusicPlay_ModelKey] as? GXPtHomeGetMusicStationsItem else { return }
                guard let isPlay = notifi.userInfo?[GX_MusicPlay_IsPlayKey] as? Bool else { return }
                guard let list = self?.musicPlayerList else { return }

                for item in list {
                    if item.model.id == playModel.id {
                        self?.currentPlayer = item
                        self?.currentPlayer?.updateForLiveStreaming(isCache: true)
                    } else {
                        item.audioPlay(isPlay: false)
                        item.updateForLiveStreaming(isCache: !isPlay)
                    }
                }
                self?.currentPlayer?.audioPlay(isPlay: isPlay)
                GXMusicWindow.shared.updateMusicPlay(model: playModel, isPlay: isPlay)

            }).disposed(by: disposeBag)
    }

    func updateMusicPlayerList(list: [GXPtHomeGetMusicStationsItem]) {
        var newPlayerList: [GXMusicPlayer] = []
        for item in list {
            if let subPlayer = self.musicPlayerList.first(where: { $0.model.id == item.id}) {
                newPlayerList.append(subPlayer)
            }
            else {
                let player = GXMusicPlayer(model: item)
                player.updateMusic()
                newPlayerList.append(player)
            }
        }
        if let currPlayer = self.currentPlayer {
            if newPlayerList.first(where: { $0 == currPlayer}) == nil {
                GXMusicWindow.shared.hideWindow()
            }
        }
        for player in self.musicPlayerList {
            if newPlayerList.first(where: { $0.model.id == player.model.id}) == nil {
                player.deprecatePlayer()
            }
        }
        self.musicPlayerList = newPlayerList
    }

    func resumeCurrentPlayer() {
        if let player = self.currentPlayer {
            player.player.play()
        }
    }

    func playMusicPlayer(isPlay: Bool) {
        var userInfo: [String : Any] = [:]
        userInfo[GX_MusicPlay_IsPlayKey] = isPlay
        if let item = self.currentPlayer?.model {
            userInfo[GX_MusicPlay_ModelKey] = item
        }
        NotificationCenter.default.post(
            name: GX_NotifName_MusicPlay,
            object: nil,
            userInfo: userInfo
        )
    }

    func closeMusicPlayer() {
        var userInfo: [String : Any] = [:]
        userInfo[GX_MusicPlay_IsPlayKey] = false
        if let item = self.currentPlayer?.model {
            userInfo[GX_MusicPlay_ModelKey] = item
        }
        NotificationCenter.default.post(
            name: GX_NotifName_MusicPlay,
            object: nil,
            userInfo: userInfo
        )
    }

    func palyMusicChange(isNext: Bool) {
        guard let player = self.currentPlayer else { return }
        guard let index = self.musicPlayerList.firstIndex(of: player) else { return }

        let count = self.musicPlayerList.count
        var selectIndex = 0
        selectIndex = isNext ? (index + count + 1)%count : (index + count - 1)%count
        let selectPlayer = self.musicPlayerList[selectIndex]

        var userInfo: [String : Any] = [:]
        userInfo[GX_MusicPlay_IsPlayKey] = true
        userInfo[GX_MusicPlay_ModelKey] = selectPlayer.model

        NotificationCenter.default.post(
            name: GX_NotifName_MusicPlay,
            object: nil,
            userInfo: userInfo
        )
    }

}
