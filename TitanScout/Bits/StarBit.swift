//
//  StarBit.swift
//  TitanScout
//
//  Created by Ian Fowler on 3/31/18.
//  Copyright © 2018 Ian Fowlercom.example. All rights reserved.
//

import UIKit
import fluid_slider

class StarBit: Bit {
	
	var ratingSlider = Slider()
	var container = UIView()
	
	override func draw(_ rect: CGRect) {
		self.addSubview(super.descriptionLabel)
		ratingSlider.frame = CGRect(x: 0, y: 30, width: self.frame.width, height: 38)
		ratingSlider.tintColor = UIColor().primaryColor()
		
		ratingSlider.attributedTextForFraction = { fraction in
			let formatter = NumberFormatter()
			formatter.maximumIntegerDigits = 2
			formatter.maximumFractionDigits = 1
			let string = formatter.string(from: Double(Int(fraction * 20.0)) / 2.0 as NSNumber) ?? ""
			return NSAttributedString(string: string)
		}
		
		// this looks a little stupid at first, but it's necessary to implement the string formatting for the preset.
		ratingSlider.fraction = ratingSlider.fraction
		
		ratingSlider.setMinimumLabelAttributedText(NSAttributedString(string: "0"))
		ratingSlider.setMaximumLabelAttributedText(NSAttributedString(string: "10"))
		ratingSlider.shadowOffset = CGSize(width: 0, height: 5)
		ratingSlider.shadowBlur = 5
		ratingSlider.shadowColor = UIColor(white: 0, alpha: 0.1)
		ratingSlider.contentViewColor = UIColor().primaryColor()
		ratingSlider.valueViewColor = .white
		
		ratingSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
		
		self.addSubview(ratingSlider)
		
	}
	
	
	@objc func sliderValueChanged() {
		super.update(String(describing: getSliderValue()))
	}
	
	func getSliderValue() -> Double {
		return Double(Int(ratingSlider.fraction * 20.0)) / 2.0
	}
	
	init(key: String, title: String, preload:String?) {
		super.init(key: key, title:title)
		ratingSlider.fraction = 0.5

		if let p = preload {
			if let initialValue = Double(p) {
				ratingSlider.fraction = CGFloat(initialValue) / 10.0
			}
		}
		sliderValueChanged()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(key: "", title: "")
		super.update("5.0")
	}
	
}


