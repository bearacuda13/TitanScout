//
//  SwitchBit.swift
//  TitanScout
//
//  Created by Ian Fowler on 2/19/18.
//  Copyright © 2018 Ian Fowlercom.example. All rights reserved.
//


import UIKit

class SwitchBit: Bit {
	
	var mainSwitch = Switch()
	
	var leftText:String
	var rightText:String
	
	func switchChanged() {
		if mainSwitch.rightSelected {
			super.update(mainSwitch.rightText ?? "")
		} else {
			super.update(mainSwitch.leftText ?? "")
		}
	}

	@objc func updateFor(s: Switch) {
		switchChanged()
	}
	
	override func draw(_ rect: CGRect) {
		
		
		self.addSubview(super.descriptionLabel)
		
		mainSwitch.frame = CGRect(x: 0, y: 30, width: self.frame.width, height: 38)
		mainSwitch.rightText = rightText
		mainSwitch.leftText = leftText
		mainSwitch.addTarget(self, action: #selector(updateFor), for: .valueChanged)
		
		self.addSubview(mainSwitch)
	}


	init(key: String, title: String, left:String, right:String) {
		leftText = left
		rightText = right
		super.init(key: key, title:title)
		updateFor(s: mainSwitch)
	}
	
	required init?(coder aDecoder: NSCoder) {
		leftText = ""
		rightText = ""
		super.init(key: "", title: "")
		updateFor(s: mainSwitch)
	}
	
}

