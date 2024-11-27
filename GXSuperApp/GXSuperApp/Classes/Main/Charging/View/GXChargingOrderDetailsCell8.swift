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
        self.timeLabel.text = GXUtil.gx_minuteSecond(time: time)
        // 判断倒计时还是超时读秒
        if time > 0 {
            
        }
        else {
            
        }
    }
    
    func bindCell(model: GXChargingOrderDetailData?) {
        guard let model = model else { return }
        self.freeMinLabel.text = "$\(model.occupyPrice) / min"
    }
}
