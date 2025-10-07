//
//  Date+Extension.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 24/04/2025.
//

import Foundation

extension Date {
	func formatted() -> String {
		let calendar = Calendar.current
		let dateFormatter = DateFormatter()
		
		if calendar.isDateInToday(self) {
			dateFormatter.dateFormat = "'Today at' h:mm a"
			return dateFormatter.string(from: self)
		} else if calendar.isDateInYesterday(self) {
			dateFormatter.dateFormat = "'Yesterday at' h:mm a"
			return dateFormatter.string(from: self)
		} else {
			dateFormatter.dateFormat = "h:mm a dd/MM/yyyy"
			return dateFormatter.string(from: self)
		}
	}
	
	var components: DateComponents {
		Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: self)
	}
	
	func isGreater(than date: Date, for components: Set<Calendar.Component>) -> Bool {
		let calendar = Calendar.current
		let selfComponents = calendar.dateComponents(components, from: self)
		let dateComponents = calendar.dateComponents(components, from: date)
		
		return calendar.date(from: selfComponents) ?? Date.now > calendar.date(from: dateComponents) ?? Date.now
	}
}
