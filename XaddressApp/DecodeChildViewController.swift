//
//  DecodeChildViewController.swift
//  XaddressApp
//
//  Created by Paul Von Schrottky on 10/15/16.
//  Copyright © 2016 LoanApp. All rights reserved.
//

import UIKit
import CoreData
import UITextField_Shake
import NVActivityIndicatorView
import LTMorphingLabel

enum DecodingState {
    case Address
    case Country
    case State
    case Result
    case None
}

class NoCursorTextField: UITextField {
    override func caretRectForPosition(position: UITextPosition) -> CGRect {
        return CGRectZero
    }
}

class CoverView: UIView {
    var underlyingViews: [UIView]!
//    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
//        
//        let hitView = super.hitTest(point, withEvent: event)
//        
//        print("hit at point: ", point)
//        
////        for view in underlyingViews {
//////            let convertedPoint = view.convertRect(view.frame, toView: self)
//////            print("convertedPoint: ", convertedPoint)
////            print("view", view)
////            if CGRectCon(view, point) {
////                return view
////            }
////        }
//        
//        return hitView
//    }
}

class ScrollView: UIScrollView {
    
    // Disable user scrolling.
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

class DecodeChildViewController: UIViewController {
    
    var decodingState = DecodingState.None
    
    var addressTextField: UITextField!
    var countryTextField: NoCursorTextField!
    var stateTextField: NoCursorTextField!
    
    var countryPickerView: UIPickerView!
    var statePickerView: UIPickerView!
    
    var scrollView: ScrollView!
    var wrapperViews = [UIView]()
    
    var countries = [XACountry]()
    var states = [XAState]()
    
    var selectedCountry: XACountry!
    var selectedState: XAState?
    
//    var xAddressTextField: UITextField!
//    var xAddressView: AddressView!

    var topConstraint: NSLayoutConstraint!
    
    var mapViewController: ViewController!
    
