//
//  XaddressView.swift
//  XaddressApp
//
//  Created by Paul Von Schrottky on 10/8/16.
//  Copyright © 2016 Paul Von Schrottky. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class XaddressView: UIView {
    
    @IBOutlet weak var activityView: NVActivityIndicatorView!
    @IBOutlet weak var iconView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var rightView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.clearColor()
        
        
        iconView.backgroundColor = Constant.Color.Principal
        iconView.layer.masksToBounds = false
        iconView.layer.cornerRadius = 45
        iconView.layer.borderWidth = 3
        iconView.layer.borderColor = Constant.Color.Border.CGColor
        iconView.layer.shadowRadius = 2
        iconView.layer.shadowOpacity = 0.5
        iconView.layer.shadowOffset = CGSizeZero
        
        
        rightView.layer.cornerRadius = 10
        rightView.backgroundColor = Constant.Color.Principal
        rightView.layer.shadowRadius = 2
        rightView.layer.shadowOpacity = 0.5
        rightView.layer.shadowOffset = CGSizeZero
        rightView.layer.borderWidth = 3
        rightView.layer.borderColor = Constant.Color.Border.CGColor
    }
    
    func setupWithXaddress(xaddress: Xaddress?) {
        
        stopLoading()
        
        guard let xaddress = xaddress else { return }
        guard let n = xaddress.n else { return }
        guard let p2 = xaddress.p2 else { return }
        guard let p1 = xaddress.p1 else { return }
        guard let state = xaddress.state?.shortName else { return }
        guard let country = xaddress.country?.shortName else { return }
        
        let attributedString = NSMutableAttributedString()
        attributedString.appendAttributedString(NSAttributedString(string: String(n), attributes: [
            NSForegroundColorAttributeName: Constant.Color.Red,
        ]))
        
        attributedString.appendAttributedString(NSAttributedString(string: " " + p2, attributes: [
            NSForegroundColorAttributeName: Constant.Color.TextDark,
        ]))
        
        attributedString.appendAttributedString(NSAttributedString(string: " " + p1, attributes: [
            NSForegroundColorAttributeName: Constant.Color.TextDark,
        ]))
        titleLabel.attributedText = attributedString
        
        
        subtitleLabel.text = state + " - " + country
    }

    func startLoading() {
        iconImageView.alpha = 0
        activityView.alpha = 1
        activityView.startAnimation()
    }
    
    func stopLoading() {
        iconImageView.alpha = 1
        activityView.alpha = 0
        activityView.stopAnimation()
    }
    
}