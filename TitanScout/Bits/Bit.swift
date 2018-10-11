//
//  Bit.swift
//  TitanScout
//
//  Created by Ian Fowler on 2/19/18.
//  Copyright © 2018 Ian Fowlercom.example. All rights reserved.
//

import UIKit

class Bit: UIView {
	
	var bitView: UIView!

	var title:String
	var dictKey:String
	
	let descriptionLabelHeight:CGFloat = 25.0
	
	var descriptionLabel = UILabel()

	
	var viewFrame = CGRect(x: 0, y: 0, width: 320, height: 74)
	
	init(key: String, title:String) {
		self.title = title
		self.dictKey = key
		super.init(frame: viewFrame)
		self.backgroundColor = UIColor.clear
		descriptionLabel.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.width, height: descriptionLabelHeight)
		descriptionLabel.text = title
	}
	
	func update(_ value:String) {
		info.updateValue(value, forKey: dictKey)
	}
	
	func update(_ value:String, withKey:String) {
		info.updateValue(value, forKey: withKey)
	}
	
	required init?(coder aDecoder: NSCoder) {
		self.title = ""
		self.dictKey = ""
		super.init(coder: aDecoder)
	}

	
	

	
}
