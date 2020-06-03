//
//  AnimatedBlurField.swift
//  FashTime
//
//  Created by Alberto Aznar de los Ríos on 02/04/2019.
//  Copyright © 2019 FashTime Ltd. All rights reserved.
//

import UIKit

extension UIToolbar {
	
	convenience init(target: Any, selector: Selector) {
		
		let rect = CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 44.0)
		let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
		let barButton = UIBarButtonItem(barButtonSystemItem: .done, target: target, action: selector)
		
		self.init(frame: rect)
		barStyle = .black
		tintColor = .white
		setItems([flexible, barButton], animated: false)
	}
}

open class AnimatedBlurField: UIView {
    
    @IBOutlet weak private var textField: UITextField!
    @IBOutlet weak private var textFieldRightConstraint: NSLayoutConstraint!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var alertLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var eyeButton: UIButton!
    @IBOutlet weak private var textView: UITextView!
    @IBOutlet weak private var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak private var titleLabelTextFieldConstraint: NSLayoutConstraint?
    @IBOutlet weak private var titleLabelTextViewConstraint: NSLayoutConstraint?
    @IBOutlet weak private var counterLabelTextFieldConstraint: NSLayoutConstraint?
    @IBOutlet weak private var counterLabelTextViewConstraint: NSLayoutConstraint?
    @IBOutlet weak private var alertLabelBottomConstraint: NSLayoutConstraint!
  
    @IBOutlet weak private var textFieldCenterYConstraint: NSLayoutConstraint?
    @IBOutlet weak private var textViewTopConstraint: NSLayoutConstraint?
    @IBOutlet weak private var titleLabelLeadingConstraint: NSLayoutConstraint?
    
    public var targetTitleLeadingPadding: CGFloat = 5.0
  
    /// Date picker values
    private var datePicker: UIDatePicker?
    private var initialDate: Date?
    private var dateFormat: String?
    private var maxMultiLinesHeight: CGFloat?
    
  
    /// Picker values
    private var numberPicker: UIPickerView?
    var numberOptions = [Int]()
    
