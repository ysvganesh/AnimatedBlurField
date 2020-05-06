//
//  ViewController.swift
//  AnimatedBlurField
//
//  Created by Siva on 05/06/2020.
//  Copyright (c) 2020 Siva. All rights reserved.
//

import UIKit
import AnimatedBlurField

class ViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var emailAnimatedField: AnimatedBlurField!
    @IBOutlet weak var usernameAnimatedField: AnimatedBlurField!
    @IBOutlet weak var birthdateAnimatedField: AnimatedBlurField!
    @IBOutlet weak var passwordAnimatedField: AnimatedBlurField!
    @IBOutlet weak var password2AnimatedField: AnimatedBlurField!
    @IBOutlet weak var priceAnimatedField: AnimatedBlurField!
    @IBOutlet weak var urlAnimatedField: AnimatedBlurField!
    @IBOutlet weak var numberAnimatedField: AnimatedBlurField!
    @IBOutlet weak var multilineAnimatedField: AnimatedBlurField!
    @IBOutlet weak var defaultField: AnimatedBlurField!
    @IBOutlet weak var multilineHeightConstraint: NSLayoutConstraint!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTap()
        continueButton.layer.cornerRadius = 5
        
        var format = AnimatedBlurFieldFormat()
        format.titleFont = UIFont(name: "AvenirNext-Regular", size: 12)!
        format.textFont = UIFont(name: "AvenirNext-Regular", size: 14)!
        format.titleColor = UIColor.init(white: 1.0, alpha: 0.6)
        format.textColor = .white
        format.highlightColor = UIColor.init(white: 1.0, alpha: 0.6)
        //format.uppercasedTitles = true
        format.alertColor = .red
        format.alertFieldActive = false
        format.titleAlwaysVisible = false
        format.titleInVisibleIfFilled = false
        format.alertFont = UIFont(name: "AvenirNext-Regular", size: 14)!
        
        /*DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
          self.usernameAnimatedField.text = ""
        }
      
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
          self.multilineAnimatedField.text = "Write your email Write your email Write your email Write your email Write your email"
        }
      
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
          self.multilineAnimatedField.text = ""
        }*/
      
        emailAnimatedField.format = format
        emailAnimatedField.setUp(with: .email,
                                 delegate: self,
                                 dataSource: self,
                                 placeHolder: "Write your email",
                                 attributes: [
                                  .foregroundColor: UIColor.init(white: 1.0, alpha: 0.8),
                                  .font: UIFont.systemFont(ofSize: 14)])
        emailAnimatedField.tag = 0
        
        usernameAnimatedField.format = format
        usernameAnimatedField.setUp(with: .username(4, 10),
                                    delegate: self,
                                    dataSource: self,
                                    placeHolder: "Write your username",
                                    attributes: nil)
        usernameAnimatedField.tag = 1
        
        birthdateAnimatedField.format = format
        let defaultDate = Date().addingTimeInterval(-20 * 365 * 24 * 60 * 60)
        let minDate = Date().addingTimeInterval(-90 * 365 * 24 * 60 * 60)
        let maxDate = Date().addingTimeInterval(-13 * 365 * 24 * 60 * 60)
        let chooseText = "Choose"
        let dateFormat = "dd / MM / yyyy"
        birthdateAnimatedField.setUp(with: .datepicker(.dateAndTime, defaultDate, minDate, maxDate, chooseText, dateFormat),
                                     delegate: self,
                                     dataSource: self,
                                     placeHolder: "Select your birthday",
                                     attributes: nil)
        birthdateAnimatedField.tag = 2
    
        numberAnimatedField.format = format
        numberAnimatedField.setUp(with: .numberpicker(19, 16, 100, chooseText),
                                  delegate: self,
                                  dataSource: self,
                                  placeHolder: "Select your age",
                                  attributes: nil)
        numberAnimatedField.tag = 3
        
        passwordAnimatedField.format = format
        passwordAnimatedField.setUp(with: .password(6, 10),
                                    delegate: self,
                                    dataSource: self,
                                    placeHolder: "New password (min 6, max 10)",
                                    attributes: nil)
        passwordAnimatedField.isSecure = true
        passwordAnimatedField.disablePasswordAutoFill = true
        passwordAnimatedField.showVisibleButton = true
        passwordAnimatedField.visibleEyeIconApperance = (color: .red, size: .init(width: 15, height: 15))
        passwordAnimatedField.tag = 4
        
        password2AnimatedField.format = format
        password2AnimatedField.setUp(with: .password(6, 10),
                                     delegate: self,
                                     dataSource: self,
                                     placeHolder: "Repeat password",
                                     attributes: nil)
        password2AnimatedField.isSecure = true
        password2AnimatedField.tag = 5
        
        priceAnimatedField.format = format
        priceAnimatedField.setUp(with: .price(100, 2),
                                 delegate: self,
                                 dataSource: self,
                                 placeHolder: "Write the price",
                                 attributes: nil)
        priceAnimatedField.tag = 6
        
        urlAnimatedField.format = format
        urlAnimatedField.setUp(with: .url,
                               delegate: self,
                               dataSource: self,
                               placeHolder: "Write your url web",
                               attributes: nil)
        urlAnimatedField.tag = 7
        
        multilineAnimatedField.format = format
        multilineAnimatedField.format.counterEnabled = true
        multilineAnimatedField.format.countDownDecrementally = false
        multilineAnimatedField.setUp(with: .multiline(70.0),
                                     delegate: self,
                                     dataSource: self,
                                     placeHolder: "Place",
                                     attributes: nil)
        //multilineAnimatedField.autocapitalizationType = .words
        multilineAnimatedField.tag = 8
      
      
        defaultField.format = format
        defaultField.setUp(with: .none,
                           delegate: self,
                           dataSource: self,
                           placeHolder: "This is a no-type field",
                           attributes: nil)
        defaultField.isSecure = true
        defaultField.tag = 9
    }
    
    @IBAction func didPressContinueButton(_ sender: UIButton) {
        print("Can continue")
    }
}


