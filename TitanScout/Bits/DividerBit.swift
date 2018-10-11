//
//  DividerBit.swift
//  TitanScout
//
//  Created by Ian Fowler on 2/27/18.
//  Copyright © 2018 Ian Fowlercom.example. All rights reserved.
//


import UIKit
class DividerBit: Bit {
	
	var divider = UIView()
	
	override func draw(_ rect: CGRect) {
		super.descriptionLabel.frame = CGRect(x: 0.0, y: self.frame.height / 4.0 , width: self.frame.width, height: descriptionLabelHeight )
		super.descriptionLabel.font = UIFont(name: super.descriptionLabel.font.fontName, size: 20.0)
		self.addSubview(super.descriptionLabel)
		divider.frame = CGRect(x: 0, y: super.descriptionLabel.frame.maxY + 5, width: self.frame.width, height: 2)
		divider.layer.borderWidth = 0.5
		divider.backgroundColor = UIColor.darkGray
		self.addSubview(divider)
		
	}
	
	
}
