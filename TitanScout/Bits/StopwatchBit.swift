//
//  StopwatchBit.swift
//  TitanScout
//
//  Created by Ian Fowler on 2/19/18.
//  Copyright © 2018 Ian Fowlercom.example. All rights reserved.
//

import UIKit


class StopwatchBit: Bit {
	
	var start = UIButton()
	var cancel = UIButton()
	var save = UIButton()
	var timeLabel = UILabel()
	
	weak var timer: Timer?
	var startTime: Double = 0
	var time: Double = 0
	var elapsed: Double = 0
	var status: Bool = false
	
	
	// Only override draw() if you perform custom drawing.
	// An empty implementation adversely affects performance during animation.
	override func draw(_ rect: CGRect) {
		
		self.addSubview(super.descriptionLabel)
		
		let h = 48
		let y = 24
		
		start.frame = CGRect(x: Int(self.frame.width) - 3*h - 24, y: y, width: h, height: h)
		save.frame = CGRect(x: Int(self.frame.width) - 2*h - 16, y: y, width: h, height: h)
		cancel.frame = CGRect(x: Int(self.frame.width) - h - 8, y: y, width: h, height: h)
		
		var w = self.frame.width / 2.0
		if start.frame.minX - 10.0 < w {
			w = start.frame.minX - 10.0
		}
		
		timeLabel.frame = CGRect(x: 0, y: y, width: Int(w), height: h)

		start.setTitle("Start", for: .normal)
		save.setTitle("Save", for: .normal)
		cancel.setTitle("Cancel", for: .normal)
		

		start.titleLabel?.font = UIFont(name: start.titleLabel?.font.fontName ?? "System", size: start.frame.width / 3.5)
		save.titleLabel?.font = UIFont(name: start.titleLabel?.font.fontName ?? "System", size: start.frame.width / 3.5)
		cancel.titleLabel?.font = UIFont(name: start.titleLabel?.font.fontName ?? "System", size: start.frame.width / 4)
		
		start.addTarget(self, action: #selector(startPressed), for: .touchUpInside)
		save.addTarget(self, action: #selector(savePressed), for: .touchUpInside)
		cancel.addTarget(self, action: #selector(cancelPressed), for: .touchUpInside)
		
		
		start.setTitleColor(self.tintColor, for: .normal)
		save.setTitleColor(self.tintColor, for: .normal)
		cancel.setTitleColor(self.tintColor, for: .normal)
		
		
		timeLabel.text = "00:00.0"
		timeLabel.font = UIFont(name: timeLabel.font.fontName, size: CGFloat(h))
		timeLabel.adjustsFontSizeToFitWidth = true
		
		self.addSubview(timeLabel)
		self.addSubview(start)
		self.addSubview(save)
		self.addSubview(cancel)
		
		// Drawing code
		configButton(b: start)
		configButton(b: save)
		configButton(b: cancel)
		
	}
	
	func cancelTimer() {
		
		UIView.animate(withDuration: 0.3) {
			self.start.layer.backgroundColor =  UIColor.clear.cgColor
			self.start.setTitleColor(self.tintColor, for: .normal)
		}
		
		
		// Invalidate timer
		timer?.invalidate()
		
		// Reset timer variables
		startTime = 0
		time = 0
		elapsed = 0
		status = false

	}
	@objc func cancelPressed() {
		cancelTimer()
		
		timeLabel.text = "00:00.0"
		
		self.cancel.layer.backgroundColor =  UIColor.clear.cgColor
		UIView.animate(withDuration: 0.3) {
			self.cancel.layer.backgroundColor =  self.tintColor.cgColor
		}
		UIView.animate(withDuration: 0.3) {
			self.cancel.layer.backgroundColor =  UIColor.clear.cgColor
		}
		
	}
	
	@objc func startPressed() {
		if !status {
			start.layer.backgroundColor =  UIColor.clear.cgColor
			UIView.animate(withDuration: 0.3) {
				self.start.layer.backgroundColor =  self.tintColor.cgColor
				self.start.setTitleColor(UIColor.white, for: .normal)
			}
			
			startTime = Date().timeIntervalSinceReferenceDate - elapsed
			timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
			
			// Set Start/Stop button to true
			status = true
		}
	}
	
	@objc func savePressed() {
		elapsed = Date().timeIntervalSinceReferenceDate - startTime
		timer?.invalidate()
		// Set Start/Stop button to false
		status = false
		if elapsed < 5000.0 {
			super.update(String(elapsed).replacingOccurrences(of: ".", with: "-"), withKey: super.dictKey + "-" + String(Date().timeIntervalSince1970).replacingOccurrences(of: ".", with: "-"))
			self.save.layer.backgroundColor =  UIColor.clear.cgColor
			UIView.animate(withDuration: 0.3) {
				self.save.layer.backgroundColor =  self.tintColor.cgColor
			}
			UIView.animate(withDuration: 0.3) {
				self.save.layer.backgroundColor =  UIColor.clear.cgColor
			}
		}
		cancelTimer()
	}
	
	@objc func updateCounter() {
		
		// Calculate total time since timer started in seconds
		time = Date().timeIntervalSinceReferenceDate - startTime
		
		// Calculate minutes
		let minutes = UInt8(time / 60.0)
		time -= (TimeInterval(minutes) * 60)
		
		// Calculate seconds
		let seconds = UInt8(time)
		time -= TimeInterval(seconds)
		
		// Calculate milliseconds
		let milliseconds = UInt8(time * 10)
		
		// Format time vars with leading zero
		let strMinutes = String(format: "%02d", minutes)
		let strSeconds = String(format: "%02d", seconds)
		let strMilliseconds = String(format: "%01d", milliseconds)

		// Add time vars to relevant labels
		timeLabel.text = strMinutes + ":" + strSeconds + "." + strMilliseconds
		
	}
	
	
	
	func configButton(b:UIButton) {
		b.layer.cornerRadius = b.frame.width/2
		b.layer.borderWidth = 1.0
		b.layer.borderColor = self.tintColor.cgColor
	}
	
	
	
}