extension ViewController: AnimatedBlurFieldDelegate {
    
    func animatedFieldDidBeginEditing(_ animatedField: AnimatedBlurField) {
        let offset = animatedField.frame.origin.y + animatedField.frame.size.height - (view.frame.height - 350)
        scrollView.setContentOffset(CGPoint(x: 0, y: offset < 0 ? 0 : offset), animated: true)
    }
    
    func animatedFieldDidEndEditing(_ animatedField: AnimatedBlurField) {
        var offset: CGFloat = 0
        if animatedField.frame.origin.y + animatedField.frame.size.height > scrollView.frame.height {
            offset = animatedField.frame.origin.y + animatedField.frame.size.height - scrollView.frame.height + 10
        }
        scrollView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
        
        let validEmailUser = emailAnimatedField.isValid && usernameAnimatedField.isValid
        continueButton.isEnabled = validEmailUser
        continueButton.alpha = validEmailUser ? 1.0 : 0.3
    }
    
    func animatedField(_ animatedField: AnimatedBlurField, didResizeHeight height: CGFloat) {
        multilineHeightConstraint.constant = height
        view.layoutIfNeeded()
        
        let offset = animatedField.frame.origin.y + height - (view.frame.height - 350)
        scrollView.setContentOffset(CGPoint(x: 0, y: offset < 0 ? 0 : offset), animated: false)
    }
    
    func animatedField(_ animatedField: AnimatedBlurField, didSecureText secure: Bool) {
        if animatedField == passwordAnimatedField {
            password2AnimatedField.secureField(secure)
        }
    }
    
    func animatedField(_ animatedField: AnimatedBlurField, didChangePickerValue value: String) {
        numberAnimatedField.text = value
    }
}

extension ViewController: AnimatedBlurFieldDataSource {
    
    func animatedFieldLimit(_ animatedField: AnimatedBlurField) -> Int? {
        switch animatedField.tag {
        case 1: return 10
        case 8: return 30
        default: return nil
        }
    }
    
    func animatedFieldValidationError(_ animatedField: AnimatedBlurField) -> String? {
        if animatedField == emailAnimatedField {
            return "Email invalid! Please check again ;)"
        }
        return nil
    }
}

