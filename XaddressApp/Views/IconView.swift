//
//  IconView.swift
//  XaddressApp
//
//  Created by Paul Von Schrottky on 11/6/16.
//  Copyright © 2016 LoanApp. All rights reserved.
//

import UIKit

class IconView: UIView {
    
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
        
        backgroundColor = Constant.Color.Border
        borderView.backgroundColor = Constant.Color.Foreground
        imageView.backgroundColor = Constant.Color.Foreground
        
        layer.shadowRadius = 2
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSizeZero
        layer.shadowColor = Constant.Color.Shadow.CGColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.size.width / 2
        borderView.layer.cornerRadius = borderView.bounds.size.width / 2
        imageView.layer.cornerRadius = imageView.bounds.size.width / 2
    }

}
