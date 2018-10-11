//
//  EditViewController.swift
//  TitanScout
//
//  Created by Ian Fowler on 2/7/18.
//  Copyright © 2018 Ian Fowlercom.example. All rights reserved.
//

import UIKit

class EditViewController: UIViewController, UITabBarControllerDelegate {

	@IBOutlet weak var navigation: UINavigationBar!
	
	@IBOutlet weak var colorView: UIView!
	@IBOutlet weak var segmentedAutoTeleop: UISegmentedControl!
	
	@IBOutlet weak var scroll: UIScrollView!
	
	private var inputToolbar: UIView!
	private var notesTextView: GrowingTextView!
	private var textViewBottomConstraint: NSLayoutConstraint!
	
	let teleopView = UIView()
	let autoView = UIView()
	let summaryView = UIView()
	
	var match:Match?
	
	let heightConstant = 84
	
	func setupAutoTeleop() {
		if let m = match {
			Fetch().getPreloadValues(team: m.teamNumber, match: m.matchNumber) { (preloads) -> () in
				Fetch().getInfo("auto") { (dict) -> () in
					self.autoView.process(withInstructions: dict, withPreloads: preloads, team: m.teamNumber, match: m.matchNumber)
				}
				Fetch().getInfo("teleop") { (dict) -> () in
					self.teleopView.process(withInstructions: dict, withPreloads: preloads, team: m.teamNumber, match: m.matchNumber)
				}
				Fetch().getInfo("summary") { (dict) -> () in
					self.summaryView.process(withInstructions: dict, withPreloads: preloads, team: m.teamNumber, match: m.matchNumber)
				}
				
				// while we're at it, update the notes preload
				if let notesPreload = preloads?.valFor("notes") {
					self.notesTextView.text = notesPreload
					info["notes"] = notesPreload
				}
				
			}
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		updateView()
	}
	
	// UITabBarControllerDelegate
	func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
		print("Tab bar")
	}
	
	
	override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
		print("Edit")
		return false
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		let vf = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
		teleopView.frame = vf
		autoView.frame = vf
		summaryView.frame = vf
		
		setupAutoTeleop()
		
		super.tabBarController?.delegate = self

		self.navigationItem.hidesBackButton = true
		let newBackButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(EditViewController.back(sender:)))
		self.navigationItem.leftBarButtonItem = newBackButton
		
