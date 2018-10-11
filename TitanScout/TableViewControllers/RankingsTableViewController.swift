//
//  RankingsTableViewController.swift
//  TitanScout
//
//  Created by Ian Fowler on 4/5/18.
//  Copyright © 2018 Ian Fowlercom.example. All rights reserved.
//

import UIKit

struct TeamData {
	var team:String
	var dataPoint:String
	var nishantNumber:Int
}

class RankingsTableViewController: UITableViewController, UISearchBarDelegate {

	@IBOutlet weak var search: UISearchBar!
	
//	var teams = [String]()
	var teams = ["2022","2481","2384","931","2022","2481","2384","931"]

	
	var filteredData = [TeamData]()
	var data = [TeamData]()
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		search.delegate = self
		
        // Uncomment the following line to preserve selection between presentations
//         self.clearsSelectionOnViewWillAppear = true

		//init toolbar
		let toolbar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))
		
		//create left side empty space so that done button set on right side
		let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
		let doneBtn: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction))
		toolbar.setItems([flexSpace, doneBtn], animated: false)
		toolbar.sizeToFit()
		//setting toolbar as inputAccessoryView
		search.inputAccessoryView = toolbar
		
		
		self.refreshControl?.addTarget(self, action:
			#selector(self.handleRefresh(_:)),
									   for: UIControlEvents.valueChanged)
		
		
		update()
		
		
    }
	
	@objc func handleRefresh(_ refreshControl: UIRefreshControl) {
		update()
		refreshControl.endRefreshing()
	}
	
	// This method updates filteredData based on the text in the Search Box
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		// When there is no text, filteredData is the same as the original data
		// When user has entered text into the search box
		// Use the filter method to iterate over all items in the data array
		// For each item, return true if the item should be included and false if the
		// item should NOT be included
		filteredData = searchText.isEmpty ? data : data.filter { (item: TeamData) -> Bool in
			// If dataItem matches the searchText, return true to include it
			
			return item.team.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
		}
		
		tableView.reloadData()
	}
	
	
	@objc func doneButtonAction() {
		self.view.endEditing(true)
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
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 83
	}
	
	
//
//	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//	}
//
//
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell:RankTableViewCell = tableView.dequeueReusableCell(withIdentifier: "RankTableViewCell")! as! RankTableViewCell
		
		if filteredData.count > indexPath.row {
			let m = filteredData[indexPath.row]
			
			cell.selectionStyle = .none
			
			cell.nameLabel.text = m.dataPoint
			
			cell.setCircleView(m.nishantNumber)
			if m.nishantNumber == 0 {
				cell.circleView.alpha = 0.3
			} else {
				cell.circleView.alpha = 1.0
			}
			cell.teamLabel.text = "Team \(m.team)"
		}
		return cell
	}
	
	@objc func update() {
		
		data = []
		
		for team in teams {
			Fetch().getNishantNumber(forTeam: team) { (num) -> () in
				self.data.append(TeamData(team: team, dataPoint: "", nishantNumber: num))
			}
		}
		
		let sortedArray = data.sorted { (obj1, obj2) -> Bool in
			return obj1.nishantNumber < obj2.nishantNumber
		}
		
		filteredData = sortedArray
		
		self.tableView.reloadData()
	}

}
