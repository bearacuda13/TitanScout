//
//  Step.swift
//  TitanScout
//
//  Created by Ian Fowler on 2/18/18.
//  Copyright © 2018 Ian Fowlercom.example. All rights reserved.
//

import UIKit
class StepBit: Bit {

	var stepper = GMStepper()
	var color: String
	
	@objc func updateFor(s: GMStepper) {
		super.update(String(Int(s.value)))
	}
	
	override func draw(_ rect: CGRect) {
		self.addSubview(super.descriptionLabel)
		stepper.frame = CGRect(x: 0, y: 30, width: self.frame.width, height: 38)
		stepper.addTarget(self, action: #selector(updateFor), for: .valueChanged)
		if color.lowercased() == "default" {
			stepper.buttonsBackgroundColor = UIColor(rgb: 0x007AFF).darkenedPrimaryColor()
			stepper.labelBackgroundColor = UIColor(rgb: 0x66CCFF).primaryColor()
		} else {
			stepper.buttonsBackgroundColor = color.toUIColor()
			stepper.labelBackgroundColor = color.toUIColor().lighter(by: 18.0)
		}
		self.addSubview(stepper)
	}
	
	override func didAddSubview(_ subview: UIView) {
		updateFor(s: stepper)
	}
	
	init(key: String, title: String, color:String, preload: String?) {
		self.color = color
		
		super.init(key: key, title:title)
		
		if let p = preload {
			if let initialValue = Int(p) {
				stepper.value = Double(initialValue)
			}
		}
		
		updateFor(s: stepper)
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		color = ""
		super.init(key: "", title: "")
		updateFor(s: stepper)
	}
	
}


extension String {
	func toUIColor() -> UIColor {
		
		var cString:String = self.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
		
		if (cString.hasPrefix("#")) {
			cString.remove(at: cString.startIndex)
		}
		
		if ((cString.count) != 6) {
			return UIColor.gray
		}
		
		var rgbValue:UInt32 = 0
		Scanner(string: cString).scanHexInt32(&rgbValue)
		
		return UIColor(
			red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
			green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
			blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
			alpha: CGFloat(1.0)
		)
	}
}

extension UIColor {
	
	func lighter(by:CGFloat) -> UIColor {
		return self.adjust(by: abs(by) )
	}
	
	func darker(by:CGFloat) -> UIColor {
		return self.adjust(by: -1 * abs(by) )
	}
	
	func adjust(by:CGFloat) -> UIColor {
		var r:CGFloat=0, g:CGFloat=0, b:CGFloat=0, a:CGFloat=0;
		if(self.getRed(&r, green: &g, blue: &b, alpha: &a)){
			return UIColor(red: min(r + by/100, 1.0),
						   green: min(g + by/100, 1.0),
						   blue: min(b + by/100, 1.0),
						   alpha: a)
		}
		return UIColor.clear
	}
	
	func scale(by:CGFloat) -> UIColor {
		var r:CGFloat=0, g:CGFloat=0, b:CGFloat=0, a:CGFloat=0;
		if(self.getRed(&r, green: &g, blue: &b, alpha: &a)){
			return UIColor(red: min(r * (100.0 + by)/100.0, 1.0),
						   green: min(g + (100.0 + by)/100.0, 1.0),
						   blue: min(b + (100.0 + by)/100.0, 1.0),
						   alpha: a)
		}
		return UIColor.clear
	}
}
