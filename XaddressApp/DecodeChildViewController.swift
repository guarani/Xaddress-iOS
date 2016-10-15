//
//  DecodeChildViewController.swift
//  XaddressApp
//
//  Created by Paul Von Schrottky on 10/15/16.
//  Copyright © 2016 LoanApp. All rights reserved.
//

import UIKit

class DecodeChildViewController: UIViewController {
    
    var addressTextField: UITextField!
    var countryTextField: UITextField!
    var scrollView: UIScrollView!
    var wrapperViews = [UIView]()

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[scrollView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["scrollView": scrollView]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[scrollView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["scrollView": scrollView]))
        view.addSubview(scrollView)
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        
        let addressView = UIView()
        addressView.translatesAutoresizingMaskIntoConstraints = false
        addressTextField = UITextField()
        addressTextField.returnKeyType = .Next
        addressTextField.autocorrectionType = .No
        addressTextField.autocapitalizationType = .None
        addressTextField.placeholder = "Enter an Xaddress to find its location"
        addressTextField.borderStyle = .RoundedRect
        addressView.addSubview(addressTextField)
        addressTextField.translatesAutoresizingMaskIntoConstraints = false
        addressView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(8)-[addressTextField]-(8)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["addressTextField": addressTextField]))
        addressView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(8)-[addressTextField]-(8)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["addressTextField": addressTextField]))
        wrapperViews.append(addressView)
        
        let countryView = UIView()
        countryView.translatesAutoresizingMaskIntoConstraints = false
        countryTextField = UITextField()
        countryTextField.returnKeyType = .Next
        countryTextField.autocorrectionType = .No
        countryTextField.autocapitalizationType = .None
        countryTextField.placeholder = "Select a country"
        countryTextField.borderStyle = .RoundedRect
        countryView.addSubview(countryTextField)
        countryTextField.translatesAutoresizingMaskIntoConstraints = false
        countryView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(8)-[countryTextField]-(8)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["countryTextField": countryTextField]))
        countryView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(8)-[countryTextField]-(8)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["countryTextField": countryTextField]))
        wrapperViews.append(countryView)
        
        var previousWrapperView: UIView!
        
        for (idx, wrapperView) in wrapperViews.enumerate() {
            scrollView.addSubview(wrapperView)
            scrollView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[wrapperView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["wrapperView": wrapperView]))
            view.addConstraint(NSLayoutConstraint(item: wrapperView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: wrapperView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: wrapperView, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1, constant: 0))
            
            if idx == 0 {
                scrollView.addConstraint(NSLayoutConstraint(item: wrapperView, attribute: .Left, relatedBy: .Equal, toItem: scrollView, attribute: .Left, multiplier: 1, constant: 0))
            } else {
                scrollView.addConstraint(NSLayoutConstraint(item: wrapperView, attribute: .Left, relatedBy: .Equal, toItem: previousWrapperView, attribute: .Right, multiplier: 1, constant: 0))
            }
            
            if idx == wrapperViews.count - 1 {
                scrollView.addConstraint(NSLayoutConstraint(item: wrapperView, attribute: .Right, relatedBy: .Equal, toItem: scrollView, attribute: .Right, multiplier: 1, constant: 0))
            }
            
            previousWrapperView = wrapperView
        }
        
    }

}

extension DecodeChildViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == textField {
            
        }
    }
}