    var moc: NSManagedObjectContext {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let countryFetchRequest = NSFetchRequest()
        countryFetchRequest.entity = NSEntityDescription.entityForName("XACountry", inManagedObjectContext: moc)
        countryFetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        countries = try! moc.executeFetchRequest(countryFetchRequest) as! [XACountry]
        selectedCountry = countries.first!
        
        // Scroll view
        scrollView = ScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[scrollView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["scrollView": scrollView]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[scrollView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["scrollView": scrollView]))
        view.addSubview(scrollView)
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
    
        // Address
        let addressView = UIView()
        addressView.translatesAutoresizingMaskIntoConstraints = false
        addressTextField = UITextField()
        addressTextField.clearButtonMode = .Always
        addressTextField.delegate = self
        addressTextField.returnKeyType = .Go
        addressTextField.autocorrectionType = .No
        addressTextField.autocapitalizationType = .None
        addressTextField.placeholder = "Enter an Xaddress to find its location"
        addressTextField.borderStyle = .RoundedRect
        addressView.addSubview(addressTextField)
        addressTextField.translatesAutoresizingMaskIntoConstraints = false
        addressView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(8)-[addressTextField]-(8)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["addressTextField": addressTextField]))
        addressView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(8)-[addressTextField]-(8)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["addressTextField": addressTextField]))
        wrapperViews.append(addressView)
        
        // Country
        
        let countryView = UIView()
        
        let countryBackButton = UIButton()
        countryBackButton.translatesAutoresizingMaskIntoConstraints = false
        countryBackButton.setImage(UIImage(named: "Left-100"), forState: .Normal)
        countryBackButton.setContentHuggingPriority(UILayoutPriorityRequired, forAxis: .Horizontal)
        countryView.addSubview(countryBackButton)
        countryBackButton.addTarget(self, action: #selector(countryBackButtonAction), forControlEvents: .TouchUpInside)
        
        let countryGoButton = UIButton()
        countryGoButton.layer.cornerRadius = 5
        countryGoButton.titleLabel?.font = UIFont.systemFontOfSize(14)
        countryGoButton.backgroundColor = view.tintColor
        countryGoButton.translatesAutoresizingMaskIntoConstraints = false
        countryView.addSubview(countryGoButton)
        countryGoButton.setTitle("Go", forState: .Normal)
        countryGoButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        countryGoButton.addTarget(self, action: #selector(countryGoButtonAction), forControlEvents: .TouchUpInside)
        
        countryView.translatesAutoresizingMaskIntoConstraints = false
        countryTextField = NoCursorTextField()
        countryTextField.returnKeyType = .Next
        countryTextField.autocorrectionType = .No
        countryTextField.autocapitalizationType = .None
        countryTextField.placeholder = "Select a country"
        countryView.addSubview(countryTextField)
        countryTextField.translatesAutoresizingMaskIntoConstraints = false
        let countryViews = [
            "countryBackButton": countryBackButton,
            "countryTextField": countryTextField,
            "countryGoButton": countryGoButton,
        ]
        countryView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[countryBackButton]-[countryTextField]-[countryGoButton(50)]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: countryViews))
        countryView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(8)-[countryBackButton]-(8)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: countryViews))
        countryView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(8)-[countryTextField]-(8)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: countryViews))
        countryView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(8)-[countryGoButton]-(8)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: countryViews))
        countryPickerView = UIPickerView()
        countryPickerView.dataSource = self
        countryPickerView.delegate = self
        countryTextField.inputView = countryPickerView

        wrapperViews.append(countryView)
        
        // State
        
        let stateView = UIView()
        
        let stateBackButton = UIButton()
        stateBackButton.translatesAutoresizingMaskIntoConstraints = false
        stateBackButton.setImage(UIImage(named: "Left-100"), forState: .Normal)
        stateBackButton.setContentHuggingPriority(UILayoutPriorityRequired, forAxis: .Horizontal)
        stateView.addSubview(stateBackButton)
        stateBackButton.addTarget(self, action: #selector(stateBackButtonAction), forControlEvents: .TouchUpInside)
        
        let stateGoButton = UIButton()
        stateGoButton.layer.cornerRadius = 5
        stateGoButton.titleLabel?.font = UIFont.systemFontOfSize(14)
        stateGoButton.backgroundColor = view.tintColor
        stateGoButton.translatesAutoresizingMaskIntoConstraints = false
        stateView.addSubview(stateGoButton)
        stateGoButton.setTitle("Go", forState: .Normal)
        stateGoButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        stateGoButton.addTarget(self, action: #selector(stateGoButtonAction), forControlEvents: .TouchUpInside)
        
        stateView.translatesAutoresizingMaskIntoConstraints = false
        stateTextField = NoCursorTextField()
        stateTextField.returnKeyType = .Go
        stateTextField.autocorrectionType = .No
        stateTextField.autocapitalizationType = .None
        stateTextField.placeholder = "Select a state"
        stateView.addSubview(stateTextField)
        stateTextField.translatesAutoresizingMaskIntoConstraints = false
        let stateViews = [
            "stateBackButton": stateBackButton,
            "stateTextField": stateTextField,
            "stateGoButton": stateGoButton,
        ]
        stateView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[stateBackButton]-[stateTextField]-[stateGoButton(50)]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: stateViews))
        stateView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(8)-[stateBackButton]-(8)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: stateViews))
        stateView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(8)-[stateTextField]-(8)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: stateViews))
        stateView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(8)-[stateGoButton]-(8)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: stateViews))
        statePickerView = UIPickerView()
        statePickerView.dataSource = self
        statePickerView.delegate = self
        stateTextField.inputView = statePickerView
        wrapperViews.append(stateView)
        
        // Result
        
