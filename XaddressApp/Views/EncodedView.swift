//
//  AddressView.swift
//  XaddressApp
//
//  Created by Paul Von Schrottky on 10/8/16.
//  Copyright © 2016 Paul Von Schrottky. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import LTMorphingLabel

class AddressView: UIView {
    
    @IBOutlet weak var activityView: NVActivityIndicatorView!
    @IBOutlet weak var iconView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var rightView: UIView!
    @IBOutlet weak var titleLabel: LTMorphingLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        iconView.backgroundColor = UIColor.whiteColor()
        titleLabel.backgroundColor = UIColor.whiteColor()
        
        [iconView, rightView].forEach {
            $0.addBorder()
            $0.backgroundColor = Constant.Color.Principal
        }
    }
}