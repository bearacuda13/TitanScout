//
//  Fetch.swift
//  TitanScout
//
//  Created by Ian Fowler on 2/7/18.
//  Copyright © 2018 Ian Fowlercom.example. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SigmaSwiftStatistics

struct MatchGroup {
	var matchNumber:String
	var matches:[MatchSelect]
}

struct MatchSelect {
	var match:Match
	var takenBy:String
}

struct Match {
	var teamNumber:String
	var matchNumber:String
	var alliance:String?
}


struct Team {
	var teamNumber:String
}

var info = [String:String]()

var ref: DatabaseReference!

var accessKey = "DataForTeam2022"

class Fetch {
	func initDB() {
		ref = Database.database().reference()
	}
	func getMatches(completion: @escaping ([Match]) -> ()) {
		if let r = ref {
			r.child(accessKey).child("teams").observeSingleEvent(of: .value, with: { (snapshot) in
				// Get user value
				if let teams = snapshot.value as? NSDictionary {
					var matchesArray = [Match]()
					for team in teams {
						if let teamDict  = team.value as? NSDictionary {
							for match in teamDict {
								let teamKey = String(describing: team.key)
								if let tInd = teamKey.index(of: "-") {
									if let mInd = String(describing: match.key).index(of: "-") {
										matchesArray.append(Match(
											teamNumber: String(describing: teamKey[tInd...].dropFirst()),
											matchNumber: String(describing: String(describing: match.key)[mInd...].dropFirst()),
											alliance: nil
										))
									}
								}
							}
						}
					}
					completion(matchesArray)
				}
			}) { (error) in
				print(error.localizedDescription)
				completion([Match]())
			}
		}
	}
	
	func addMatch(m:Match) {
		if let r = ref {
			r.child(accessKey).child("teams").child("team-\(m.teamNumber)").setValue("match-"+String(describing: m.matchNumber))
		}
	}
	
	func getTeams(completion: @escaping ([Team]) -> ()){
		if let r = ref {
			r.child(accessKey).child("teams").observeSingleEvent(of: .value, with: { (snapshot) in
				// Get user value
				if let teams = snapshot.value as? NSDictionary {
					var teamArray = [Team]()
					for team in teams {
						let teamKey = String(describing: team.key)
						if let ind = teamKey.index(of: "-") {
							teamArray.append(Team(teamNumber: String(teamKey[ind...].dropFirst())))
						}
					}
					completion(teamArray)
				} else {
					completion([Team]())
				}
				
			}) { (error) in
				print(error.localizedDescription)
				completion([Team]())
			}
		}
	}
	
	func getStatForTeam(team: String, key: String, completion: @escaping ([String]) -> ()){
		if let r = ref {
			r.child(accessKey).child("teams").child("team-"+team).observeSingleEvent(of: .value, with: { (snapshot) in
				// Get user value
				if let teams = snapshot.value as? NSDictionary {
					var valueArray = [String]()
					for match in teams {
						if let m = match.value as? NSDictionary {
							for uniqueID in m {
								if let u = uniqueID.value as? NSDictionary {
									if let v = u.value(forKey: key) {
										valueArray.append(String(describing: v))
									}
								}
							}
						}
					}
					completion(valueArray)
				}
				
			}) { (error) in
				print(error.localizedDescription)
			}
		}
	}
	
	func getStatsForTeam(team: String, keyArray: [String], completion: @escaping ([String:[String]]) -> ()){
		if let r = ref {
			r.child(accessKey).child("teams").child("team-"+team).observeSingleEvent(of: .value, with: { (snapshot) in
				// Get user value
				if let teams = snapshot.value as? NSDictionary {
					var valueDict = [String:[String]]()
					for match in teams {
						if let m = match.value as? NSDictionary {
							for uniqueID in m {
								if let u = uniqueID.value as? NSDictionary {
									for key in keyArray {
										if let v = u.value(forKey: key) {
											if let _ = valueDict[key]  {
											} else {
												valueDict[key] = [String]()
											}
											valueDict[key]!.append(String(describing: v))
										}
									}
								}
							}
						}
					}
					completion(valueDict)
				}
				
			}) { (error) in
				print(error.localizedDescription)
			}
		}
	}
	
	
	func getStatsForAllTeams(keyArray: [String], completion: @escaping ([String:[String:[String]]]) -> ()){
		if let r = ref {
			r.child(accessKey).child("teams").observeSingleEvent(of: .value, with: { (snapshot) in
				// Get user value
				if let t = snapshot.value as? NSDictionary {
					var masterDict = [String:[String:[String]]]()
					for val in t {
						if let teams = val.value as? NSDictionary {
							var valueDict = [String:[String]]()
							for match in teams {
								if let m = match.value as? NSDictionary {
									for uniqueID in m {
										if let u = uniqueID.value as? NSDictionary {
											for key in keyArray {
												if let v = u.value(forKey: key) {
													if let _ = valueDict[key]  {
													} else {
														valueDict[key] = [String]()
													}
													valueDict[key]!.append(String(describing: v))
												}
											}
										}
									}
								}
							}
							if let teamKey = val.key as? String {
								if let ind = teamKey.index(of: "-") {
									masterDict[String(teamKey[ind...].dropFirst())] = valueDict
								}
							}
						}
					}
					completion(masterDict)
				}
			}) { (error) in
				print(error.localizedDescription)
			}
		}
	}
	
