//
//  TextfieldBit.swift
//  TitanScout
//
//  Created by Ian Fowler on 2/27/18.
//  Copyright © 2018 Ian Fowlercom.example. All rights reserved.
//
//
//  Step.swift
//  TitanScout
//
//  Created by Ian Fowler on 2/18/18.
//  Copyright © 2018 Ian Fowlercom.example. All rights reserved.
//

import UIKit
class TextFieldBit: Bit {
	
	var stepper = GMStepper()
	
	@objc func updateFor(s: GMStepper) {
		super.update(String(Int(s.value)))
	}
	
	override func draw(_ rect: CGRect) {
		self.addSubview(super.descriptionLabel)
		
		stepper.frame = CGRect(x: 0, y: 30, width: self.frame.width, height: 38)
		stepper.addTarget(self, action: #selector(updateFor), for: .valueChanged)
		stepper.buttonsBackgroundColor = UIColor(rgb: 0x007AFF)
		stepper.labelBackgroundColor = UIColor(rgb: 0x66CCFF)
		self.addSubview(stepper)
	}
	
	
}