//		textView.contentInsetAdjustmentBehavior = .never

		if let m = match {
			self.title = "Team \(m.teamNumber) Match \(m.matchNumber)"
			if let alliance = m.alliance {
				if alliance.uppercased().trimmingCharacters(in: .whitespaces) == "RED" {
					colorView.backgroundColor = UIColor.red
				} else if alliance.uppercased().trimmingCharacters(in: .whitespaces) == "BLUE" {
					colorView.backgroundColor = UIColor.blue
				} else {
					colorView.backgroundColor = UIColor.clear
				}
			}
		}
		
		scroll.isScrollEnabled = true
		
        // Do any additional setup after loading the view.
		
		setupNotes()
		

		let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
		swipeRight.direction = UISwipeGestureRecognizerDirection.right
		segmentedAutoTeleop.addGestureRecognizer(swipeRight)

		let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
		swipeLeft.direction = UISwipeGestureRecognizerDirection.left
		segmentedAutoTeleop.addGestureRecognizer(swipeLeft)

		updateView()
		
		segmentedAutoTeleop.tintColor = UIColor().darkenedPrimaryColor()
		
		info.updateValue(notesTextView.text, forKey: "notes")
		
    }
	
	@objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
		if let swipeGesture = gesture as? UISwipeGestureRecognizer {
			switch swipeGesture.direction {
			case UISwipeGestureRecognizerDirection.left:
				if segmentedAutoTeleop.selectedSegmentIndex > 0 {
					segmentedAutoTeleop.selectedSegmentIndex = segmentedAutoTeleop.selectedSegmentIndex - 1
					segmentedAutoTeleop.sendActions(for: .valueChanged)
				}
				
			case UISwipeGestureRecognizerDirection.right:
				if segmentedAutoTeleop.selectedSegmentIndex < segmentedAutoTeleop.numberOfSegments - 1 {
					segmentedAutoTeleop.selectedSegmentIndex = segmentedAutoTeleop.selectedSegmentIndex + 1
					segmentedAutoTeleop.sendActions(for: .valueChanged)
				}
				
			default:
				break
			}
		}
	}
	
	
	@objc func back(sender: UIBarButtonItem) {
		// Perform your custom actions
		// ...
		// Go back to the previous ViewController
		
		notesTextView.resignFirstResponder()
		
		let alertView = SCLAlertView()
		alertView.addButton("Don't Save") {
			_ = self.navigationController?.popViewController(animated: true)
			if super.tabBarController?.selectedIndex == 0 {
				Fetch().dropOut(match: self.match?.matchNumber ?? "", team: self.match?.teamNumber ?? "", alliance: self.match?.alliance ?? "", name: alias)
			} 
		}
		alertView.showError(
			"Continue without saving?",
			subTitle: "Going back erases any new changes to the data you've filled out.",
			closeButtonTitle: "Cancel"
		)
		
		
	}
	
	func setupNotes() {
		
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
		
		// *** Create Toolbar
		inputToolbar = UIView()
		inputToolbar.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
		inputToolbar.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(inputToolbar)
		
		// *** Create GrowingTextView ***
		notesTextView = GrowingTextView()
		notesTextView.delegate = self
		notesTextView.layer.cornerRadius = 4.0
		notesTextView.maxHeight = 70
		notesTextView.trimWhiteSpaceWhenEndEditing = true
		notesTextView.placeholder = "Edit notes..."
		notesTextView.placeholderColor = UIColor(white: 0.8, alpha: 1.0)
		notesTextView.font = UIFont.systemFont(ofSize: 15)
		notesTextView.translatesAutoresizingMaskIntoConstraints = false
		inputToolbar.addSubview(notesTextView)
		
		// *** Autolayout ***
		NSLayoutConstraint.activate([
			inputToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			inputToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			inputToolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			notesTextView.topAnchor.constraint(equalTo: inputToolbar.topAnchor, constant: 8),
			])
		
		if #available(iOS 11, *) {
			textViewBottomConstraint = notesTextView.bottomAnchor.constraint(equalTo: inputToolbar.safeAreaLayoutGuide.bottomAnchor, constant: -8)
			NSLayoutConstraint.activate([
				notesTextView.leadingAnchor.constraint(equalTo: inputToolbar.safeAreaLayoutGuide.leadingAnchor, constant: 8),
				notesTextView.trailingAnchor.constraint(equalTo: inputToolbar.safeAreaLayoutGuide.trailingAnchor, constant: -8),
				textViewBottomConstraint
				])
		} else {
			
			textViewBottomConstraint = notesTextView.bottomAnchor.constraint(equalTo: inputToolbar.bottomAnchor, constant: -8)
			NSLayoutConstraint.activate([
				notesTextView.leadingAnchor.constraint(equalTo: inputToolbar.leadingAnchor, constant: 8),
				notesTextView.trailingAnchor.constraint(equalTo: inputToolbar.trailingAnchor, constant: -8),
				textViewBottomConstraint
				])
		}
		
		// *** Listen to keyboard show / hide ***
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)

		// *** Hide keyboard when tapping outside ***
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
		view.addGestureRecognizer(tapGesture)

	}

	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	@objc private func keyboardWillChangeFrame(_ notification: Notification) {
		if let endFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
			var keyboardHeight = view.bounds.height - endFrame.origin.y
			if #available(iOS 11, *) {
				if keyboardHeight > 0 {
					keyboardHeight = keyboardHeight - view.safeAreaInsets.bottom
				}
			}
			
			if notesTextView.isFirstResponder {
				textViewBottomConstraint.constant = -keyboardHeight - 8
			}
			view.layoutIfNeeded()
		}
	}
	
	@objc private func tapGestureHandler() {
		view.endEditing(true)
	}
	
	func shiftView(by: CGFloat, up: Bool)	{
		let movementDuration: Double = 0.3
		var movement:CGFloat = -by
		if up {
			movement = by
		}
		UIView.beginAnimations("animateTextField", context: nil)
		UIView.setAnimationBeginsFromCurrentState(true)
		UIView.setAnimationDuration(movementDuration)
		self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
		UIView.commitAnimations()
	}

	func updateView() {
		for subview in scroll.subviews {
			subview.removeFromSuperview()
		}
		
		teleopView.adjustHeight()
		autoView.adjustHeight()
		summaryView.adjustHeight()
		
		for v in scroll.subviews{
			v.removeFromSuperview()
		}
		
		switch segmentedAutoTeleop.selectedSegmentIndex  {
			case 0:
				scroll.addSubview(autoView)
				self.scroll.contentSize = self.autoView.frame.size
			case 1:
				scroll.addSubview(teleopView)
				self.scroll.contentSize = self.teleopView.frame.size
			default:
				scroll.addSubview(summaryView)
				self.scroll.contentSize = self.summaryView.frame.size
		}
	}
	
	@IBAction func segmentChanged(_ sender: Any) {
		updateView()
	}
	override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func cancel() {
		navigationController?.popViewController(animated: true)
		dismiss(animated: true, completion: nil)
	}
	
	@IBAction func donePressed(_ sender: Any) {
		submit()
		cancel()
	}
	
	func submit() {
		if let m = match {
			Fetch().submit(m)
		}
	}
	
	
	
	@objc func textFieldDidBeginEditing(_ textField: UITextField) {
		animateViewMoving(true, moveValue: 100)
	}
	
	@objc func textFieldDidEndEditing(_ textField: UITextField) {
		animateViewMoving(false, moveValue: 100)
	}
	
	// Lifting the view up
	func animateViewMoving(_ up:Bool, moveValue :CGFloat){
//		let movement:CGFloat = ( up ? -moveValue : moveValue)
//
		// AT THE MOMENT, THE SCROLLVIEW DOES NOT SHIFT UPWARD TO MAKE ROOM FOR THE TEXTFIELDBIT.
		
//		if let v = EditViewController().view {
//			v.shiftTheScroll(movement)
//		} else {
//			print("I found the culprit")
//		}
		
	}
}

