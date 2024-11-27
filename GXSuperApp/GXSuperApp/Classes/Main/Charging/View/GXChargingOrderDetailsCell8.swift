//
//  GXChargingOrderDetailsCell8.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/8.
//

import UIKit
import Reusable
import RxSwift

class GXChargingOrderDetailsCell8: UITableViewCell, NibReusable {
    let disposeBag = DisposeBag()
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var freeMinLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var chargingTitleLabel: UILabel!
    @IBOutlet weak var chargingDetailLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.isSkeletonable = true
        
        NotificationCenter.default.rx
            .notification(GX_NotifName_OccupyCountdown)
            .take(until: self.rx.deallocated)
            .subscribe(onNext: {[weak self] notifi in
                self?.occupyCountdown(timeObject: notifi.object)
            }).disposed(by: disposeBag)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func occupyCountdown(timeObject: Any?) {
        guard let time = timeObject as? Int else { return }
        self.timeLabel.text = GXUtil.gx_minuteSecond(time: abs(time))
        if time > 0 {
            // 占位费倒计时
            self.containerView.backgroundColor = .gx_yellow
            self.chargingTitleLabel.text = "Idle fee will start in"
            self.chargingDetailLabel.text = "Please unplug and move the car to avoid idle fee"
        }
        else {
            // 占位费读秒
            self.containerView.backgroundColor = .gx_drakRed
            self.chargingTitleLabel.text = "Idle fee has started"
            self.chargingDetailLabel.text = "Please remove the charging gun and move the vehicle promptly"
        }
    }
    
    func bindCell(model: GXChargingOrderDetailData?) {
        guard let model = model else { return }
        self.freeMinLabel.text = "$\(model.occupyPrice) / min"
    }
}
