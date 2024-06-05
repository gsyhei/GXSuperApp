//
//  GXParticipantHomeDtConCell.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/6.
//

import UIKit
import Reusable
import RxSwift

class GXParticipantHomeDtConCell: UICollectionViewCell, NibReusable {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: GXMarqueeTextView!
    @IBOutlet weak var playButton: UIButton!

    private var disposeBag = DisposeBag()
    var model: GXPtHomeGetMusicStationsItem?
    var playAction: GXActionBlockItem2<GXPtHomeGetMusicStationsItem?, Bool>?

    override func prepareForReuse() {
        self.iconImageView.image = nil
        self.titleLabel.text = nil
        self.detailLabel.text = nil
        self.playButton.isSelected = false
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .white
        self.contentView.layer.masksToBounds = true
        self.contentView.layer.cornerRadius = 12.0

        self.detailLabel.textFont = .gx_font(size: 15)
        self.detailLabel.textColor = .gx_drakGray

        NotificationCenter.default.rx
            .notification(GX_NotifName_MusicPlay)
            .take(until: self.rx.deallocated)
            .subscribe(onNext: {[weak self] notifi in
                guard let playModel = notifi.userInfo?[GX_MusicPlay_ModelKey] as? GXPtHomeGetMusicStationsItem else { return }
                guard let isPlay = notifi.userInfo?[GX_MusicPlay_IsPlayKey] as? Bool else { return }
                if self?.model?.id == playModel.id {
                    self?.playButton.isSelected = isPlay
                } else {
                    self?.playButton.isSelected = false
                }
            }).disposed(by: disposeBag)
    }
    
    func bindCell(model: GXPtHomeGetMusicStationsItem) {
        self.model = model
        self.iconImageView.kf.setImage(with: URL(string: model.coverPic))
        self.titleLabel.text = model.title
        self.detailLabel.text = model.subTitle       
//        let music = GXMusicPlayerManager.shared.music
//        if music.currentItem?.id == model.id && music.player.isAutoPlay {
        let music = GXMusicPlayerManager.shared.currentPlayer
        if music?.model.id == model.id && (music?.player.isAutoPlay ?? false) {
            self.playButton.isSelected = true
        }
    }
    
    @IBAction func plaButtonClicked(_ sender: UIButton) {
        if GXServiceManager.shared.networkStatus == .notReachable {
            GXToast.showError(text: "当前网络不可用")
            return
        }
        let isPlay = !sender.isSelected
        if let item = self.model {
            if isPlay {
                GXApiUtil.requestCreateEvent(targetType: 1, targetId: item.id)
            }
            let userInfo: [String : Any] = [GX_MusicPlay_ModelKey: item, GX_MusicPlay_IsPlayKey: isPlay]
            NotificationCenter.default.post(
                name: GX_NotifName_MusicPlay,
                object: nil,
                userInfo: userInfo
            )
        }
    }
}