extension UIView {
	class func fromNib<T: UIView>() -> T {
		return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
	}
	func shiftTheScroll(_ movement: CGFloat) {
		for v in self.subviews {
			if let view = v as? UIScrollView {
				view.setContentOffset(CGPoint(x: 0, y: movement), animated: true)
			}
		}
	}
}


extension UIColor {
	convenience init(red: Int, green: Int, blue: Int) {
		assert(red >= 0 && red <= 255, "Invalid red component")
		assert(green >= 0 && green <= 255, "Invalid green component")
		assert(blue >= 0 && blue <= 255, "Invalid blue component")
		
		self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
	}
	
	convenience init(rgb: Int) {
		self.init(
			red: (rgb >> 16) & 0xFF,
			green: (rgb >> 8) & 0xFF,
			blue: rgb & 0xFF
		)
	}
	
}

extension EditViewController: GrowingTextViewDelegate {
	
	// *** Call layoutIfNeeded on superview for animation when changing height ***
	
	func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
		UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [.curveLinear], animations: { () -> Void in
			self.view.layoutIfNeeded()
		}, completion: nil)
	}
	
	func textViewDidChange(_ textView: UITextView) {
		if textView == notesTextView {
			info.updateValue(textView.text, forKey: "notes")
		}
	}
	func textViewDidEndEditing(_ textView: UITextView) {
		if textView == notesTextView {
			info.updateValue(textView.text, forKey: "notes")
		}
	}
	
	
	
}

