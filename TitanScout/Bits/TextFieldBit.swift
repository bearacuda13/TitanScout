//
//  TextfieldBit.swift
//  TitanScout
//
//  Created by Ian Fowler on 2/27/18.
//  Copyright © 2018 Ian Fowlercom.example. All rights reserved.
//

import UIKit
class TextFieldBit: Bit, UITextFieldDelegate {
	
	var textField = UITextField()
	
	@objc func updateFor(s: UITextField) {
		super.update(s.text ?? "")
	}
	
	var isNumPad:String
	
	init(key: String, title: String, isNumberPad:String, preload:String?) {
		isNumPad = isNumberPad
		super.init(key: key, title: title)
		textField.delegate = self
		if let p = preload {
			textField.text = p
		}
		updateFor(s: textField)
	}
	
	
	required init?(coder aDecoder: NSCoder) {
		isNumPad = "NO"
		super.init(key: "", title: "")
		textField.delegate = self
	}
	
	override func draw(_ rect: CGRect) {
		self.addSubview(super.descriptionLabel)
		textField.frame = CGRect(x: 0, y: 30, width: self.frame.width, height: 38)
		textField.addTarget(self, action: #selector(updateFor), for: .valueChanged)
		textField.autocorrectionType = .no
		if isNumPad.uppercased() == "YES" || isNumPad.uppercased() == "Y" {
			textField.keyboardType = UIKeyboardType.numberPad
		}
		textField.layer.borderWidth = 1.0
		textField.layer.borderColor = UIColor.lightGray.cgColor
		self.addSubview(textField)
	}
	func textFieldDidBeginEditing(_ textField: UITextField) {
		EditViewController().textFieldDidBeginEditing(textField)
		super.update(textField.text ?? "")
		updateFor(s: textField)
	}
	func textFieldDidEndEditing(_ textField: UITextField) {
		EditViewController().textFieldDidEndEditing(textField)
		super.update(textField.text ?? "")
		updateFor(s: textField)
	}
	
}

