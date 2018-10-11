//
//  AutoMatchTableViewCell.swift
//  TitanScout
//
//  Created by Ian Fowler on 3/25/18.
//  Copyright © 2018 Ian Fowlercom.example. All rights reserved.
//

import UIKit
import UICircularProgressRing

class AutoMatchTableViewCell: UITableViewCell {
	
	@IBOutlet weak var container: UIView!
	@IBOutlet weak var teamLabel: UILabel!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var colorView: UIView!
	
	@IBOutlet weak var circleView: UICircularProgressRingView!
	
	
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
		container.layer.cornerRadius = 5.0
		circleView.valueIndicator = ""
		
	}
	func tapped() {
		container.backgroundColor = UIColor.lightGray
	}
	
	func setCircleView(_ num: Int) {
		circleView.setProgress(value: CGFloat(num), animationDuration: 0.3)
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		
		// Configure the view for the selected state
		
	}
	
}
