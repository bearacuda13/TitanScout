//
//  SegmentBit.swift
//  TitanScout
//
//  Created by Ian Fowler on 3/4/18.
//  Copyright © 2018 Ian Fowlercom.example. All rights reserved.
//

import UIKit

class SegmentBit: Bit, SJFluidSegmentedControlDataSource, SJFluidSegmentedControlDelegate {
	
	var values:[String]
	
	var mainSegment = TTSegmentedControl()
	
	// Define a lazy var
	lazy var segmentedControl: SJFluidSegmentedControl = {
		[unowned self] in
		// Setup the frame per your needs
		let segmentedControl = SJFluidSegmentedControl(frame: CGRect(x: 0, y: 30, width: self.frame.width, height: 38))
		segmentedControl.dataSource = self
		segmentedControl.selectorViewColor = UIColor().primaryColor()
		return segmentedControl
		}()
	
	override func draw(_ rect: CGRect) {
		self.addSubview(super.descriptionLabel)
		
//		mainSegment.didSelectItemWith = { (index, title) -> () in
//			super.update(title ?? "")
//		}
		
		segmentedControl.delegate = self
		segmentedControl.frame.size = CGSize(width: self.frame.width, height: 38.0)
		self.addSubview(segmentedControl)
		
		
	}
	
	
	init(key: String, title: String, titles:[String], preload:String?) {
		values = titles
		super.init(key: key, title:title)
		if let p = preload {
			segmentedControl.setCurrentSegmentIndex(values.index(of: p) ?? 0, animated: false)
		}
		if segmentedControl.currentSegment < values.count {
			super.update(values[segmentedControl.currentSegment])
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		values = [String]()
		super.init(key: "", title: "")
		super.update(values[0])
	}
	
	
	// Don't forget to implement the required data source method
	func numberOfSegmentsInSegmentedControl(_ segmentedControl: SJFluidSegmentedControl) -> Int {
		return values.count
	}
	
	func segmentedControl(_ segmentedControl: SJFluidSegmentedControl, titleForSegmentAtIndex index: Int) -> String? {
		return values[index]
	}
	
	func segmentedControl(_ segmentedControl: SJFluidSegmentedControl, titleColorForSelectedSegmentAtIndex index: Int) -> UIColor {
		return UIColor.white
	}
	
	func segmentedControl(_ segmentedControl: SJFluidSegmentedControl, didChangeFromSegmentAtIndex fromIndex: Int, toSegmentAtIndex toIndex: Int) {
		super.update(values[toIndex])
	}
	
	
	
}


