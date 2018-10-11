//
//  MatchesTableViewController.swift
//  
//
//  Created by Ian Fowler on 2/7/18.
//

import UIKit

var shouldUpdateMatches = true

class MatchesTableViewController: UITableViewController, UISearchBarDelegate {

	@IBOutlet weak var searchBar: UISearchBar!
	var data = [Match]()
	var filteredData = [Match]()
	var m:Match?
	
	override func viewDidAppear(_ animated: Bool) {
		if shouldUpdateMatches {
			update()
			shouldUpdateMatches = false
		}
		for cell in tableView.visibleCells {
			if let c = cell as? MatchTableViewCell {
				c.container.backgroundColor = UIColor.white
			}
		}
	}
	
	
	@objc func update() {
		Fetch().getMatches() { (matches) -> () in
			self.data = matches
		}
		filteredData = data
		
		let sortedArray = filteredData.sorted { (obj1, obj2) -> Bool in
			if let one = Int(obj1.matchNumber) {
				if let two = Int(obj2.matchNumber) {
					return one > two
				}
			}
			return false
		}
		
		filteredData = sortedArray
		
		self.tableView.reloadData()
	}
	

	var oneTimer = Timer()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		
		self.tableView.separatorStyle = .none
		
		searchBar.delegate = self
		
		filteredData = data
		
		self.refreshControl?.addTarget(self, action:
			#selector(self.handleRefresh(_:)),
								 for: UIControlEvents.valueChanged)
		//init toolbar
		let toolbar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))
		
		//create left side empty space so that done button set on right side
		let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
		let doneBtn: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction))
		toolbar.setItems([flexSpace, doneBtn], animated: false)
		toolbar.sizeToFit()
		//setting toolbar as inputAccessoryView
		searchBar.inputAccessoryView = toolbar
		
		oneTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update), userInfo: nil, repeats: false)

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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell:MatchTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MatchCell")! as! MatchTableViewCell
		let matches = filteredData
		let match = matches[indexPath.row]
		
		cell.selectionStyle = .none
		
		cell.teamLabel.text = "Team \(match.teamNumber)"
		cell.matchLabel.text = "Match \(match.matchNumber)"
		if let alliance = match.alliance {
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
	
	@objc private func tapGestureHandler() {
		view.endEditing(true)
	}
	
	override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
		let cell:MatchTableViewCell = tableView.cellForRow(at: indexPath) as! MatchTableViewCell
		cell.container.backgroundColor = UIColor.lightGray
		m = filteredData[indexPath.row]
		self.performSegue(withIdentifier: "toEditSegue", sender: self)
	}
	
	override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
		if let cell:MatchTableViewCell = tableView.cellForRow(at: indexPath) as? MatchTableViewCell {
			cell.container.backgroundColor = UIColor.white
		}
	}
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		searchBar.resignFirstResponder() // hides the keyboard.
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 82 
	}
	
	// This function is called before the segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		var id = ""
		if let identifier = segue.identifier {
			id = identifier
		}
		if id  == "toEditSegue" {
			// get a reference to the second view controller
			let secondViewController = segue.destination as! EditViewController
		
			// set a variable in the second view controller with the data to pass
			secondViewController.match = m
		}
	}
	
	// This method updates filteredData based on the text in the Search Box
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		filteredData = searchText.isEmpty ? data : data.filter { (item: Match) -> Bool in
			return (item.matchNumber + "-" + item.teamNumber).range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
		}
		
		
		let sortedArray = filteredData.sorted { (obj1, obj2) -> Bool in
			if let one = Int(obj1.matchNumber) {
				if let two = Int(obj2.matchNumber) {
					return one > two
				}
			}
			return false
		}
		
		filteredData = sortedArray
		tableView.reloadData()
	}
	
	@objc func handleRefresh(_ refreshControl: UIRefreshControl) {
		update()
		refreshControl.endRefreshing()
	}
}
