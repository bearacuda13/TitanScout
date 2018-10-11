//
//  AutoMatchTableViewController.swift
//  TitanScout
//
//  Created by Ian Fowler on 3/25/18.
//  Copyright © 2018 Ian Fowlercom.example. All rights reserved.
//


import UIKit
import Firebase
import FirebaseDatabase
import fluid_slider

var alias = String(describing: UserDefaults.standard.object(forKey: "alias") ?? UIDevice.current.name.replacingOccurrences(of: "'s iPhone'", with: ""))

class AutoMatchTableViewController: UITableViewController, UISearchBarDelegate {
	@IBOutlet weak var searchBar: UISearchBar!
	
	var data = [MatchGroup]()
	var filteredData = [MatchGroup]()
	var t:MatchGroup?
	
	var refHandle: DatabaseHandle?

	
	@IBOutlet weak var nameLabel: UILabel!
	
	let slider = Slider()

	@IBAction func changeAlias(_ sender: Any) {
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
	
	func min() -> String {
		if filteredData.count > 0 {
			return filteredData[0].matchNumber
		}
		return ""
	}
	
	func max() -> String {
		if filteredData.count > 0 {
			return filteredData[filteredData.count - 1].matchNumber
		}
		return ""
	}
	
	func maxCGF() -> CGFloat {
		if filteredData.count > 0 {
			return CGFloat(Int(filteredData[filteredData.count - 1].matchNumber) ?? 0)
		}
		return 0.0
	}
	
	override func viewDidAppear(_ animated: Bool) {
		nameLabel.text = "Hello, I'm " + alias
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		
		nameLabel.text = "Hello, I'm " + alias
		
		
		Fetch().getMatchGroups() { (groups) -> () in
			self.data = groups
		}
		
		
		self.tableView.separatorStyle = .none
		
		
		filteredData = data
		
		self.refreshControl?.addTarget(self, action:
			#selector(self.handleRefresh(_:)),
									   for: UIControlEvents.valueChanged)
		
		if let r = ref {
			refHandle = r.child(accessKey).child("matches").observe(DataEventType.value, with: { (snapshot) in
				self.updateFromSnapshot(snapshot.value as? NSDictionary ?? NSDictionary())

			})
		}
		
		tableView.reloadData()
		
		/*
		slider.frame = CGRect(x: 5, y: 0, width: self.view.frame.width - 10, height: 45.0)
		
		slider.attributedTextForFraction = { fraction in
			let formatter = NumberFormatter()
			formatter.maximumIntegerDigits = 3
			formatter.maximumFractionDigits = 0
			let string = formatter.string(from: (fraction * self.maxCGF()) as NSNumber) ?? ""
			return NSAttributedString(string: string)
		}
		slider.setMinimumLabelAttributedText(NSAttributedString(string: min()))
		slider.setMaximumLabelAttributedText(NSAttributedString(string: max()))
		slider.fraction = 0.0
		slider.shadowOffset = CGSize(width: 0, height: 10)
		slider.shadowBlur = 5
		slider.shadowColor = UIColor(white: 0, alpha: 0.1)
		slider.contentViewColor = self.view.tintColor
		slider.valueViewColor = .white
		slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
		*/
	}
	
	
	
	@objc func sliderValueChanged() {
		
		
		if filteredData.count > 0 {
			let x = slider.fraction * maxCGF()
			var g = 0
			var distance = abs(CGFloat(Int(filteredData[0].matchNumber) ?? 0) - x)
			for group in 0..<filteredData.count {
				if distance > abs(CGFloat(Int(filteredData[group].matchNumber) ?? 0) - x) {
					distance = abs(CGFloat(Int(filteredData[group].matchNumber) ?? 0) - x)
					g = group
				}
			}
//			if g > 3 {
//				g = g - 2
//			}
			let indexPath = IndexPath(row: g, section: 0)
			tableView.scrollToRow(at: indexPath, at: .top, animated: true)


		}
	}
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		return UIView(frame: CGRect(x: 0.0, y:0.0, width:0.0, height: 0.0))
	}
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 0.0
	}
	
	
	func updateFromSnapshot(_ groups:NSDictionary) {
		
		var groupArray = [MatchGroup]()
		for match in groups {
			let matchNumber = String(describing: String(describing: match.key).dropFirst(6))
			if let matchDict = match.value as? NSDictionary {
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
				}
				
				groupArray.append(MatchGroup(matchNumber: matchNumber, matches: matchArray))
				
			}
		}
		
		data = groupArray
		
		let sortedArray = data.sorted { (obj1, obj2) -> Bool in
			if let one = Int(obj1.matchNumber) {
				if let two = Int(obj2.matchNumber) {
					return one < two
				}
			}
			return false
		}
		
		filteredData = sortedArray
		
		
//		slider.setMinimumLabelAttributedText(NSAttributedString(string: min()))
//		slider.setMaximumLabelAttributedText(NSAttributedString(string: max()))
		
		self.tableView.reloadData()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// MARK: - Table view data source
	
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
//		return filteredData.count
		return 1
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell:MatchProgressCell = tableView.dequeueReusableCell(withIdentifier: "MatchProgressCell")! as! MatchProgressCell
		
		let matchGroup = filteredData[indexPath.section]
		cell.setProgressIndicator(matchGroup)
		cell.selectionStyle = .none
		
		cell.teamLabel.text = "Match \(matchGroup.matchNumber)"
		
		return cell
	}
	
//	override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//
//		let tempContainer = UIView(frame: CGRect(x: 0, y:0, width: self.view.frame.width, height: 50))
//		tempContainer.addSubview(slider)
//		return tempContainer
//	}
	
	// set height for footer
//	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//		return 50
//	}
	
	override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
		let cell:MatchProgressCell = tableView.cellForRow(at: indexPath) as! MatchProgressCell
		cell.container.backgroundColor = UIColor.lightGray
		t = filteredData[indexPath.section]
		
		
//		self.performSegue(withIdentifier: "toChartsSegue", sender: self)
	}
	
	override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
		let cell:MatchProgressCell = tableView.cellForRow(at: indexPath) as! MatchProgressCell
		cell.container.backgroundColor = UIColor.white
		
	}
	
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 72
	}
	
	
	// This function is called before the segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		// get a reference to the second view controller
		let secondViewController = segue.destination as! StatsTableViewController
		
		// set a variable in the second view controller with the data to pass
		secondViewController.t = t
	}
	
	
	
	// This method updates filteredData based on the text in the Search Box
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		// When there is no text, filteredData is the same as the original data
		// When user has entered text into the search box
		// Use the filter method to iterate over all items in the data array
		// For each item, return true if the item should be included and false if the
		// item should NOT be included
		filteredData = searchText.isEmpty ? data : data.filter { (item: MatchGroup) -> Bool in
			// If dataItem matches the searchText, return true to include it
			
			return item.matchNumber.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
		}
		
		tableView.reloadData()
	}
	
	@objc func update() {
		Fetch().getMatchGroups() { (matchGroups) -> () in
			self.data = matchGroups
		}
		
		let sortedArray = data.sorted { (obj1, obj2) -> Bool in
			if let one = Int(obj1.matchNumber) {
				if let two = Int(obj2.matchNumber) {
					return one < two
				}
			}
			return false
		}
		
		filteredData = sortedArray
		
		
		
		self.tableView.reloadData()
	}
	
	@objc func handleRefresh(_ refreshControl: UIRefreshControl) {
		update()
		refreshControl.endRefreshing()
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return filteredData.count
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return filteredData[section].matchNumber
	}
	
	override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
		return filteredData.map { $0.matchNumber }
	}
	
	
}