extension String {
	func left(of: Character) -> String {
		if let ind = self.index(of: of) {
			return String(self[..<ind])
		}
		return ""
	}
	func right(of: Character) -> String {
		if let ind = self.index(of: of) {
			var s = String(self[ind...])
			s.removeFirst()
			return s
		}
		return ""
	}
}

extension UIView {
	
	func process(withInstructions: NSDictionary, withPreloads:NSDictionary?, team: String, match: String) {
		
		for i in 0 ..< withInstructions.allValues.count {
			
			let k = (withInstructions.allKeys as! [String]).sorted(by: <)[i]
			let dict = withInstructions.value(forKey: k) as! NSDictionary
			let type = k.right(of: "-").left(of: "-")
			
			let pl = withPreloads?.valFor(dict.valFor("key")) ?? ""
			
			switch type {
				case "stepper":
					self.pileSubview(StepBit(key: dict.valFor("key"), title: dict.valFor("title"), color: dict.valFor("color"), preload: pl))
				case "stopwatch":
					self.pileSubview(StopwatchBit(key: dict.valFor("key"), title: dict.valFor("title")))
				case "textField":
					self.pileSubview(TextFieldBit(key: dict.valFor("key"), title: dict.valFor("title"), isNumberPad: dict.valFor("isNumberPad"), preload: pl))
				case "starRating":
					self.pileSubview(StarBit(key: dict.valFor("key"), title: dict.valFor("title"), preload: pl))
				case "divider":
					self.pileSubview(DividerBit(key: dict.valFor("key"), title: dict.valFor("title")))
				case "segmentedControl":
					self.pileSubview(SegmentBit(key: dict.valFor("key"), title: dict.valFor("title"), titles: dict.arrFor("titles"), preload: pl))
				default:
					print("Dang it... I don't know what a " + type + " is.")
			}
		}
		pileSubview(UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 200)))
	}
	
	func pileSubview(_ view: UIView) {
		let maxy = self.getMaxY()
		view.frame = CGRect(x: 8, y: maxy, width: self.frame.width - 16, height: view.frame.height)
		self.addSubview(view)
	}
	
	func getMaxY() -> CGFloat {
		var maxy = CGFloat(0)
		for view in self.subviews.reversed() {
			if view.frame.maxY > maxy {
				maxy = view.frame.maxY
			}
		}
		return maxy
	}
	
	func adjustHeight() {
		self.frame = CGRect(x: self.frame.minX, y: self.frame.minY, width: self.frame.width, height: self.getMaxY() - self.frame.minY)
	}
	func getSelectedTextField() -> UITextField? {
		
		let totalTextFields = getTextFieldsInView(view: self)
		
		for textField in totalTextFields{
			if textField.isFirstResponder{
				return textField
			}
		}
		
		return nil
		
	}
	
	func getTextFieldsInView(view: UIView) -> [UITextField] {
		
		var totalTextFields = [UITextField]()
		
		for subview in view.subviews as [UIView] {
			if let textField = subview as? UITextField {
				totalTextFields += [textField]
			} else {
				totalTextFields += getTextFieldsInView(view: subview)
			}
		}
		
		return totalTextFields
	}
}

extension NSDictionary {
	func valFor(_ key: String) -> String {
		let a = self.value(forKey: key)
		if let v = a as? String {
			return v
		}
		return ""
	}
	func arrFor(_ key: String) -> [String] {
		let a = self.value(forKey: key)
		if let v = a as? NSArray {
			if let arr = v as? [String] {
				return arr
			} else {
				print("NSArray to [String] failure")
			}
		} else {
			print("NSDictionary to NSArray failure")
		}
		return [String]()
	}
	
}

extension UIColor {
	convenience init(hexString: String) {
		let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
		var int = UInt32()
		Scanner(string: hex).scanHexInt32(&int)
		let a, r, g, b: UInt32
		switch hex.count {
		case 3: // RGB (12-bit)
			(a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
		case 6: // RGB (24-bit)
			(a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
		case 8: // ARGB (32-bit)
			(a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
		default:
			(a, r, g, b) = (255, 0, 0, 0)
		}
		self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
	}
}