	func getMatchGroups(completion: @escaping ([MatchGroup]) -> ()){
		if let r = ref {
			r.child(accessKey).child("matches").observeSingleEvent(of: .value, with: { (snapshot) in
				// Get user value
				
				if let groups = snapshot.value as? NSDictionary {
					
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
										takenBy: self.getDescription(from: team.value as? NSArray ?? NSArray()))
									)
								}
							}
							
							groupArray.append(MatchGroup(matchNumber: matchNumber, matches: matchArray))
							
						}
					}
					completion(groupArray)
				} else {
					completion([MatchGroup]())
				}
				
			}) { (error) in
				print(error.localizedDescription)
				completion([MatchGroup]())
			}
		}
	}
	
	func getDescription(from: NSArray) -> String {
		var d = ""
		if let arr = from as? [String] {
			if arr.count <= 1 && arr[0].isEmpty {
				return "Open"
			}
			d += "Covered by " + arr[0]
			if arr.count == 1 {
				return d
			}
			if arr.count == 2 {
				return d + " and " + arr[1]
			}
			for name in arr {
				d += ", " + name
			}
			return d.replacingLastOccurrenceOfString(", ", with: ", and ")
		}
		return ""
	}
	
	func signUp(match: String, team: String, alliance: String, name:String) {
		if let r = ref {
			r.child(accessKey).child("matches").child("match-"+match).child(team + "-" + alliance).observeSingleEvent(of: .value, with: { (snapshot) in
				// Get user value
				if let groups = snapshot.value as? NSArray {
					if !groups.contains(name) {
						if groups.count == 1 && groups.contains("") {
							r.child(accessKey).child("matches").child("match-"+match).child(team + "-" + alliance).setValue(NSArray().plus(name))
						} else {
							r.child(accessKey).child("matches").child("match-"+match).child(team + "-" + alliance).setValue(groups.plus(name))
						}
					}
				}
			})
		}
	}
	
	
	func userHasFilledOut(team: String, match: String, completion: @escaping (Bool?) -> ()){
		if let r = ref {
			r.child(accessKey).child("teams").child("team-"+team).child("match-"+match).observeSingleEvent(of: .value, with: { (snapshot) in
				
				let result = snapshot.hasChild(UIDevice.current.identifierForVendor!.uuidString)
				completion(result)
				return
			})
			return
		}
		completion(nil)
	}
	
	
	func getPreloadValueFor(team: String, match: String, key: String, completion: @escaping (String?) -> ()){
		if let r = ref {	r.child(accessKey).child("teams").child("team-"+team).child("match-"+match).child(UIDevice.current.identifierForVendor!.uuidString).child(key).observeSingleEvent(of: .value, with: { (snapshot) in
				completion(String(describing: snapshot.value ?? ""))
				return
			})
			return
		}
		completion(nil)
	}
	func getPreloadValues(team: String, match: String, completion: @escaping (NSDictionary?) -> ()){
		if let r = ref {	r.child(accessKey).child("teams").child("team-"+team).child("match-"+match).child(UIDevice.current.identifierForVendor!.uuidString).observeSingleEvent(of: .value, with: { (snapshot) in
			completion(snapshot.value as? NSDictionary)
			return
		})
			return
		}
		completion(nil)
	}
	
	func dropOut(match: String, team: String, alliance: String, name:String) {
		Fetch().userHasFilledOut(team: team, match: match) { (shouldExit) -> () in
			if !(shouldExit ?? true) {
				if let r = ref {
					r.child(accessKey).child("matches").child("match-"+match).child(team + "-" + alliance).observeSingleEvent(of: .value, with: { (snapshot) in
						// Get user value
						if let groups = snapshot.value as? NSArray {
							let sub = groups.without(name)
							if sub.count == 0 {
								r.child(accessKey).child("matches").child("match-"+match).child(team + "-" + alliance).setValue(NSArray().plus(""))
							} else {
								r.child(accessKey).child("matches").child("match-"+match).child(team + "-" + alliance).setValue(sub)
							}
						}
					})
				}
			}
		}
	}
	
	func getInfo(_ withChild: String, completion: @escaping (NSDictionary) -> ()) {
		if let r = ref {
			r.child(accessKey).child("appStructure").child(withChild).observeSingleEvent(of: .value, with: { (snapshot) in
				if let v = snapshot.value {
					completion(v as! NSDictionary)
				} else {
					completion(NSDictionary())
				}
			})
		} else {
			completion(NSDictionary())
		}
	}
	
	func submit(_ m:Match) {
		info["scout-alias"] = alias
		if let r = ref {
			r.child(accessKey).child("teams").child("team-\(m.teamNumber)").child("match-"+String(describing: m.matchNumber)).child(UIDevice.current.identifierForVendor!.uuidString).setValue(info)
		}
		info = [String:String]()
	}
	
	func max(_ array:[String]?) -> Double {
		if let a = array {
			return Sigma.max(a.map{Double($0) ?? 0.0}) ?? 0.0
		}
		return 0.0
	}
	
	func ave(_ array:[String]?) -> Double {
		if let a = array {
			return Sigma.average(a.map{Double($0) ?? 0.0}) ?? 0.0
		}
		return 0.0
	}
	
	func sum(_ array:[String]?) -> Double {
		if let a = array {
			return Sigma.sum(a.map{Double($0) ?? 0.0})
		}
		return 0.0
	}
	
	func yesNoCount(_ array:[String]?) -> Double {
		let yesNoDict = ["No":0, "Yes":1]
		if let a = array {
			return Sigma.sum(a.map{Double(yesNoDict[$0] ?? 0)})
		}
		return 0.0
	}
	
	func getNishantNumber(forTeam: String, completion: @escaping (Int) -> ()) {
				
		getStatsForAllTeams(keyArray: ["unsuccessfulScaleBoxesAuto","unsuccessfulSwitchBoxesAuto","unsuccessfulScaleBoxesTeleop","unsuccessfulSwitchBoxesTeleop","successfulScaleBoxesAuto","successfulSwitchBoxesAuto","successfulScaleBoxesTeleop","successfulSwitchBoxesTeleop","vaultBoxes","climbSuccess","crossLine","climberType","scout-alias"]) { (dict) -> () in
			
			var teamScores = [String:Int]()
			
			var allTeamDict = [String:[String]]()
			
			for team in dict.values {
				for value in team {
					if let _ = allTeamDict[value.key] {
						allTeamDict[value.key]! += value.value
					} else {
						allTeamDict[value.key] = value.value
					}
				}
			}
			
			var teamNormalDistributions = [String:Double]()
			
			
			for team in Array(dict.keys) {
				let nn = self.computeNishantNumber(forTeam: team, dict: dict, allTeamDict: allTeamDict)
				if nn > 0 {
					teamScores[team] = nn
				}
			}
			
			let nishantNumbers:[Double] = Array(teamScores.values).map { Double($0) }
			
			for team in Array(dict.keys) {
				if let a = Sigma.average(nishantNumbers) {
					if let sd = Sigma.standardDeviationPopulation(nishantNumbers) {
						teamNormalDistributions[team] = Sigma.normalDistribution(x: Double(teamScores[team] ?? 0), μ: a, σ: sd)
					}
				}
			}
			
			completion(Int((teamNormalDistributions[forTeam] ?? 0) * 100.0))
			
		}
		
		
		
	}
	
	func computeNishantNumber(forTeam: String, dict: [String:[String:[String]]], allTeamDict:[String:[String]]) -> Int {
		
		var nishantNumber:Double = 0.0
		let maxTeleopScaleBoxesAllTeams:Double = self.max(allTeamDict["successfulScaleBoxesTeleop"])
		let maxTeleopSwitchBoxesAllTeams:Double = self.max(allTeamDict["successfulSwitchBoxesTeleop"])
		let maxVaultBoxesAllTeams:Double = self.max(allTeamDict["vaultBoxes"])
		let maxAutoScaleBoxesAllTeams:Double = self.max(allTeamDict["successfulScaleBoxesAuto"])
		let maxAutoSwitchBoxesAllTeams:Double = self.max(allTeamDict["successfulSwitchBoxesAuto"])
		
		var singleTeamDict = [String:[String]]()
		if let d = dict[forTeam] {
			singleTeamDict = d
		}
		
		
		//		Average Auto Scale Boxes (Team)
		let averageAutoScaleBoxesTeam:Double = self.ave(singleTeamDict["successfulScaleBoxesAuto"])
		let averageAutoSwitchBoxesTeam:Double = self.ave(singleTeamDict["successfulSwitchBoxesAuto"])
		let averageTeleopScaleBoxesTeam:Double = self.ave(singleTeamDict["successfulScaleBoxesTeleop"])
		let averageTeleopSwitchBoxesTeam:Double = self.ave(singleTeamDict["successfulSwitchBoxesTeleop"])
		let averageTeleopVaultBoxesTeam:Double = self.ave(singleTeamDict["vaultBoxes"])
		let successfulClimbsTeam:Double = self.yesNoCount(singleTeamDict["climbSuccess"])
		
		//		Number of Matches (Team)
		var numberOfMatchesTeam:Double = 0.0
		if let a = singleTeamDict["scout-alias"] {
			numberOfMatchesTeam = Double(a.count)
		}
		
		let autoLineCrossesTeam:Double = self.yesNoCount(singleTeamDict["crossLine"])
		
		
		if (maxAutoScaleBoxesAllTeams + maxAutoSwitchBoxesAllTeams) != 0 {
			nishantNumber += 25.0 * (averageAutoScaleBoxesTeam + averageAutoSwitchBoxesTeam) / (maxAutoScaleBoxesAllTeams + maxAutoSwitchBoxesAllTeams)
		}
		if (maxTeleopScaleBoxesAllTeams + maxTeleopSwitchBoxesAllTeams + maxVaultBoxesAllTeams) != 0 {
			nishantNumber += 50.0 * (averageTeleopScaleBoxesTeam + averageTeleopSwitchBoxesTeam + averageTeleopVaultBoxesTeam) / (maxTeleopScaleBoxesAllTeams + maxTeleopSwitchBoxesAllTeams + maxVaultBoxesAllTeams)
		}
		nishantNumber += 15.0 * (successfulClimbsTeam + numberOfMatchesTeam)
		nishantNumber += 10.0 * (autoLineCrossesTeam + numberOfMatchesTeam)
		
		var shouldPerformExtraWeight = false
		if let a = singleTeamDict["climberType"] {
			for ct in a {
				if ct == "Ramp" {
					shouldPerformExtraWeight = true
				}
			}
		}
		
		if numberOfMatchesTeam != 0 {
			if successfulClimbsTeam / numberOfMatchesTeam > 0.8 {
				shouldPerformExtraWeight = true
			}
		}
		if shouldPerformExtraWeight {
			let successfulBoxes = self.sum(singleTeamDict["successfulScaleBoxesAuto"]) + self.sum(singleTeamDict["successfulSwitchBoxesAuto"]) + self.sum(singleTeamDict["successfulScaleBoxesTeleop"]) + self.sum(singleTeamDict["successfulSwitchBoxesTeleop"])
			let unsuccessfulBoxes = self.sum(singleTeamDict["unsuccessfulScaleBoxesAuto"]) + self.sum(singleTeamDict["unsuccessfulSwitchBoxesAuto"]) + self.sum(singleTeamDict["unsuccessfulScaleBoxesTeleop"]) + self.sum(singleTeamDict["unsuccessfulSwitchBoxesTeleop"])
			
			nishantNumber = (nishantNumber * 0.7) + (successfulBoxes / (successfulBoxes + unsuccessfulBoxes))
		}
		
		if numberOfMatchesTeam == 0.0 {
			nishantNumber = 0
		}
		
		guard !(nishantNumber.isNaN || nishantNumber.isInfinite) else {
			return 0 // or do some error handling
		}
		
		return Int(nishantNumber)
		
	}
	
	func getStarNumber(forTeam: String, completion: @escaping (Int) -> ()) {
		getStatForTeam(team: forTeam, key: "starRating") { (result) -> () in
			completion(Int(Sigma.average(result.map{Double($0) ?? 0.0}) ?? 0.0))
		}
	}
	
}



extension UIColor {
	func primaryColor() -> UIColor {
		return "7CD3F7".toUIColor()
	}
	func darkenedPrimaryColor() -> UIColor {
		return "277FBC".toUIColor()
	}
}

extension String {
	func replacingLastOccurrenceOfString(_ searchString: String,
										 with replacementString: String,
										 caseInsensitive: Bool = true) -> String {
		let options: String.CompareOptions
		if caseInsensitive {
			options = [.backwards, .caseInsensitive]
		} else {
			options = [.backwards]
		}
		
		if let range = self.range(of: searchString,
								  options: options,
								  range: nil,
								  locale: nil) {
			
			return self.replacingCharacters(in: range, with: replacementString)
		}
		return self
	}
}

extension NSArray {
	func without(_ obj: Any) -> NSArray {
		let arr:NSMutableArray = self as? NSMutableArray ?? NSMutableArray()
		let index = arr.index(of: obj)
		if index > -1 {
			arr.removeObject(at: index)
		}
		return arr as NSArray
	}
	func plus(_ obj: Any) -> NSArray {
		let arr:NSMutableArray = self as? NSMutableArray ?? NSMutableArray()
		arr.add(obj)
		return arr as NSArray
	}
}
