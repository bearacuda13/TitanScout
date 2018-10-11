//
//  ChartsViewController.swift
//  TitanScout
//
//  Created by Ian Fowler on 2/10/18.
//  Copyright © 2018 Ian Fowlercom.example. All rights reserved.
//

import UIKit

class ChartsViewController: UIViewController {

	@IBOutlet weak var navigation: UINavigationBar!
	
	@IBOutlet weak var colorView: UIView!
	
	@IBOutlet weak var scroll: UIScrollView!
	
	var team:Team?
	
	
	var showsAuto = true
	override func viewDidLoad() {
		super.viewDidLoad()
		
		
//		scroll.isScrollEnabled = true
		// Do any additional setup after loading the view.
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
	func cancel() {
		navigationController?.popViewController(animated: true)
		dismiss(animated: true, completion: nil)
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
