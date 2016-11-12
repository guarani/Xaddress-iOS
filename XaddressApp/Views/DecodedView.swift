//
//  DecodedView.swift
//  XaddressApp
//
//  Created by Paul Von Schrottky on 11/5/16.
//  Copyright © 2016 LoanApp. All rights reserved.
//

import UIKit

class DecodedView: UIView {
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var middleLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        topLabel.font = UIFont.boldSystemFontOfSize(17)
        translatesAutoresizingMaskIntoConstraints = false
        
        clipsToBounds = false
        
        backgroundColor = Constant.Color.Border
        borderView.backgroundColor = Constant.Color.Foreground
        layer.shadowRadius = 2
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSizeZero
        layer.shadowColor = Constant.Color.Shadow.CGColor
        
        let iconView = UINib(nibName: "IconView", bundle: nil).instantiateWithOwner(nil, options: nil).first as! IconView
        addSubview(iconView)
        addConstraint(NSLayoutConstraint(item: iconView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: iconView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0))

        bottomLabel.hidden = true

    }
}