//        // Address
//        let xAddressWrapperView = UIView()
//        let xAddressInputView = UIView()
//        xAddressView = NSBundle.mainBundle().loadNibNamed("AddressView", owner: nil, options: nil).last as! AddressView
//        xAddressWrapperView.translatesAutoresizingMaskIntoConstraints = false
//        xAddressInputView.translatesAutoresizingMaskIntoConstraints = false
//        xAddressView.translatesAutoresizingMaskIntoConstraints = false
//        xAddressInputView.backgroundColor = UIColor.yellowColor()
//        xAddressInputView.addSubview(xAddressView)
//        xAddressInputView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[xAddressView]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["xAddressView": xAddressView]))
//        xAddressInputView.addConstraint(NSLayoutConstraint(item: xAddressView, attribute: .CenterY, relatedBy: .Equal, toItem: xAddressInputView, attribute: .CenterY, multiplier: 1, constant: 0))
//        xAddressTextField = NoCursorTextField()
//        xAddressTextField.inputView = xAddressInputView
//        xAddressTextField.delegate = self
//        xAddressWrapperView.addSubview(xAddressTextField)
//        xAddressTextField.translatesAutoresizingMaskIntoConstraints = false
//        xAddressWrapperView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(8)-[xAddressTextField]-(8)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["xAddressTextField": xAddressTextField]))
//        xAddressWrapperView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(8)-[xAddressTextField]-(8)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["xAddressTextField": xAddressTextField]))
//        wrapperViews.append(xAddressWrapperView)

        
        // Layout
        
        var previousWrapperView: UIView!
        
        for (idx, wrapperView) in wrapperViews.enumerate() {
            scrollView.addSubview(wrapperView)
            scrollView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[wrapperView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["wrapperView": wrapperView]))
            topConstraint = NSLayoutConstraint(item: wrapperView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0)
            view.addConstraint(topConstraint)
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
    
    // #MARK: - Keyboard Accessory Button Actions
    
    func countryBackButtonAction(sender: UIButton) {
        goToState(.Address)
    }
    
    func countryGoButtonAction(sender: UIButton) {
        self.selectedCountry = countries[countryPickerView.selectedRowInComponent(0)]
        if self.selectedCountry.kind == "X" {
            goToState(.Result)
        } else {
            goToState(.State)
        }
    }
    
    func stateBackButtonAction(sender: UIButton) {
        goToState(.Country)
    }
    
    func stateGoButtonAction(sender: UIButton) {
        goToState(.Result)
    }
    
    // #MARK - Helpers
    
    func goToState(state: DecodingState) {
        let screenWidth = UIScreen.mainScreen().bounds.width
        
        switch state {
        case .Address:
            decodingState = .Address
            addressTextField.becomeFirstResponder()
            scrollView.setContentOffset(CGPointMake(screenWidth * 0, 0), animated: true)
        case .Country:
            decodingState = .Country
            countryTextField.becomeFirstResponder()
            scrollView.setContentOffset(CGPointMake(screenWidth * 1, 0), animated: true)
        case .State:
            decodingState = .State
            let stateFetchRequest = NSFetchRequest()
            stateFetchRequest.entity = NSEntityDescription.entityForName("XAState", inManagedObjectContext: moc)
            let selectedCountryCode = selectedCountry!.code!
            stateFetchRequest.predicate = NSPredicate(format: "countryCode==%@", selectedCountryCode)
            stateFetchRequest.sortDescriptors = [NSSortDescriptor(key: "name1", ascending: true)]
            states = try! moc.executeFetchRequest(stateFetchRequest) as! [XAState]
            
            stateTextField.becomeFirstResponder()
            scrollView.setContentOffset(CGPointMake(screenWidth * 2, 0), animated: true)
        case .Result:
            decodingState = .Result
            view.endEditing(true)
            
            let xaddressString = addressTextField.text!
            let xAddress = XAUtils.xaddressForText(xaddressString, country: selectedCountry, state: selectedState)
            print("xAddress: ", xAddress)
            mapViewController.showPlace(xAddress!)
            
        default:
            break
        }
    }
}

extension DecodeChildViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == addressTextField {
            if let text = textField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) where text.isEmpty == false {
                goToState(.Country)
                countryTextField.becomeFirstResponder()
            } else {
                addressTextField.shake()
            }
        }
        return false
    }
}

extension DecodeChildViewController: UIPickerViewDataSource {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == countryPickerView {
            return countries.count
        } else {
            return states.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == countryPickerView {
            return countries[row].name
        } else {
            return states[row].name1
        }
    }
}

extension DecodeChildViewController: UIPickerViewDelegate {
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == countryPickerView {
            selectedCountry = countries[row]
        } else {
            selectedState = states[row]
        }
    }
}

//extension String {
//    static func randomString(length: Int) -> String {
//        
//        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
//        let len = UInt32(letters.length)
//        
//        var randomString = ""
//        
//        for _ in 0 ..< length {
//            let rand = arc4random_uniform(len)
//            var nextChar = letters.characterAtIndex(Int(rand))
//            randomString += NSString(characters: &nextChar, length: 1) as String
//        }
//        
//        return randomString
//    }
//}
