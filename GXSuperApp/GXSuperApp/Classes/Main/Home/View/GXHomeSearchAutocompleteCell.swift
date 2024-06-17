//
//  GXHomeSearchAutocompleteCell.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/18.
//

import UIKit
import Reusable
import GooglePlaces

class GXHomeSearchAutocompleteCell: UITableViewCell, NibReusable {
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.nameLabel.text = nil
        self.nameLabel.attributedText = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.nameLabel.text = nil
        self.nameLabel.attributedText = nil
    }
    
    func bindCell(model: GMSAutocompleteSuggestion) {
        guard let attFullText = model.placeSuggestion?.attributedFullText else { return }
        
        let attributed = NSMutableAttributedString(attributedString: attFullText)
        let allRange = NSRange(location: 0, length: attFullText.length)
        attributed.setAttributes([.font : UIFont.gx_font(size: 16)], range: allRange)
        attFullText.enumerateAttribute(.gmsAutocompleteMatchAttribute, in: allRange, options: .init(rawValue: 0)) 
        { value, range, stop in
            let color = (value != nil) ? UIColor.gx_green : UIColor.gx_textBlack
            let font = (value != nil) ? UIFont.gx_boldFont(size: 16) : UIFont.gx_font(size: 16)
            attributed.setAttributes([.font: font, .foregroundColor: color], range: range)
        }
        self.nameLabel.attributedText = attributed
    }
}
