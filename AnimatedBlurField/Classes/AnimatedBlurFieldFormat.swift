//
//  AnimateFieldConfiguration.swift
//  FashTime
//
//  Created by Alberto Aznar de los Ríos on 02/04/2019.
//  Copyright © 2019 FashTime Ltd. All rights reserved.
//

import Foundation

public struct AnimatedBlurFieldFormat {
    
    /// Title always visible
    public var titleInVisibleIfFilled = false
    
    /// Font for title label
    public var titleFont = UIFont.systemFont(ofSize: 13, weight: .regular)
    
    /// Font for text field
    public var textFont = UIFont.systemFont(ofSize: 16, weight: .regular)
    
    /// Font for counter
    public var counterFont = UIFont.systemFont(ofSize: 13, weight: .regular)
    
    /// Title label text color
    public var titleColor = UIColor(white: 1.0, alpha: 0.6)
    
    /// TextField text color
    public var textColor = UIColor.white
  
    //When title label becomes placeHolder
    public var placeHolderColor: UIColor = UIColor(white: 1.0, alpha: 0.8)
    
    /// Title label text uppercased
    public var uppercasedTitles = false
  
    /// Counter text color
    public var counterColor = UIColor.white
    
    /// Enable alert
    public var alertEnabled = true
    
    /// Font for alert label
    public var alertFont = UIFont.systemFont(ofSize: 13, weight: .regular)
    
    /// Alert status color
    public var alertColor = UIColor.red
    
    /// Colored alert field text
    public var alertFieldActive = true
    
    /// Colored alert line
    public var alertLineActive = true
    
    /// Colored alert title
    public var alertTitleActive = true
    
    /// Alert position
    public var alertPosition = AnimatedBlurFieldAlertPosition.top
    
    /// Secure icon image (On status)
    public var visibleOnImage = IconsLibrary.imageOfEye(color: .red)
    
    /// Secure icon image (Off status)
    public var visibleOffImage = IconsLibrary.imageOfEyeoff(color: .red)
    
    /// Enable counter label
    public var counterEnabled = false
    
    /// Set count down by decrementally
    public var countDownDecrementally = false
    
    /// Enable counter animation on change
    public var counterAnimation = false
    
    /// VisualEffectView attributes
    public var visualEffectColorTint = UIColor.white
    public var visualEffectColorTintAlpha: CGFloat = 0.15
    public var visualEffectBlurRadius: CGFloat = 10
    public var visualEffectScale: CGFloat = 1
  
    public init() {}
}
