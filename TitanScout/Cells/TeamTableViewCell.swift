//
//  MatchTableViewCell.swift
//  TitanScout
//
//  Created by Ian Fowler on 2/7/18.
//  Copyright © 2018 Ian Fowlercom.example. All rights reserved.
//

import UIKit

class TeamTableViewCell: UITableViewCell {

	@IBOutlet weak var container: UIView!
	@IBOutlet weak var teamLabel: UILabel!
	@IBOutlet weak var colorView: UIView!
	
	
	
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
