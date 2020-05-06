//
//  UIViewController+TapGesture.swift
//  AnimatedField_Example
//
//  Created by Siva on 05/06/2020.
//  Copyright (c) 2020 Siva. All rights reserved.
//

import UIKit

extension UIViewController {
    
    @objc func hideKeyboardWhenTap() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