    var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current // USA: Locale(identifier: "en_US")
        formatter.numberStyle = .decimal
        return formatter
    }
	
    var isPlaceholderVisible = true
	
    /// Placeholder
    var placeholder = ""
	
    /// The styled string that is displayed when there is no other text in the text field.
    var attributedPlaceholder: NSAttributedString?
	
    /// Field type (default values)
    var type: AnimatedBlurFieldType = .none {
        didSet {
            if case let AnimatedBlurFieldType.datepicker(mode, defaultDate, minDate, maxDate, chooseText, format) = type {
                initialDate = defaultDate
                dateFormat = format
                setupDatePicker(mode: mode, minDate: minDate, maxDate: maxDate, chooseText: chooseText)
            }
            if case let AnimatedBlurFieldType.numberpicker(defaultNumber, minNumber, maxNumber, chooseText) = type {
                setupPicker(defaultNumber: defaultNumber, minNumber: minNumber, maxNumber: maxNumber, chooseText: chooseText)
            }
            if case AnimatedBlurFieldType.price = type {
                keyboardType = .decimalPad
            }
            if case AnimatedBlurFieldType.email = type {
                keyboardType = .emailAddress
            }
            if case AnimatedBlurFieldType.url = type {
                keyboardType = .URL
            }
            if case let AnimatedBlurFieldType.multiline(maxHeight) = type {
                if var height = maxHeight {
                  if height < 41 { height = 40 }
                  maxMultiLinesHeight = height
                }
                showTextView(true)
                setupTextViewConstraints()
            } else {
                showTextView(false)
                setupTextFieldConstraints()
            }
        }
    }
	    
    /// Uppercased field format
    public var uppercased = false
    
    /// Lowercased field format
    public var lowercased = false
    
    /// The input accessory view for this field
    public var accessoryView: UIView? {
      didSet {
        textField.inputAccessoryView = accessoryView
        textView.inputAccessoryView = accessoryView
      }
    }
    
    public var keyboardAppearance: UIKeyboardAppearance = .default {
      didSet {
        textField.keyboardAppearance = keyboardAppearance
        textView.keyboardAppearance = keyboardAppearance
      }
    }
  
    /// Keyboard type
    public var keyboardType = UIKeyboardType.alphabet {
        didSet { textField.keyboardType = keyboardType }
    }
  
    public var autocapitalizationType: UITextAutocapitalizationType = .sentences {
        didSet {
            textField.autocapitalizationType = autocapitalizationType
            textView.autocapitalizationType = autocapitalizationType
        }
    }
	
    public var keyboardToolbar: UIToolbar? {
      didSet { textField.inputView = keyboardToolbar }
    }
    
    /// Secure field (dot format)
    public var isSecure = false {
        didSet { textField.isSecureTextEntry = isSecure }
    }
  
    public var disablePasswordAutoFill = false {
      didSet {
        //https://stackoverflow.com/a/46474180
        if #available(iOS 12, *) {
            // iOS 12 & 13: Not the best solution, but it works.
            textField.textContentType = .oneTimeCode
        } else {
            // iOS 11: Disables the autofill accessory view.
            textField.textContentType = .init(rawValue: "")
        }
      }
    }
    
    /// Show visible button to make field unsecure
    public var showVisibleButton = false {
        didSet {
            if showVisibleButton {
                eyeButton.isHidden = false
                textFieldRightConstraint.constant = 30
                secureField(true)
            } else {
                eyeButton.isHidden = true
                textFieldRightConstraint.constant = 0
            }
        }
    }
  
    public var visibleEyeIconApperance: (color: UIColor, size: CGSize) = (color: .lightGray, size: .init(width: 15, height: 15)) {
      didSet {
        format.visibleOnImage = IconsLibrary.imageOfEye(color: visibleEyeIconApperance.color, size: visibleEyeIconApperance.size)
        format.visibleOffImage = IconsLibrary.imageOfEyeoff(color: visibleEyeIconApperance.color, size: visibleEyeIconApperance.size)
        eyeButton.tintColor = visibleEyeIconApperance.color
        eyeButton.setImage(isSecure ? format.visibleOffImage : format.visibleOnImage, for: .normal)
      }
    }
    
    /// Result of regular expression validation
    public var isValid: Bool {
        get { return !(validateText(textField.isHidden ? textView.text : textField.text) != nil) }
    }
    
    /////////////////////////////////////////////////////////////////////////////
    /// The object that provides the data for the field view
    /// - Note: The data source must adopt the `AnimatedFieldDataSource` protocol.
    
    weak open var dataSource: AnimatedBlurFieldDataSource?
    
    /////////////////////////////////////////////////////////////////////////////
    /// The object that acts as the delegate of the animated field view. The delegate
    /// object is responsible for managing selection behavior and interactions with
    /// individual items.
    /// - Note: The delegate must adopt the `AnimatedFieldDelegate` protocol.
    weak open var delegate: AnimatedBlurFieldDelegate?
    
    /////////////////////////////////////////////////////////////////////////////
    /// Object that configure `AnimatedField` view. You can setup `AnimatedField` with
    /// your own parameters. See also `AnimatedFieldFormat` implementation.
    
    open var format = AnimatedBlurFieldFormat() {
        didSet {
            titleLabel.font = format.titleFont
            titleLabel.textColor = format.titleColor
            textField.font = format.textFont
            textField.textColor = format.textColor
            textView.font = format.textFont
            textView.textColor = format.textColor
            eyeButton.tintColor = format.textColor
            counterLabel.font = format.counterFont
            counterLabel.textColor = format.counterColor
            alertLabel.font = format.alertFont
            alertLabelBottomConstraint.isActive = format.alertPosition == .top
        }
    }
    
    open var text: String? {
        get {
            return textField.isHidden ? textView.text : textField.text
        }
        set {
            guard let text = newValue, text.count > 0 else {
                textField.text = textField.isHidden ? nil : newValue
                
                if !textView.isHidden {
                  textView.text = ""
                  resizeTextViewHeight()
                  endTextViewPlaceholder()
                }
                return
            }
          
            textField.text = textField.isHidden ? nil : text
            
            if !format.titleInVisibleIfFilled { animateIn() }
            if !textView.isHidden {
              textView.text = text
              resizeTextViewHeight()
              textView.textColor = format.textColor
            }
        }
    }
    
    public func setUp(with type: AnimatedBlurFieldType,
               delegate: AnimatedBlurFieldDelegate?,
               dataSource: AnimatedBlurFieldDataSource?,
               placeHolder: String,
               attributes: [NSAttributedString.Key : Any]?) {
      self.delegate = delegate
      self.dataSource = dataSource
      
      self.placeholder = placeHolder
      if let attributes = attributes {
        attributedPlaceholder = NSAttributedString(string: placeHolder, attributes: attributes)
      }
      
      if case AnimatedBlurFieldType.multiline = type {
        setupTextView()
      }else{
        setupTextField()
      }
      setupTitle()
      
      self.type = type
      setupVisualEffect()
    }
  
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
  
    open override func layoutSubviews() {
      super.layoutSubviews()
      self.viewWithTag(101)?.frame = self.bounds
      
      if isPlaceholderVisible { animateOut() }
    }
    
    private func commonInit() {
        _ = fromNib()
        setupView()
        setupTextField()
        setupTextView()
        setupTitle()
        setupEyeButton()
        setupAlertTitle()
        showTextView(false)
    }
  
    private func setupView() {
        backgroundColor = .clear
        clipsToBounds = true
    }
  
    private func setupVisualEffect() {
        self.viewWithTag(101)?.removeFromSuperview()
        
        // Create a blur effect
        /*let blurEffect = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.contentView.backgroundColor = UIColor(white: 0.0, alpha: 0.15)
        blurEffectView.tag = 101
        self.addSubview(blurEffectView)
        self.sendSubviewToBack(blurEffectView)
        self.layer.cornerRadius = 4.0*/
      
        let visualEffectView = VisualEffectView(frame: self.bounds)
        visualEffectView.colorTint = format.visualEffectColorTint
        visualEffectView.colorTintAlpha = format.visualEffectColorTintAlpha
        visualEffectView.blurRadius = format.visualEffectBlurRadius
        visualEffectView.scale = format.visualEffectScale
        visualEffectView.tag = 101
        
        self.addSubview(visualEffectView)
        self.sendSubviewToBack(visualEffectView)
        self.layer.cornerRadius = 4.0
    }
    
    private func setupTextField() {
        textField.delegate = self
        textField.textColor = format.textColor
        textField.tintColor = format.textColor
        textField.tag = tag
        textField.backgroundColor = .clear
    }
    
    private func setupTitle() {
        titleLabel.text = format.uppercasedTitles ? placeholder.uppercased() : placeholder
    }
    
    private func setupTextView() {
        textView.delegate = self
        textView.textColor = format.textColor
        textView.tintColor = format.textColor
        textView.tag = tag
        textView.textContainerInset = .zero
        textView.contentInset = UIEdgeInsets(top: 3, left: -5, bottom: 6, right: 0)
        textViewDidChange(textView)
        endTextViewPlaceholder()
    }
    
    private func showTextView(_ show: Bool) {
        textField.isHidden = show
        textField.text = show ? nil : ""
        textView.isHidden = !show
    }
    
    private func setupEyeButton() {
        showVisibleButton = false
        eyeButton.tintColor = format.textColor
    }
    
    private func setupAlertTitle() {
        alertLabel.alpha = 0.0
    }
    
    private func setupTextFieldConstraints() {
        titleLabelTextFieldConstraint?.isActive = true
        counterLabelTextFieldConstraint?.isActive = true
        titleLabelTextViewConstraint?.isActive = false
        counterLabelTextViewConstraint?.isActive = false
        layoutIfNeeded()
    }
    
    private func setupTextViewConstraints() {
        titleLabelTextFieldConstraint?.isActive = false
        counterLabelTextFieldConstraint?.isActive = false
        titleLabelTextViewConstraint?.isActive = true
        counterLabelTextViewConstraint?.isActive = true
        layoutIfNeeded()
    }
    
    private func setupDatePicker(mode: UIDatePicker.Mode?, minDate: Date?, maxDate: Date?, chooseText: String?) {
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = mode ?? .date
        datePicker?.maximumDate = maxDate
        datePicker?.minimumDate = minDate
        datePicker?.setValue(format.textColor, forKey: "textColor")
        
        let toolBar = UIToolbar(target: self, selector: #selector(didChooseDatePicker))
		
        textField.inputAccessoryView = accessoryView ?? toolBar
        textField.inputView = datePicker
    }
    
    private func setupPicker(defaultNumber: Int, minNumber: Int, maxNumber: Int, chooseText: String?) {
        
        numberPicker = UIPickerView()
        numberPicker?.dataSource = self
        numberPicker?.delegate = self
        numberPicker?.setValue(format.textColor, forKey: "textColor")
        
        numberOptions += minNumber...maxNumber
        if let index = numberOptions.firstIndex(where: {$0 == defaultNumber}) {
            numberPicker?.selectRow(index, inComponent:0, animated:false)
        }
        
		let toolBar = UIToolbar(target: self, selector: #selector(didChooseNumberPicker))
		
        textField.inputAccessoryView = accessoryView ?? toolBar
        textField.inputView = numberPicker
    }
    
    open override func becomeFirstResponder() -> Bool {
        if !textField.isHidden {
          textField.becomeFirstResponder()
        }else{
          textView.becomeFirstResponder()
        }
      
        return super.becomeFirstResponder()
    }
    
    open override func resignFirstResponder() -> Bool {
        if !textField.isHidden {
          textField.resignFirstResponder()
        }else{
          textView.resignFirstResponder()
        }
        return super.resignFirstResponder()
    }
    
    @IBAction func didPressEyeButton(_ sender: UIButton) {
        secureField(!textField.isSecureTextEntry)
    }
    
    @IBAction func didChangeTextField(_ sender: UITextField) {
        updateCounterLabel()
    }
    
    @objc func didChooseDatePicker() {
        let date = datePicker?.date ?? initialDate
        textField.text = date?.format(dateFormat: dateFormat ?? "dd / MM / yyyy")
        _ = resignFirstResponder()
    }
    
    @objc func didChooseNumberPicker() {
//        textField.text = numberPicker
        _ = resignFirstResponder()
    }
}

// CLASS METHODS

extension AnimatedBlurField {
    
    func animateIn() {
        isPlaceholderVisible = false
        titleLabelTextViewConstraint?.constant = -5
        titleLabelTextFieldConstraint?.constant = -5
        textFieldCenterYConstraint?.constant = 8
        textViewTopConstraint?.constant = 20
        titleLabelLeadingConstraint?.constant = targetTitleLeadingPadding
      
        UIView.animate(withDuration: 0.3) { [weak self] in
          self?.titleLabel.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
          self?.layoutIfNeeded()
        }
      
      titleLabel.textColor = format.titleColor
    }
    
    func animateOut() {
        isPlaceholderVisible = true
        titleLabelTextViewConstraint?.constant = -(textField.frame.height/2.0 + titleLabel.frame.height/2.0)
        titleLabelTextFieldConstraint?.constant = -(textField.frame.height/2.0 + titleLabel.frame.height/2.0)
        textFieldCenterYConstraint?.constant = 0
        textViewTopConstraint?.constant = 10
        titleLabelLeadingConstraint?.constant = 15
      
        UIView.animate(withDuration: 0.3) { [weak self] in
          self?.titleLabel.transform = .identity
          self?.layoutIfNeeded()
        }
      
      if let attText = attributedPlaceholder {
        titleLabel.attributedText = attText
      }else {
        titleLabel.textColor = format.placeHolderColor
      }
    }
    
    func animateInAlert(_ message: String?) {
        guard let message = message else { return }
        
        alertLabel.text = message
        alertLabel.textColor = format.alertTitleActive ? format.alertColor : format.titleColor
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.titleLabel.alpha = 0.0
            self?.alertLabel.alpha = 1.0
        }) { [weak self] (completed) in
            self?.alertLabel.shake()
        }
    }
    
    func animateOutAlert() {
        alertLabel.text = ""
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.titleLabel.alpha = 1.0
            self?.alertLabel.alpha = 0.0
        }
    }
    
    func updateCounterLabel() {
      guard format.counterEnabled else { return }
        let value = (dataSource?.animatedFieldLimit(self) ?? 0) - textView.text.count
        counterLabel.text = format.countDownDecrementally ? "\(value)" : "\(textView.text.count)/\(dataSource?.animatedFieldLimit(self) ?? 0)"
        if format.counterAnimation {
            counterLabel.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.counterLabel.transform = .identity
            }
        }
    }
    
    func resizeTextViewHeight() {
      textView.isScrollEnabled = true
        let size = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        if let maxHeight = maxMultiLinesHeight, size.height > maxHeight {
          textView.isScrollEnabled = true
          textView.showsVerticalScrollIndicator = true
          return
        }
        
        if size.height < 25 {
          textView.textContainerInset = .zero
          textView.isScrollEnabled = false
          textView.showsVerticalScrollIndicator = false
          textViewHeightConstraint.constant = 30
          delegate?.animatedField(self, didResizeHeight: 50)
          return
        }
      
        textViewHeightConstraint.constant = 10 + size.height
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.layoutIfNeeded()
        }
      
        delegate?.animatedField(self, didResizeHeight: size.height + 15 + titleLabel.frame.size.height)
    }
    
    func endTextViewPlaceholder() {
        counterLabel.isHidden = true
    }
    
    func beginTextViewPlaceholder() {
        counterLabel.isHidden = !format.counterEnabled
        if format.counterEnabled { updateCounterLabel() }
    }
    
    func validateText(_ text: String?) -> String? {
        let validationExpression = type.validationExpression
        let regex = dataSource?.animatedFieldValidationMatches(self) ?? validationExpression
        if let text = text, text != "", !text.isValidWithRegEx(regex) {
            return dataSource?.animatedFieldValidationError(self) ?? type.validationError
        }
        
        if
            case let AnimatedBlurFieldType.price(maxPrice, _) = type,
            let text = text,
            text != "",
            let price = formatter.number(from: text),
            price.doubleValue > maxPrice {
            return dataSource?.animatedFieldPriceExceededError(self) ?? type.priceExceededError
        }
        return nil
    }
}

extension AnimatedBlurField: AnimatedFieldInterface {
    
    open func restart() {
        _ = resignFirstResponder()
        endEditing(true)
        textField.text = ""
    }
  
    open func showAlert(_ message: String? = nil) {
        guard format.alertEnabled else { return }
        textField.textColor = format.alertFieldActive ? format.alertColor : format.textColor
        animateInAlert(message)
    }
    
    open func hideAlert() {
        textField.textColor = format.textColor
        animateOutAlert()
    }
    
    open func secureField(_ secure: Bool) {
        isSecure = secure
        eyeButton.setImage(secure ? format.visibleOffImage : format.visibleOnImage, for: .normal)
        delegate?.animatedField(self, didSecureText: secure)
    }
}
