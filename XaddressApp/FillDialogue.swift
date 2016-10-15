////
////  FillDialogue.swift
////  XaddressApp
////
////  Created by Paul Von Schrottky on 10/8/16.
////  Copyright © 2016 Paul Von Schrottky. All rights reserved.
////
//
//import UIKit
//
//class FillDialogue: NSObject {
//    static var dialogue: FillDialogue!
//    var window: UIWindow!
//    
//    var bottomLayoutConstraint: NSLayoutConstraint!
//    var backgroundView: UIView!
//    var fillView: FillView!
//    var saveButtonCallback: ((liters: Amount, totalPrice: Amount) -> Void)?
//    
//    init(saveButtonCallback: ((liters: Amount, totalPrice: Amount) -> Void)) {
//        super.init()
//        FillDialogue.dialogue = self
//        
//        self.saveButtonCallback = saveButtonCallback
//        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(kayboardDidChangeFrame), name: UIKeyboardDidChangeFrameNotification, object: nil)
//        
//        
//        window = UIWindow(frame: UIScreen.mainScreen().bounds)
//        window.windowLevel = UIWindowLevelAlert
//        window.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
//        
//        backgroundView = UIView()
//        backgroundView.translatesAutoresizingMaskIntoConstraints = false
//        window.addSubview(backgroundView)
//        window.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[backgroundView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["backgroundView": backgroundView]))
//        window.addConstraint(NSLayoutConstraint(item: window, attribute: .Top, relatedBy: .Equal, toItem: backgroundView, attribute: .Top, multiplier: 1, constant: 0))
//        bottomLayoutConstraint = NSLayoutConstraint(item: window, attribute: .Bottom, relatedBy: .Equal, toItem: backgroundView, attribute: .Bottom, multiplier: 1, constant: 0)
//        window.addConstraint(bottomLayoutConstraint)
//        
//        
//        fillView = UINib(nibName: "FillView", bundle: nil).instantiateWithOwner(self, options: nil)[0] as! FillView
//        backgroundView.addSubview(fillView)
//        fillView.translatesAutoresizingMaskIntoConstraints = false
//        backgroundView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(40)-[fillView]-(40)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["fillView": fillView]))
//        fillView.saveCallback = { liters, totalPrice in
//            self.hide()
//            saveButtonCallback(liters: liters, totalPrice: totalPrice)
//        }
//        
//        backgroundView.addConstraint(NSLayoutConstraint(item: fillView, attribute: .CenterX, relatedBy: .Equal, toItem: backgroundView, attribute: .CenterX, multiplier: 1, constant: 0))
//        backgroundView.addConstraint(NSLayoutConstraint(item: fillView, attribute: .CenterY, relatedBy: .Equal, toItem: backgroundView, attribute: .CenterY, multiplier: 1, constant: 0))
//    }
//    
//    
//    func show() {
//        // Animate window from transparent to opaque.
//        window.alpha = 0
//        window.hidden = false   // Adds window to the screen.
//        
//        UIView.animateWithDuration(0.5, animations: {
//            self.window.alpha = 1
//        })
//        fillView.litersTextField.becomeFirstResponder()
//    }
//    
//    func hide() {
//        
//        // Animate window from opaque to transparent, removing it when done.
//        UIView.animateWithDuration(0.6, animations: {
//            self.window.alpha = 0
//        }, completion: { _ in
//            self.window.hidden = true
//        })
//    }
//
//    
//    // #MARK - UIKeyboard Notification
//    
//    func kayboardDidChangeFrame(notification: NSNotification) {
//        
//    }
//    
//    func keyboardWillShow(notification: NSNotification) {
//        
//        let beginFrame = notification.userInfo![UIKeyboardFrameBeginUserInfoKey]!.CGRectValue()
//        let endFrame = notification.userInfo![UIKeyboardFrameEndUserInfoKey]!.CGRectValue()
//        
//        print(beginFrame, endFrame)
//        guard CGRectEqualToRect(beginFrame, endFrame) == false else {
//            return
//        }
//        
//        if let keyboardHeight = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size.height,
//                     duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue {
//            
//            bottomLayoutConstraint.constant = keyboardHeight
//            self.window.alpha = 0
//            UIView.animateWithDuration(duration, animations: {
//                self.window.alpha = 1
//            })
//        }
//    }
//    
//    func keyboardWillHide(notification: NSNotification) {
//        
//    }
//}
