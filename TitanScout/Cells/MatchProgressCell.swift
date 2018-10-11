//
//  MatchProgressCell.swift
//  TitanScout
//
//  Created by Ian Fowler on 3/25/18.
//  Copyright © 2018 Ian Fowlercom.example. All rights reserved.
//

import UIKit


class MatchProgressCell: UITableViewCell {
	
	@IBOutlet weak var container: UIView!
	@IBOutlet weak var teamLabel: UILabel!
	
	@IBOutlet weak var progressCell: VerticalProgressView!
	@IBOutlet weak var progressLabel: UILabel!
	
	func setProgressIndicator(_ matchGroup: MatchGroup) {
		var count = 0
		for m in matchGroup.matches {
			if m.takenBy == "Open" {
				count += 1
			}
		}
		let percent = CGFloat(count) / CGFloat(matchGroup.matches.count)
		progressCell.setProgress(progress: 1.0 - Float(percent), animated: true)
		progressLabel.text = "\(6-count) of 6"
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
		container.layer.cornerRadius = 5.0
		
	}
	func tapped() {
		container.backgroundColor = UIColor.lightGray
	}
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		
		// Configure the view for the selected state
		
	}
	
}
