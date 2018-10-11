//
//  StatsTableViewController.swift
//  TitanScout
//
//  Created by Ian Fowler on 2/10/18.
//  Copyright © 2018 Ian Fowlercom.example. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class StatsTableViewController: UITableViewController {
	
	var data = [MatchSelect]()
	var filteredData = [MatchSelect]()
	var t:MatchGroup?
	var m:Match?
	
	var statsRefHandle: DatabaseHandle?


	@IBOutlet weak var nameLabel: UILabel!
	
	@IBAction func aliasChange(_ sender: Any) {
		// Add a text field
		let alert = SCLAlertView()
		let txt = alert.addTextField("Enter your name")
		alert.addButton("Change Name") {
			alias = txt.text ?? alias
			self.nameLabel.text = "Hello, I'm " + alias
			UserDefaults.standard.set(alias, forKey: "alias")
			
		}
		alert.showEdit("Edit Name", subTitle: "Right now, you're " + alias, closeButtonTitle: "I'm good with " + alias)

	}
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationItem.title = "Match \(t?.matchNumber ?? "")"
		
		self.tableView.separatorStyle = .none
		
		nameLabel.text = "Hello, I'm " + alias

		
		
		if let r = ref {
			if let x = t {
				statsRefHandle = r.child(accessKey).child("matches").child("match-" + x.matchNumber).observe(DataEventType.value, with: { (snapshot) in
					
					self.update(snapshot.value as? NSDictionary ?? NSDictionary(), matchNumber: x.matchNumber)

				})
			}
		}
		
		
		// Uncomment the following line to preserve selection between presentations
		// self.clearsSelectionOnViewWillAppear = false
		
		// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
		// self.navigationItem.rightBarButtonItem = self.editButtonItem
		
		
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		// #warning Incomplete implementation, return the number of sections
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
		return filteredData.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell:AutoMatchTableViewCell = tableView.dequeueReusableCell(withIdentifier: "AutoMatchTableViewCell")! as! AutoMatchTableViewCell
		let m = filteredData[indexPath.row]
		
		
		cell.selectionStyle = .none
		
		cell.nameLabel.text = m.takenBy
		
		Fetch().getNishantNumber(forTeam: m.match.teamNumber) { (num) -> () in
			cell.setCircleView(num)
			if num == 0 {
				cell.circleView.alpha = 0.3
			} else {
				cell.circleView.alpha = 1.0
			}
		}
		
		
		
		cell.teamLabel.text = "Team \(m.match.teamNumber)"
		if let alliance = m.match.alliance {
			if alliance.uppercased().trimmingCharacters(in: .whitespaces) == "RED" {
				cell.colorView.backgroundColor = UIColor.red
			} else if alliance.uppercased().trimmingCharacters(in: .whitespaces) == "BLUE" {
				cell.colorView.backgroundColor = UIColor.blue
			} else {
				cell.colorView.backgroundColor = UIColor.white
			}
		}
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
		let cell:AutoMatchTableViewCell = tableView.cellForRow(at: indexPath) as! AutoMatchTableViewCell
		cell.container.backgroundColor = UIColor.lightGray
		m = filteredData[indexPath.row].match
		
		//		self.performSegue(withIdentifier: "toChartsSegue", sender: self)

	}
	
	
	override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
		let cell:AutoMatchTableViewCell = tableView.cellForRow(at: indexPath) as! AutoMatchTableViewCell
		cell.container.backgroundColor = UIColor.white
		
	}
	
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 77
	}
	
	
	// This function is called before the segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// get a reference to the second view controller
		let secondViewController = segue.destination as! EditViewController
		
		// set a variable in the second view controller with the data to pass
		secondViewController.match = m
		
		Fetch().signUp(match: m?.matchNumber ?? "", team: m?.teamNumber ?? "", alliance: m?.alliance ?? "", name: alias)
		
	}
	
	func update(_ matchDict : NSDictionary, matchNumber:String) {

		
		var matchArray = [MatchSelect]()
		
		
		for team in matchDict {
			let teamKey = String(describing: team.key)
			if let ind = teamKey.index(of: "-") {
				
				matchArray.append(
					MatchSelect(match: Match(
						teamNumber: String(describing: teamKey[..<ind]),
						matchNumber: matchNumber,
						alliance: String(describing: teamKey[ind...].dropFirst())
						),
								takenBy: Fetch().getDescription(from: team.value as? NSArray ?? NSArray()))
				)
			}
			
			t = MatchGroup(matchNumber: matchNumber, matches: matchArray)
			
		}
		
		
		data = t?.matches ?? []
		
		let sortedArray = data.sorted { (obj1, obj2) -> Bool in
			if let alliance1 = obj1.match.alliance {
				if let alliance2 = obj2.match.alliance {
					if alliance1.lowercased() != alliance2.lowercased() {
						return alliance1.lowercased() == "red"
					}
				}
			}
			if let one = Int(obj1.match.teamNumber) {
				if let two = Int(obj2.match.teamNumber) {
					return one < two
				}
			}
			return false
		}
		filteredData = sortedArray
		
		tableView.reloadData()
	}
	
	
	override func viewDidAppear(_ animated: Bool) {
		print("Stats did appear")
		tableView.reloadData()
	}
	
}

