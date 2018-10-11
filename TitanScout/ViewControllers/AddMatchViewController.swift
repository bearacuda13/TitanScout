//
//  AddMatchViewController.swift
//  TitanScout
//
//  Created by Ian Fowler on 2/12/18.
//  Copyright © 2018 Ian Fowlercom.example. All rights reserved.
//

import UIKit

class AddMatchViewController: UIViewController {

	@IBOutlet weak var teamNumber: UITextField!
	@IBOutlet weak var matchNumber: UITextField!
	@IBOutlet weak var allianceSwitch: Switch!
	@IBOutlet weak var doneButton: UIBarButtonItem!
	@IBAction func donePressed(_ sender: Any) {
		let m = getMatch()
		if m.teamNumber.isEmpty && m.matchNumber.isEmpty{
			SCLAlertView().showError("Not so fast!", subTitle: "Make sure you fill out the team and match numbers.") // Error
		} else if m.teamNumber.isEmpty {
			SCLAlertView().showError("Not so fast!", subTitle: "Make sure you fill out the team number.") // Error
		} else if m.matchNumber.isEmpty{
			SCLAlertView().showError("Not so fast!", subTitle: "Make sure you fill out the match number.") // Error
		} else {
			navigationController?.popViewController(animated: true)
			dismiss(animated: true, completion: nil)
			shouldUpdateMatches = true
			Fetch().addMatch(m: m)
		}
	}
	
	func getMatch() -> Match {
		var alliance = allianceSwitch.leftText ?? ""
		if allianceSwitch.rightSelected {
			alliance = allianceSwitch.rightText ?? ""
		}
		return Match(teamNumber: teamNumber.text ?? "",
					 matchNumber: matchNumber.text ?? "",
					 alliance: alliance)
	}
	
	
	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
